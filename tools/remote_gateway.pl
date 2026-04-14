#!/usr/bin/env perl

use strict;
use warnings;
use FindBin qw($RealBin);
use lib "$RealBin/../src";
use lib "$RealBin/../src/deps";

use IO::Select;
use IO::Socket::UNIX;
use IO::Socket::INET;
use Getopt::Long qw(GetOptions);
use Time::HiRes qw(time sleep);
use JSON::PP qw(encode_json decode_json);
use Digest::SHA qw(sha1);
use MIME::Base64 qw(encode_base64);

use Bus::Messages qw(serialize);
use Bus::MessageParser;

my $socket_path = 'console.socket';
my $listen_host = '127.0.0.1';
my $listen_port = 18085;
my $replay_size = 200;
my $connect_timeout = 1.0;
my $audit_file = 'gateway_audit.jsonl';
my $command_token = '';
my $command_rate_limit = 30;
my $command_rate_window = 60;
my $auth_enabled = 0;
my $users_file = '';
my $token_ttl = 900;
my $session_file = 'gateway_sessions.json';

GetOptions(
	'socket=s' => \$socket_path,
	'listen-host=s' => \$listen_host,
	'listen-port=i' => \$listen_port,
	'replay-size=i' => \$replay_size,
	'connect-timeout=f' => \$connect_timeout,
	'audit-file=s' => \$audit_file,
	'command-token=s' => \$command_token,
	'command-rate-limit=i' => \$command_rate_limit,
	'command-rate-window=i' => \$command_rate_window,
	'auth-enabled!' => \$auth_enabled,
	'users-file=s' => \$users_file,
	'token-ttl=i' => \$token_ttl,
	'session-file=s' => \$session_file,
) or die "Invalid arguments\n";

my $health_server = IO::Socket::INET->new(
	LocalAddr => $listen_host,
	LocalPort => $listen_port,
	Proto     => 'tcp',
	Listen    => 20,
	ReuseAddr => 1,
);

die "Cannot bind gateway endpoint on $listen_host:$listen_port: $!\n" if !$health_server;

my $selector = IO::Select->new($health_server);
my $parser = Bus::MessageParser->new();

my $kore_socket;
my %ws_clients;
my %state = (
	connected => 0,
	started_at => scalar(time),
	last_connect_at => undef,
	last_disconnect_at => undef,
	last_event_at => undef,
	reconnects => 0,
	events_seen => 0,
	connection_errors => 0,
	commands_seen => 0,
	commands_rejected => 0,
);

my @events;
my %command_rate_buckets;
my %users;
my %tokens;
my %refresh_tokens;

sub ws_frame_text {
	my ($payload) = @_;
	my $len = length($payload);
	my $head = chr(0x81);
	if ($len < 126) {
		$head .= chr($len);
	} elsif ($len <= 65535) {
		$head .= chr(126) . pack('n', $len);
	} else {
		$head .= chr(127) . pack('Q>', $len);
	}
	return $head . $payload;
}

sub ws_send_text {
	my ($client, $text) = @_;
	my $frame = ws_frame_text($text);
	my $written = syswrite($client, $frame);
	return defined $written;
}

sub ws_send_json {
	my ($client, $obj) = @_;
	return ws_send_text($client, encode_json($obj));
}

sub ws_remove_client {
	my ($client) = @_;
	my $fileno = fileno($client);
	delete $ws_clients{$fileno};
	$selector->remove($client);
	close $client;
}

sub broadcast_event {
	my ($event) = @_;
	my @stale;
	foreach my $fileno (keys %ws_clients) {
		my $client = $ws_clients{$fileno};
		my $ok = ws_send_json($client, { type => 'live_event', payload => $event });
		push @stale, $client if !$ok;
	}
	ws_remove_client($_) for @stale;
}

sub add_event {
	my ($event) = @_;
	push @events, $event;
	shift @events while @events > $replay_size;
	broadcast_event($event);
}

sub normalize_event {
	my ($id, $args) = @_;
	my $now = scalar(time);

	if ($id eq 'output') {
		return {
			kind => 'log_event',
			ts => $now,
			type => $args->{type},
			domain => $args->{domain},
			message => $args->{message},
		};
	} elsif ($id eq 'title changed') {
		return {
			kind => 'title_event',
			ts => $now,
			title => $args->{title},
		};
	} elsif ($id eq 'inputted') {
		return {
			kind => 'input_event',
			ts => $now,
			data => $args->{data},
		};
	}

	return {
		kind => 'unknown_event',
		ts => $now,
		id => $id,
	};
}

sub connect_kore {
	my $socket = IO::Socket::UNIX->new(
		Type => SOCK_STREAM,
		Peer => $socket_path,
		Timeout => $connect_timeout,
	);
	return $socket;
}

sub set_kore_socket {
	my ($socket) = @_;
	$kore_socket = $socket;
	if ($kore_socket) {
		$kore_socket->autoflush(1);
		$selector->add($kore_socket);
		$kore_socket->send(serialize('set active'));
		$state{connected} = 1;
		$state{last_connect_at} = scalar(time);
		add_event({ kind => 'gateway_event', ts => scalar(time), message => 'connected_to_openkore' });
	}
}

sub disconnect_kore {
	if ($kore_socket) {
		$selector->remove($kore_socket);
		close $kore_socket;
		$kore_socket = undef;
	}
	$state{connected} = 0;
	$state{last_disconnect_at} = scalar(time);
	add_event({ kind => 'gateway_event', ts => scalar(time), message => 'disconnected_from_openkore' });
}

sub ensure_connection {
	return if $kore_socket;
	my $sock = connect_kore();
	if ($sock) {
		$state{reconnects}++ if defined $state{last_disconnect_at};
		set_kore_socket($sock);
	} else {
		$state{connection_errors}++;
	}
}

sub build_health_payload {
	return {
		ok => JSON::PP::true,
		service => 'openkore-remote-gateway',
		time => scalar(time),
			config => {
				socket => $socket_path,
				listen_host => $listen_host,
				listen_port => $listen_port,
				replay_size => $replay_size,
				audit_file => $audit_file,
				command_token_required => $command_token ne '' ? JSON::PP::true : JSON::PP::false,
				command_rate_limit => $command_rate_limit,
				command_rate_window => $command_rate_window,
				auth_enabled => $auth_enabled ? JSON::PP::true : JSON::PP::false,
				token_ttl => $token_ttl,
				session_file => $session_file,
			},
		status => {
			connected => $state{connected} ? JSON::PP::true : JSON::PP::false,
			started_at => $state{started_at},
			last_connect_at => $state{last_connect_at},
			last_disconnect_at => $state{last_disconnect_at},
			last_event_at => $state{last_event_at},
			reconnects => $state{reconnects},
			events_seen => $state{events_seen},
			connection_errors => $state{connection_errors},
			commands_seen => $state{commands_seen},
			commands_rejected => $state{commands_rejected},
			ws_clients => scalar(keys %ws_clients),
		},
	};
}

sub write_http_response {
	my ($client, $status, $body, $content_type) = @_;
	$content_type ||= 'application/json';
	my $len = length($body);
	print $client "HTTP/1.1 $status\r\n";
	print $client "Content-Type: $content_type\r\n";
	print $client "X-Content-Type-Options: nosniff\r\n";
	print $client "X-Frame-Options: DENY\r\n";
	print $client "Referrer-Policy: no-referrer\r\n";
	print $client "Cache-Control: no-store\r\n";
	print $client "Content-Length: $len\r\n";
	print $client "Connection: close\r\n\r\n";
	print $client $body;
}

sub rate_limit_allows {
	my ($key) = @_;
	my $now = scalar(time);
	$key ||= 'unknown';
	my $bucket = $command_rate_buckets{$key};
	if (!$bucket) {
		$bucket = { window_start => $now, count => 0 };
		$command_rate_buckets{$key} = $bucket;
	}

	if (($now - $bucket->{window_start}) > $command_rate_window) {
		$bucket->{window_start} = $now;
		$bucket->{count} = 0;
	}

	$bucket->{count}++;
	return $bucket->{count} <= $command_rate_limit;
}

sub load_users {
	return if !$auth_enabled;
	if ($users_file eq '' || !-f $users_file) {
		die "Auth enabled but --users-file is missing or not found\n";
	}
	my $raw = '';
	open(my $fh, '<:encoding(UTF-8)', $users_file) or die "Cannot open users file $users_file: $!\n";
	local $/;
	$raw = <$fh>;
	close $fh;
	my $data = decode_json($raw);
	my $list = $data->{users};
	die "Invalid users file format (expected {\"users\": [...]})\n" if ref($list) ne 'ARRAY';
	%users = ();
	for my $u (@$list) {
		next if ref($u) ne 'HASH';
		next if !defined $u->{username} || !defined $u->{password};
		my $role = $u->{role} // 'viewer';
		$users{$u->{username}} = { password => $u->{password}, role => $role };
	}
	die "No valid users loaded from $users_file\n" if !keys(%users);
}

sub load_sessions {
	return if !$auth_enabled;
	return if !-f $session_file;
	open(my $fh, '<:encoding(UTF-8)', $session_file) or return;
	local $/;
	my $raw = <$fh>;
	close $fh;
	my $data = eval { decode_json($raw) };
	return if !$data || ref($data) ne 'HASH';
	%tokens = %{ $data->{tokens} || {} };
	%refresh_tokens = %{ $data->{refresh_tokens} || {} };
}

sub save_sessions {
	return if !$auth_enabled;
	my $payload = {
		tokens => \%tokens,
		refresh_tokens => \%refresh_tokens,
		saved_at => time(),
	};
	if (open(my $fh, '>:encoding(UTF-8)', $session_file)) {
		print $fh encode_json($payload);
		close $fh;
	}
}

sub cleanup_sessions {
	return if !$auth_enabled;
	my $now = time();
	for my $t (keys %tokens) {
		delete $tokens{$t} if ($tokens{$t}{expires_at} // 0) < $now;
	}
	for my $r (keys %refresh_tokens) {
		delete $refresh_tokens{$r} if ($refresh_tokens{$r}{expires_at} // 0) < $now;
	}
}

sub issue_token {
	my ($username, $role) = @_;
	my $seed = join(':', $username, $role, time(), rand(), $$, 'access');
	my $token = encode_base64(sha1($seed), '');
	my $refresh_seed = join(':', $username, $role, time(), rand(), $$, 'refresh');
	my $refresh = encode_base64(sha1($refresh_seed), '');
	$tokens{$token} = {
		username => $username,
		role => $role,
		expires_at => time() + $token_ttl,
		refresh_token => $refresh,
	};
	$refresh_tokens{$refresh} = {
		username => $username,
		role => $role,
		expires_at => time() + ($token_ttl * 8),
		access_token => $token,
	};
	save_sessions();
	return ($token, $refresh);
}

sub get_auth_token_from_headers {
	my ($headers) = @_;
	my $auth = $headers->{authorization} // '';
	if ($auth =~ /^Bearer\s+(.+)$/i) {
		return $1;
	}
	return '';
}

sub get_auth_token_from_query {
	my ($request_line) = @_;
	return '' if $request_line !~ m{^\w+\s+\S+\s+HTTP/1\.[01]$};
	my ($target) = $request_line =~ m{^\w+\s+(\S+)\s+HTTP/1\.[01]$};
	return '' if !defined $target || $target !~ /\?/;
	my ($q) = $target =~ /\?(.*)$/;
	return '' if !defined $q;
	for my $pair (split /&/, $q) {
		my ($k, $v) = split /=/, $pair, 2;
		next if !defined $k;
		if ($k eq 'token') {
			$v //= '';
			$v =~ tr/+/ /;
			$v =~ s/%([0-9A-Fa-f]{2})/chr(hex($1))/eg;
			return $v;
		}
	}
	return '';
}

sub role_allows {
	my ($role, $required) = @_;
	my %rank = (viewer => 1, operator => 2, admin => 3);
	return ($rank{$role} // 0) >= ($rank{$required} // 0);
}

sub authorize_request {
	my (%args) = @_;
	my $headers = $args{headers} || {};
	my $required_role = $args{required_role} || 'viewer';
	return (1, { role => 'operator', username => 'token_mode' }) if !$auth_enabled;

	my $token = get_auth_token_from_headers($headers);
	$token = $args{fallback_token} if $token eq '' && defined $args{fallback_token};
	return (0, 'missing_token') if $token eq '';
	my $sess = $tokens{$token};
	return (0, 'invalid_token') if !$sess;
	if ($sess->{expires_at} < time()) {
		delete $tokens{$token};
		save_sessions();
		return (0, 'token_expired');
	}
	return (0, 'forbidden') if !role_allows($sess->{role}, $required_role);
	return (1, $sess);
}

sub auth_error_status {
	my ($err) = @_;
	return '403 Forbidden' if defined $err && $err eq 'forbidden';
	return '401 Unauthorized';
}

sub build_ui_html {
	my $default_token = $command_token ne '' ? 'required' : 'optional';
	my $html = <<'HTML';
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>OpenKore Remote Gateway</title>
  <style>
    body { font-family: system-ui, sans-serif; margin: 0; background: #0b1020; color: #d8e0ff; }
    .wrap { max-width: 1000px; margin: 0 auto; padding: 16px; }
    .card { background: #121a33; border: 1px solid #263152; border-radius: 8px; padding: 12px; margin-bottom: 12px; }
    .row { display: flex; gap: 8px; flex-wrap: wrap; }
    input, button, textarea { border-radius: 6px; border: 1px solid #364574; background: #0f1731; color: #e4ebff; padding: 8px; }
    input, textarea { flex: 1; min-width: 200px; }
    button { cursor: pointer; background: #1d2c59; }
    pre { white-space: pre-wrap; word-break: break-word; max-height: 55vh; overflow: auto; background: #081024; border: 1px solid #263152; padding: 10px; border-radius: 6px; }
    .small { opacity: 0.8; font-size: 12px; }
  </style>
</head>
<body>
  <div class="wrap">
    <div class="card">
      <h2>OpenKore Remote Gateway UI (MVP)</h2>
      <div class="small">Token mode: __TOKEN_MODE__</div>
      <div class="row">
        <input id="username" placeholder="username" />
        <input id="password" type="password" placeholder="password" />
        <button id="login">Login</button>
      </div>
      <div class="row">
        <input id="token" placeholder="Authorization token / X-Command-Token" />
        <button id="saveToken">Save Token</button>
      </div>
    </div>

    <div class="card">
      <h3>Live Log</h3>
      <div class="row">
        <button id="connect">Connect WS</button>
        <button id="disconnect">Disconnect WS</button>
      </div>
      <pre id="log"></pre>
    </div>

    <div class="card">
      <h3>Command Console</h3>
      <div class="row">
        <input id="command" placeholder="Type command (e.g. status)" />
        <button id="send">Send</button>
      </div>
      <pre id="result"></pre>
    </div>
  </div>
<script>
(() => {
  const logEl = document.getElementById('log');
  const resultEl = document.getElementById('result');
  const tokenEl = document.getElementById('token');
  const userEl = document.getElementById('username');
  const passEl = document.getElementById('password');
  const cmdEl = document.getElementById('command');
  let ws = null;

  tokenEl.value = localStorage.getItem('gw_token') || '';

  function appendLog(line) {
    logEl.textContent += line + "\\n";
    logEl.scrollTop = logEl.scrollHeight;
  }

  document.getElementById('saveToken').onclick = () => {
    localStorage.setItem('gw_token', tokenEl.value || '');
    appendLog('[ui] token saved');
  };

  document.getElementById('login').onclick = async () => {
    const username = (userEl.value || '').trim();
    const password = passEl.value || '';
    if (!username || !password) return;
    const res = await fetch('/auth/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ username, password })
    });
    const body = await res.json().catch(() => ({}));
    if (res.ok && body.access_token) {
      tokenEl.value = body.access_token;
      localStorage.setItem('gw_token', body.access_token);
      appendLog('[auth] login ok, token saved');
      const me = await fetch('/auth/me', { headers: { 'Authorization': `Bearer ${body.access_token}` } });
      const meBody = await me.json().catch(() => ({}));
      if (me.ok) appendLog(`[auth] user=${meBody.username} role=${meBody.role}`);
    } else {
      appendLog('[auth] login failed');
    }
  };

  document.getElementById('connect').onclick = () => {
    if (ws) return;
    const proto = location.protocol === 'https:' ? 'wss' : 'ws';
    const token = tokenEl.value || localStorage.getItem('gw_token') || '';
    const q = token ? `?token=${encodeURIComponent(token)}` : '';
    ws = new WebSocket(`${proto}://${location.host}/ws/events${q}`);
    ws.onopen = () => appendLog('[ws] connected');
    ws.onclose = () => { appendLog('[ws] disconnected'); ws = null; };
    ws.onerror = () => appendLog('[ws] error');
    ws.onmessage = (ev) => appendLog(ev.data);
  };

  document.getElementById('disconnect').onclick = () => {
    if (ws) ws.close();
  };

  document.getElementById('send').onclick = async () => {
    const command = (cmdEl.value || '').trim();
    if (!command) return;
    const headers = { 'Content-Type': 'application/json' };
    const token = tokenEl.value || localStorage.getItem('gw_token') || '';
    if (token) {
      headers['Authorization'] = `Bearer ${token}`;
      headers['X-Command-Token'] = token;
    }
    const res = await fetch('/commands', {
      method: 'POST',
      headers,
      body: JSON.stringify({ command })
    });
    const body = await res.text();
    resultEl.textContent = `[${res.status}] ${body}`;
  };
})();
</script>
</body>
</html>
HTML
	$html =~ s/__TOKEN_MODE__/$default_token/g;
	return $html;
}

sub audit_command {
	my ($entry) = @_;
	$entry->{audit_ts} = scalar(time);
	if (open(my $fh, '>>:encoding(UTF-8)', $audit_file)) {
		print $fh encode_json($entry) . "\n";
		close $fh;
	}
}

sub ws_upgrade_if_requested {
	my ($client, $request_line, $headers) = @_;
	return 0 if $request_line !~ m{^GET\s+/ws/events(?:\?.*)?\s+HTTP/1\.[01]$};
	return 0 if !defined $headers->{upgrade} || lc($headers->{upgrade}) ne 'websocket';
	return 0 if !defined $headers->{'sec-websocket-key'};
	if ($auth_enabled) {
		my $query_token = get_auth_token_from_query($request_line);
		my ($ok, $auth_res) = authorize_request(headers => $headers, required_role => 'viewer', fallback_token => $query_token);
		if (!$ok) {
			write_http_response($client, auth_error_status($auth_res), encode_json({ ok => JSON::PP::false, error => $auth_res }));
			return 1;
		}
	}

	my $magic = '258EAFA5-E914-47DA-95CA-C5AB0DC85B11';
	my $accept = encode_base64(sha1($headers->{'sec-websocket-key'} . $magic), '');

	print $client "HTTP/1.1 101 Switching Protocols\r\n";
	print $client "Upgrade: websocket\r\n";
	print $client "Connection: Upgrade\r\n";
	print $client "Sec-WebSocket-Accept: $accept\r\n\r\n";

	$client->autoflush(1);
	$selector->add($client);
	$ws_clients{fileno($client)} = $client;

	for my $event (@events) {
		my $ok = ws_send_json($client, { type => 'replay_event', payload => $event });
		if (!$ok) {
			ws_remove_client($client);
			return 1;
		}
	}

	return 1;
}

sub ws_handle_client_frame {
	my ($client) = @_;
	my $header = '';
	my $read = sysread($client, $header, 2);
	if (!defined $read || $read == 0) {
		ws_remove_client($client);
		return;
	}
	return if length($header) < 2;

	my ($b1, $b2) = unpack('CC', $header);
	my $opcode = $b1 & 0x0F;
	my $masked = ($b2 & 0x80) != 0;
	my $len = $b2 & 0x7F;

	if ($len == 126) {
		my $ext = '';
		if (sysread($client, $ext, 2) != 2) {
			ws_remove_client($client);
			return;
		}
		$len = unpack('n', $ext);
	} elsif ($len == 127) {
		my $ext = '';
		if (sysread($client, $ext, 8) != 8) {
			ws_remove_client($client);
			return;
		}
		$len = unpack('Q>', $ext);
	}

	my $mask = '';
	if ($masked) {
		if (sysread($client, $mask, 4) != 4) {
			ws_remove_client($client);
			return;
		}
	}

	my $payload = '';
	if ($len > 0) {
		my $got = sysread($client, $payload, $len);
		if (!defined $got || $got != $len) {
			ws_remove_client($client);
			return;
		}
	}

	if ($masked && $len > 0) {
		my @m = unpack('C4', $mask);
		my @bytes = unpack('C*', $payload);
		for (my $i = 0; $i < @bytes; $i++) {
			$bytes[$i] ^= $m[$i % 4];
		}
		$payload = pack('C*', @bytes);
	}

	if ($opcode == 0x8) {
		ws_remove_client($client);
	} elsif ($opcode == 0x9) {
		my $pong = chr(0x8A) . chr(length($payload)) . $payload;
		syswrite($client, $pong);
	}
}

sub handle_command_request {
	my ($client, $headers, $body, $remote_addr) = @_;
	$state{commands_seen}++;

	if ($auth_enabled) {
		my ($ok, $auth_res) = authorize_request(headers => $headers, required_role => 'operator');
		if (!$ok) {
			$state{commands_rejected}++;
			audit_command({ remote_addr => $remote_addr, status => 'rejected', reason => $auth_res });
			write_http_response($client, auth_error_status($auth_res), encode_json({ ok => JSON::PP::false, error => $auth_res }));
			return;
		}
	} else {
		my $token = $headers->{'x-command-token'} // '';
		if ($command_token ne '' && $token ne $command_token) {
			$state{commands_rejected}++;
			audit_command({ remote_addr => $remote_addr, status => 'rejected', reason => 'invalid_token' });
			write_http_response($client, '401 Unauthorized', encode_json({ ok => JSON::PP::false, error => 'invalid_token' }));
			return;
		}
	}

	my $payload;
	eval { $payload = decode_json($body || '{}'); 1 } or do {
		$state{commands_rejected}++;
		audit_command({ remote_addr => $remote_addr, status => 'rejected', reason => 'invalid_json' });
		write_http_response($client, '400 Bad Request', encode_json({ ok => JSON::PP::false, error => 'invalid_json' }));
		return;
	};

	my $command = $payload->{command} // '';
	$command =~ s/^\s+//;
	$command =~ s/\s+$//;

	if ($command eq '' || length($command) > 256 || $command =~ /[^[:print:]\t]/) {
		$state{commands_rejected}++;
		audit_command({ remote_addr => $remote_addr, status => 'rejected', reason => 'invalid_command', command => $command });
		write_http_response($client, '422 Unprocessable Entity', encode_json({ ok => JSON::PP::false, error => 'invalid_command' }));
		return;
	}

	if (!rate_limit_allows($remote_addr)) {
		$state{commands_rejected}++;
		audit_command({ remote_addr => $remote_addr, status => 'rejected', reason => 'rate_limited', command => $command });
		write_http_response($client, '429 Too Many Requests', encode_json({ ok => JSON::PP::false, error => 'rate_limited' }));
		return;
	}

	if (!$kore_socket) {
		$state{commands_rejected}++;
		audit_command({ remote_addr => $remote_addr, status => 'rejected', reason => 'core_unavailable', command => $command });
		write_http_response($client, '503 Service Unavailable', encode_json({ ok => JSON::PP::false, error => 'core_unavailable' }));
		return;
	}

	my $sent = $kore_socket->send(serialize('input', { data => $command }));
	if (!$sent) {
		$state{commands_rejected}++;
		audit_command({ remote_addr => $remote_addr, status => 'rejected', reason => 'send_failed', command => $command });
		write_http_response($client, '502 Bad Gateway', encode_json({ ok => JSON::PP::false, error => 'send_failed' }));
		return;
	}

	audit_command({ remote_addr => $remote_addr, status => 'accepted', reason => 'forwarded', command => $command });
	add_event({ kind => 'command_event', ts => scalar(time), source => $remote_addr, command => $command });
	write_http_response($client, '202 Accepted', encode_json({ ok => JSON::PP::true, accepted => JSON::PP::true }));
}

sub handle_auth_login {
	my ($client, $body, $remote_addr) = @_;
	if (!$auth_enabled) {
		write_http_response($client, '400 Bad Request', encode_json({ ok => JSON::PP::false, error => 'auth_disabled' }));
		return;
	}

	my $payload;
	eval { $payload = decode_json($body || '{}'); 1 } or do {
		write_http_response($client, '400 Bad Request', encode_json({ ok => JSON::PP::false, error => 'invalid_json' }));
		return;
	};

	my $username = $payload->{username} // '';
	my $password = $payload->{password} // '';
	my $u = $users{$username};
	if (!$u || $u->{password} ne $password) {
		audit_command({ remote_addr => $remote_addr, status => 'rejected', reason => 'invalid_credentials', username => $username });
		write_http_response($client, '401 Unauthorized', encode_json({ ok => JSON::PP::false, error => 'invalid_credentials' }));
		return;
	}

	my ($token, $refresh) = issue_token($username, $u->{role});
	write_http_response($client, '200 OK', encode_json({
		ok => JSON::PP::true,
		access_token => $token,
		refresh_token => $refresh,
		role => $u->{role},
		expires_in => $token_ttl,
	}));
}

sub handle_auth_refresh {
	my ($client, $body) = @_;
	if (!$auth_enabled) {
		write_http_response($client, '400 Bad Request', encode_json({ ok => JSON::PP::false, error => 'auth_disabled' }));
		return;
	}
	my $payload;
	eval { $payload = decode_json($body || '{}'); 1 } or do {
		write_http_response($client, '400 Bad Request', encode_json({ ok => JSON::PP::false, error => 'invalid_json' }));
		return;
	};
	my $refresh = $payload->{refresh_token} // '';
	my $sess = $refresh_tokens{$refresh};
	if (!$sess) {
		write_http_response($client, '401 Unauthorized', encode_json({ ok => JSON::PP::false, error => 'invalid_refresh_token' }));
		return;
	}
	if ($sess->{expires_at} < time()) {
		delete $refresh_tokens{$refresh};
		save_sessions();
		write_http_response($client, '401 Unauthorized', encode_json({ ok => JSON::PP::false, error => 'refresh_token_expired' }));
		return;
	}

	delete $tokens{$sess->{access_token}} if $sess->{access_token};
	delete $refresh_tokens{$refresh};
	save_sessions();
	my ($new_access, $new_refresh) = issue_token($sess->{username}, $sess->{role});
	write_http_response($client, '200 OK', encode_json({
		ok => JSON::PP::true,
		access_token => $new_access,
		refresh_token => $new_refresh,
		role => $sess->{role},
		expires_in => $token_ttl,
	}));
}

sub handle_auth_revoke {
	my ($client, $body) = @_;
	if (!$auth_enabled) {
		write_http_response($client, '400 Bad Request', encode_json({ ok => JSON::PP::false, error => 'auth_disabled' }));
		return;
	}
	my $payload;
	eval { $payload = decode_json($body || '{}'); 1 } or do {
		write_http_response($client, '400 Bad Request', encode_json({ ok => JSON::PP::false, error => 'invalid_json' }));
		return;
	};
	my $refresh = $payload->{refresh_token} // '';
	my $sess = delete $refresh_tokens{$refresh};
	if ($sess && $sess->{access_token}) {
		delete $tokens{$sess->{access_token}};
	}
	save_sessions();
	write_http_response($client, '200 OK', encode_json({ ok => JSON::PP::true, revoked => JSON::PP::true }));
}

sub handle_auth_me {
	my ($client, $headers) = @_;
	if (!$auth_enabled) {
		write_http_response($client, '400 Bad Request', encode_json({ ok => JSON::PP::false, error => 'auth_disabled' }));
		return;
	}
	my ($ok, $auth_res) = authorize_request(headers => $headers, required_role => 'viewer');
	if (!$ok) {
		write_http_response($client, auth_error_status($auth_res), encode_json({ ok => JSON::PP::false, error => $auth_res }));
		return;
	}
	write_http_response($client, '200 OK', encode_json({
		ok => JSON::PP::true,
		username => $auth_res->{username},
		role => $auth_res->{role},
		expires_at => $auth_res->{expires_at},
	}));
}

sub handle_audit_request {
	my ($client, $headers, $request_line, $remote_addr) = @_;
	if ($auth_enabled) {
		my ($ok, $auth_res) = authorize_request(headers => $headers, required_role => 'admin');
		if (!$ok) {
			write_http_response($client, auth_error_status($auth_res), encode_json({ ok => JSON::PP::false, error => $auth_res }));
			return;
		}
	} else {
		my $token = $headers->{'x-command-token'} // '';
		if ($command_token ne '' && $token ne $command_token) {
			write_http_response($client, '401 Unauthorized', encode_json({ ok => JSON::PP::false, error => 'invalid_token' }));
			return;
		}
	}

	my $limit = 50;
	if ($request_line =~ /[?&]limit=(\d+)/) {
		$limit = int($1);
	}
	$limit = 1 if $limit < 1;
	$limit = 200 if $limit > 200;

	my @lines;
	if (open(my $fh, '<:encoding(UTF-8)', $audit_file)) {
		@lines = <$fh>;
		close $fh;
	}
	my @slice = @lines > $limit ? @lines[-$limit..$#lines] : @lines;
	my @items;
	for my $line (@slice) {
		chomp $line;
		next if $line eq '';
		my $item;
		eval { $item = decode_json($line); 1 } or next;
		push @items, $item;
	}

	write_http_response($client, '200 OK', encode_json({
		ok => JSON::PP::true,
		count => scalar(@items),
		data => \@items,
		requested_by => $remote_addr,
	}));
}

sub handle_http_client {
	my ($client) = @_;
	$client->autoflush(1);

	my $raw = '';
	my $max_header = 65536;
	while (index($raw, "\r\n\r\n") == -1 && length($raw) < $max_header) {
		my $chunk = '';
		my $got = sysread($client, $chunk, 4096);
		if (!defined $got || $got <= 0) {
			close $client;
			return;
		}
		$raw .= $chunk;
	}

	my $sep_idx = index($raw, "\r\n\r\n");
	if ($sep_idx == -1) {
		close $client;
		return;
	}

	my $head = substr($raw, 0, $sep_idx);
	my $body = substr($raw, $sep_idx + 4);
	my @lines = split(/\r\n/, $head);
	my $request_line = shift @lines;
	my %headers;
	for my $line (@lines) {
		if ($line =~ /^([^:]+):\s*(.*)$/) {
			$headers{lc($1)} = $2;
		}
	}

	if (ws_upgrade_if_requested($client, $request_line, \%headers)) {
		return;
	}

	my $content_length = $headers{'content-length'} // 0;
	if ($content_length > length($body)) {
		my $remaining = $content_length - length($body);
		while ($remaining > 0) {
			my $chunk = '';
			my $got = sysread($client, $chunk, $remaining);
			last if !defined $got || $got <= 0;
			$body .= $chunk;
			$remaining -= $got;
		}
	}

	my $remote_addr = eval { $client->peerhost() } || 'unknown';

	if ($request_line =~ m{^GET\s+/health\s+HTTP/1\.[01]$}) {
		my $payload = build_health_payload();
		write_http_response($client, '200 OK', encode_json($payload));
	} elsif ($request_line =~ m{^GET\s+/\s+HTTP/1\.[01]$}) {
		write_http_response($client, '200 OK', build_ui_html(), 'text/html; charset=utf-8');
	} elsif ($request_line =~ m{^GET\s+/events\s+HTTP/1\.[01]$}) {
		my $payload = { ok => JSON::PP::true, data => \@events };
		write_http_response($client, '200 OK', encode_json($payload));
	} elsif ($request_line =~ m{^GET\s+/audit(?:\?.*)?\s+HTTP/1\.[01]$}) {
		handle_audit_request($client, \%headers, $request_line, $remote_addr);
	} elsif ($request_line =~ m{^GET\s+/auth/me\s+HTTP/1\.[01]$}) {
		handle_auth_me($client, \%headers);
	} elsif ($request_line =~ m{^POST\s+/auth/login\s+HTTP/1\.[01]$}) {
		handle_auth_login($client, $body, $remote_addr);
	} elsif ($request_line =~ m{^POST\s+/auth/refresh\s+HTTP/1\.[01]$}) {
		handle_auth_refresh($client, $body);
	} elsif ($request_line =~ m{^POST\s+/auth/revoke\s+HTTP/1\.[01]$}) {
		handle_auth_revoke($client, $body);
	} elsif ($request_line =~ m{^POST\s+/commands\s+HTTP/1\.[01]$}) {
		handle_command_request($client, \%headers, $body, $remote_addr);
	} else {
		write_http_response($client, '404 Not Found', encode_json({ ok => JSON::PP::false, error => 'not_found' }));
	}

	close $client;
}

sub process_kore_data {
	my ($chunk) = @_;
	$parser->add($chunk);
	my $id;
	while (my $args = $parser->readNext(\$id)) {
		$state{events_seen}++;
		$state{last_event_at} = scalar(time);
		add_event(normalize_event($id, $args));
	}
}

print "[gateway] health endpoint at http://$listen_host:$listen_port/health\n";
print "[gateway] events endpoint at http://$listen_host:$listen_port/events\n";
print "[gateway] ws endpoint at ws://$listen_host:$listen_port/ws/events\n";
print "[gateway] command endpoint at http://$listen_host:$listen_port/commands\n";
print "[gateway] audit endpoint at http://$listen_host:$listen_port/audit\n";
if ($auth_enabled) {
	print "[gateway] auth login endpoint at http://$listen_host:$listen_port/auth/login\n";
	print "[gateway] auth me endpoint at http://$listen_host:$listen_port/auth/me\n";
	print "[gateway] auth refresh endpoint at http://$listen_host:$listen_port/auth/refresh\n";
	print "[gateway] auth revoke endpoint at http://$listen_host:$listen_port/auth/revoke\n";
	print "[gateway] session file: $session_file\n";
}
print "[gateway] connecting to OpenKore socket: $socket_path\n";
load_users();
load_sessions();
add_event({ kind => 'gateway_event', ts => scalar(time), message => 'gateway_started' });

while (1) {
	cleanup_sessions();
	ensure_connection();

	my @ready = $selector->can_read(0.5);
	for my $fh (@ready) {
		if ($fh == $health_server) {
			my $client = $health_server->accept();
			handle_http_client($client) if $client;
			next;
		}

		if ($kore_socket && $fh == $kore_socket) {
			my $buf = '';
			my $read = $kore_socket->recv($buf, 32 * 1024);
			if (!defined $read || !defined $buf || $buf eq '') {
				disconnect_kore();
				next;
			}
			process_kore_data($buf);
			next;
		}

		if (exists $ws_clients{fileno($fh)}) {
			ws_handle_client_frame($fh);
		}
	}

	sleep 0.1 if !$kore_socket;
}
