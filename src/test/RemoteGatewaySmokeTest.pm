package RemoteGatewaySmokeTest;

use strict;
use warnings;
use Test::More;
use IO::Socket::INET;
use File::Temp qw(tempdir);
use File::Spec;
use MIME::Base64 qw(encode_base64);

sub _http_request {
	my (%args) = @_;
	my $sock;
	for (1..8) {
		$sock = IO::Socket::INET->new(
			PeerAddr => '127.0.0.1',
			PeerPort => $args{port},
			Proto    => 'tcp',
			Timeout  => 2,
		);
		last if $sock;
		select(undef, undef, undef, 0.2);
	}
	ok($sock, 'connect to gateway HTTP port');
	return ('', '') if !$sock;

	$sock->autoflush(1);
	my $raw = $args{raw} // '';
	my $off = 0;
	while ($off < length($raw)) {
		my $written = syswrite($sock, $raw, length($raw) - $off, $off);
		if (!defined $written || $written <= 0) {
			close $sock;
			return ('', '');
		}
		$off += $written;
	}
	shutdown($sock, 1);
	my $resp = '';
	while (1) {
		my $chunk = '';
		my $got = sysread($sock, $chunk, 4096);
		last if !defined $got || $got <= 0;
		$resp .= $chunk;
	}
	close $sock;

	my ($status) = $resp =~ m{^HTTP/1\.[01]\s+([^\r\n]+)};
	return ($status || '', $resp);
}

sub _pick_random_free_port {
	for (1..20) {
		my $probe = IO::Socket::INET->new(
			LocalAddr => '127.0.0.1',
			LocalPort => 0,
			Proto     => 'tcp',
			Listen    => 1,
			ReuseAddr => 1,
		);
		if ($probe) {
			my $port = $probe->sockport();
			close $probe;
			return $port;
		}
		select(undef, undef, undef, 0.05);
	}
	die "Unable to pick a free TCP port on 127.0.0.1: $!";
}

sub _wait_for_port {
	my ($port, $tries) = @_;
	$tries = 300 if !defined $tries;
	for (1..$tries) {
		my $s = IO::Socket::INET->new(PeerAddr => '127.0.0.1', PeerPort => $port, Proto => 'tcp', Timeout => 0.2);
		if ($s) {
			close $s;
			return 1;
		}
		select(undef, undef, undef, 0.1);
	}
	return 0;
}

sub _slurp_if_exists {
	my ($path) = @_;
	return '' if !$path || !-f $path;
	open(my $fh, '<:raw', $path) or return '';
	local $/;
	my $data = <$fh>;
	close $fh;
	return $data // '';
}

sub _ws_handshake_status {
	my (%args) = @_;
	my $sock = IO::Socket::INET->new(
		PeerAddr => '127.0.0.1',
		PeerPort => $args{port},
		Proto    => 'tcp',
		Timeout  => 2,
	);
	ok($sock, 'connect to gateway WS port');
	return '' if !$sock;
	my $token_q = '';
	if ($args{token}) {
		my $tok = $args{token};
		$tok =~ s/([^A-Za-z0-9\-_.~])/sprintf("%%%02X", ord($1))/eg;
		$token_q = "?token=$tok";
	}
	my $key = encode_base64('smoketest-key-123', '');
	my $req = "GET /ws/events$token_q HTTP/1.1\r\n"
		. "Host: 127.0.0.1\r\n"
		. "Upgrade: websocket\r\n"
		. "Connection: Upgrade\r\n"
		. "Sec-WebSocket-Key: $key\r\n"
		. "Sec-WebSocket-Version: 13\r\n\r\n";
	print $sock $req;
	my $resp = '';
	while (my $line = <$sock>) {
		$resp .= $line;
		last if $line =~ /^\r?\n$/;
	}
	close $sock;
	my ($status) = $resp =~ m{^HTTP/1\.1\s+([^\r\n]+)};
	return $status || '';
}

sub start {
	select((select(STDOUT), $| = 1)[0]);
	my $tmp = tempdir(CLEANUP => 1);
	my $audit = "$tmp/gateway_audit.jsonl";
	my $users_file = "$tmp/users.json";
	my $session_file = "$tmp/sessions.json";
	open(my $uf, '>:encoding(UTF-8)', $users_file) or die "Cannot write users file";
	print $uf "{\"users\":[{\"username\":\"viewer\",\"password\":\"viewpw\",\"role\":\"viewer\"},{\"username\":\"operator\",\"password\":\"secret\",\"role\":\"operator\"},{\"username\":\"admin\",\"password\":\"adminpw\",\"role\":\"admin\"}]}\n";
	close $uf;
	my ($port, $pid, $startup_log, $gateway_ready) = (undef, undef, '', 0);
	for my $attempt (1..3) {
		$port = _pick_random_free_port();
		$startup_log = "$tmp/gateway_startup.$attempt.log";
		$pid = fork();
		if (!defined $pid) {
			fail('fork gateway process');
			return;
		}
		if ($pid == 0) {
			my $here = __FILE__;
			$here =~ s{[\\/][^\\/]+$}{};
			my $gateway_script = File::Spec->rel2abs(
				File::Spec->catfile($here, '..', '..', 'tools', 'remote_gateway.pl')
			);
			open(STDERR, '>>', $startup_log) or die "Cannot open startup log $startup_log: $!";
			open(STDOUT, '>>', $startup_log) or die "Cannot open startup log $startup_log: $!";
			if (!-f $gateway_script) {
				die "Gateway script not found at $gateway_script\n";
			}
			exec($^X, $gateway_script,
				'--socket', File::Spec->catfile($tmp, 'nonexistent.console.socket'),
				'--listen-host', '127.0.0.1',
				'--listen-port', $port,
				'--auth-enabled',
				'--users-file', $users_file,
				'--command-rate-limit', '2',
				'--command-rate-window', '60',
				'--audit-file', $audit,
				'--session-file', $session_file);
			die "Failed to exec gateway script with perl $^X: $!\n";
		}

		$gateway_ready = _wait_for_port($port, 300);
		last if $gateway_ready;

		my $kid = waitpid($pid, 1);
		my $raw_status = $?;
		my $startup_output = _slurp_if_exists($startup_log);
		my $exit_details = sprintf(
			'attempt=%d pid=%d raw_wait=%d exit=%d signal=%d',
			$attempt, $pid, $raw_status, ($raw_status >> 8), ($raw_status & 127)
		);
		diag("Gateway failed to listen on port $port ($exit_details)");
		diag("Gateway startup log ($startup_log):\n$startup_output") if $startup_output ne '';
		if ($kid != $pid) {
			kill 'TERM', $pid;
			waitpid($pid, 0);
		}
	}

	pass('fork gateway process');
	ok($gateway_ready, 'gateway port is ready');
	if (!$gateway_ready) {
		my $startup_output = _slurp_if_exists($startup_log);
		diag("Gateway final startup log ($startup_log):\n$startup_output") if $startup_output ne '';
		return;
	}

	my ($st_root, $resp_root) = _http_request(
		port => $port,
		raw => "GET / HTTP/1.1\r\nHost: 127.0.0.1\r\nConnection: close\r\n\r\n",
	);
	like($st_root, qr/^200/, 'GET / returns 200');
	like($resp_root, qr/OpenKore Remote Gateway UI/, 'GET / includes embedded UI');

	my ($st_no_token, $resp_no_token) = _http_request(
		port => $port,
		raw => "POST /commands HTTP/1.1\r\nHost: 127.0.0.1\r\nContent-Type: application/json\r\nContent-Length: 20\r\nConnection: close\r\n\r\n{\"command\":\"status\"}",
	);
	like($st_no_token, qr/^401/, 'POST /commands without token returns 401');
	like($resp_no_token, qr/missing_token|invalid_token/, 'missing token error payload');

	my $login_op_body = "{\"username\":\"operator\",\"password\":\"secret\"}";
	my ($st_login, $resp_login) = _http_request(
		port => $port,
		raw => "POST /auth/login HTTP/1.1\r\nHost: 127.0.0.1\r\nContent-Type: application/json\r\nContent-Length: " . length($login_op_body) . "\r\nConnection: close\r\n\r\n$login_op_body",
	);
	like($st_login, qr/^200/, 'auth login returns 200');
	like($resp_login, qr/access_token/, 'auth login returns access token');
	my ($access_token) = $resp_login =~ /\"access_token\":\"([^\"]+)\"/;
	my ($refresh_token) = $resp_login =~ /\"refresh_token\":\"([^\"]+)\"/;
	ok($access_token, 'parsed access token');
	ok($refresh_token, 'parsed refresh token');

	my ($st_me_op, $resp_me_op) = _http_request(
		port => $port,
		raw => "GET /auth/me HTTP/1.1\r\nHost: 127.0.0.1\r\nAuthorization: Bearer $access_token\r\nConnection: close\r\n\r\n",
	);
	like($st_me_op, qr/^200/, 'operator auth/me returns 200');
	like($resp_me_op, qr/"role":"operator"/, 'auth/me returns operator role');

	my ($st_events_anon, $resp_events_anon) = _http_request(
		port => $port,
		raw => "GET /events HTTP/1.1\r\nHost: 127.0.0.1\r\nConnection: close\r\n\r\n",
	);
	like($st_events_anon, qr/^401/, 'GET /events without token returns 401 in auth mode');
	like($resp_events_anon, qr/missing_token|invalid_token/, 'events endpoint enforces auth');

	my ($st_events_auth, $resp_events_auth) = _http_request(
		port => $port,
		raw => "GET /events HTTP/1.1\r\nHost: 127.0.0.1\r\nAuthorization: Bearer $access_token\r\nConnection: close\r\n\r\n",
	);
	like($st_events_auth, qr/^200/, 'GET /events with token returns 200');
	like($resp_events_auth, qr/"data":\[/, 'events response contains data array');

	my $req = "POST /commands HTTP/1.1\r\n"
		. "Host: 127.0.0.1\r\n"
		. "Authorization: Bearer $access_token\r\n"
		. "Content-Type: application/json\r\n"
		. "Content-Length: 20\r\n"
		. "Connection: close\r\n\r\n"
		. "{\"command\":\"status\"}";

	my ($st_cmd1, $resp_cmd1) = _http_request(port => $port, raw => $req);
	my ($st_cmd2, $resp_cmd2) = _http_request(port => $port, raw => $req);
	my ($st_cmd3, $resp_cmd3) = _http_request(port => $port, raw => $req);

	like($st_cmd1, qr/^503/, 'first valid command returns core_unavailable');
	like($st_cmd2, qr/^503/, 'second valid command returns core_unavailable');
	like($st_cmd3, qr/^429/, 'third valid command is rate limited');
	like($resp_cmd3, qr/rate_limited/, 'rate limit error payload');

	my $refresh_body = "{\"refresh_token\":\"$refresh_token\"}";
	my $refresh_len = length($refresh_body);
	my ($st_refresh, $resp_refresh) = _http_request(
		port => $port,
		raw => "POST /auth/refresh HTTP/1.1\r\nHost: 127.0.0.1\r\nContent-Type: application/json\r\nContent-Length: $refresh_len\r\nConnection: close\r\n\r\n$refresh_body",
	);
	like($st_refresh, qr/^200/, 'auth refresh returns 200');
	my ($refreshed_access) = $resp_refresh =~ /\"access_token\":\"([^\"]+)\"/;
	my ($refreshed_refresh) = $resp_refresh =~ /\"refresh_token\":\"([^\"]+)\"/;
	ok($refreshed_access, 'parsed refreshed access token');
	ok($refreshed_refresh, 'parsed refreshed refresh token');
	ok(-f $session_file, 'session file exists after auth activity');

	my ($st_audit_op, $resp_audit_op) = _http_request(
		port => $port,
		raw => "GET /audit?limit=5 HTTP/1.1\r\nHost: 127.0.0.1\r\nAuthorization: Bearer $access_token\r\nConnection: close\r\n\r\n",
	);
	like($st_audit_op, qr/^401/, 'operator cannot read audit');
	like($resp_audit_op, qr/forbidden|invalid_token/, 'operator audit response is blocked');

	my $login_view_body = "{\"username\":\"viewer\",\"password\":\"viewpw\"}";
	my ($st_login_viewer, $resp_login_viewer) = _http_request(
		port => $port,
		raw => "POST /auth/login HTTP/1.1\r\nHost: 127.0.0.1\r\nContent-Type: application/json\r\nContent-Length: " . length($login_view_body) . "\r\nConnection: close\r\n\r\n$login_view_body",
	);
	like($st_login_viewer, qr/^200/, 'viewer auth login returns 200');
	my ($viewer_token) = $resp_login_viewer =~ /\"access_token\":\"([^\"]+)\"/;
	ok($viewer_token, 'parsed viewer access token');

	my ($st_view_cmd, $resp_view_cmd) = _http_request(
		port => $port,
		raw => "POST /commands HTTP/1.1\r\nHost: 127.0.0.1\r\nAuthorization: Bearer $viewer_token\r\nContent-Type: application/json\r\nContent-Length: 20\r\nConnection: close\r\n\r\n{\"command\":\"status\"}",
	);
	like($st_view_cmd, qr/^403/, 'viewer cannot execute command');
	like($resp_view_cmd, qr/forbidden/, 'viewer command blocked by role');

	my ($st_view_audit, $resp_view_audit) = _http_request(
		port => $port,
		raw => "GET /audit?limit=5 HTTP/1.1\r\nHost: 127.0.0.1\r\nAuthorization: Bearer $viewer_token\r\nConnection: close\r\n\r\n",
	);
	like($st_view_audit, qr/^403/, 'viewer cannot access audit');
	like($resp_view_audit, qr/forbidden/, 'viewer audit blocked by role');

	my $ws_status = _ws_handshake_status(port => $port, token => $viewer_token);
	like($ws_status, qr/^101/, 'viewer can open ws/events');

	my $login_admin_body = "{\"username\":\"admin\",\"password\":\"adminpw\"}";
	my ($st_login_admin, $resp_login_admin) = _http_request(
		port => $port,
		raw => "POST /auth/login HTTP/1.1\r\nHost: 127.0.0.1\r\nContent-Type: application/json\r\nContent-Length: " . length($login_admin_body) . "\r\nConnection: close\r\n\r\n$login_admin_body",
	);
	like($st_login_admin, qr/^200/, 'admin auth login returns 200');
	my ($admin_token) = $resp_login_admin =~ /\"access_token\":\"([^\"]+)\"/;
	ok($admin_token, 'parsed admin access token');

	my ($st_audit_admin, $resp_audit_admin) = _http_request(
		port => $port,
		raw => "GET /audit?limit=5 HTTP/1.1\r\nHost: 127.0.0.1\r\nAuthorization: Bearer $admin_token\r\nConnection: close\r\n\r\n",
	);
	like($st_audit_admin, qr/^200/, 'admin can read audit');
	like($resp_audit_admin, qr/"data":\[/, 'audit response contains data array');

	my $revoke_body = "{\"refresh_token\":\"$refreshed_refresh\"}";
	my $revoke_len = length($revoke_body);
	my ($st_revoke, $resp_revoke) = _http_request(
		port => $port,
		raw => "POST /auth/revoke HTTP/1.1\r\nHost: 127.0.0.1\r\nContent-Type: application/json\r\nContent-Length: $revoke_len\r\nConnection: close\r\n\r\n$revoke_body",
	);
	like($st_revoke, qr/^200/, 'auth revoke returns 200');

	my ($st_cmd_revoked, $resp_cmd_revoked) = _http_request(
		port => $port,
		raw => "POST /commands HTTP/1.1\r\nHost: 127.0.0.1\r\nAuthorization: Bearer $refreshed_access\r\nContent-Type: application/json\r\nContent-Length: 20\r\nConnection: close\r\n\r\n{\"command\":\"status\"}",
	);
	like($st_cmd_revoked, qr/^401/, 'revoked access token cannot execute command');
	like($resp_cmd_revoked, qr/invalid_token|token_expired/, 'revoked token response');

	my ($st_me_revoked, $resp_me_revoked);
	for (1..2) {
		($st_me_revoked, $resp_me_revoked) = _http_request(
			port => $port,
			raw => "GET /auth/me HTTP/1.1\r\nHost: 127.0.0.1\r\nAuthorization: Bearer $refreshed_access\r\nConnection: close\r\n\r\n",
		);
		last if $st_me_revoked ne '';
		select(undef, undef, undef, 0.15);
	}
	like($st_me_revoked, qr/^401/, 'revoked access token cannot query auth/me');
	like($resp_me_revoked, qr/invalid_token|token_expired/, 'revoked auth/me response');

	kill 'TERM', $pid;
	waitpid($pid, 0);
	pass('gateway process terminated');
}

1;