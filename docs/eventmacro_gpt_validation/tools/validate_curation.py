import glob
import json
import os
import re

ROOT = 'plugins/eventMacro/eventMacro'
AUDIT = 'docs/eventmacro_gpt_audit'
VALIDATION_OUT = 'docs/eventmacro_gpt_validation/_validation_data.json'


def read(path):
    with open(path, encoding='utf-8') as f:
        return f.read()


def list_files(path):
    return sorted(os.path.basename(p) for p in glob.glob(os.path.join(path, '*')) if os.path.isfile(p))


def build_meta():
    files = sorted(glob.glob(f'{ROOT}/Condition/*.pm') + glob.glob(f'{ROOT}/Condition/Base/*.pm') + glob.glob(f'{ROOT}/Conditiontypes/*.pm') + [f'{ROOT}/Condition.pm'])
    meta = {}
    for path in files:
        text = read(path)
        pkg_m = re.search(r'package\s+([\w:]+);', text)
        if not pkg_m:
            continue
        pkg = pkg_m.group(1)
        base_m = re.search(r"use base '([^']+)'", text)
        base = base_m.group(1) if base_m else None
        event = bool(re.search(r'sub\s+condition_type\s*\{\s*EVENT_TYPE\s*;?\s*\}', text, re.S))
        hooks_m = re.search(r'sub\s+_hooks\s*\{\s*\[(.*?)\]\s*;?\s*\}', text, re.S)
        hooks = re.findall(r"'([^']+)'", hooks_m.group(1)) if hooks_m else []
        meta[pkg] = {'base': base, 'event': event, 'hooks': hooks, 'file': path}
    return meta


def parse_condition_names_from_table(path):
    names = []
    if not os.path.exists(path):
        return names
    for line in read(path).splitlines():
        if not line.startswith('|'):
            continue
        if line.startswith('|---'):
            continue
        cols = [c.strip() for c in line.split('|')[1:-1]]
        if not cols:
            continue
        first = cols[0]
        if first.lower() == 'condition':
            continue
        if first:
            names.append(first)
    return names


def resolve_event(meta, pkg):
    seen = set()
    while pkg and pkg not in seen:
        seen.add(pkg)
        m = meta.get(pkg)
        if not m:
            return False
        if m['event']:
            return True
        pkg = m['base']
    return False


def main():
    condition_files = sorted(glob.glob(f'{ROOT}/Condition/*.pm'))
    source_condition_count = len(condition_files)

    catalog = json.load(open(f'{AUDIT}/audit_full/09_condition_catalog.json', encoding='utf-8'))
    catalog_count = len(catalog)

    by_name = {c['name']: c for c in catalog}
    meta = build_meta()

    mismatches = []

    # existence
    for path in condition_files:
        name = os.path.basename(path)[:-3]
        if name not in by_name:
            mismatches.append({'severity': 'CRITICO', 'type': 'missing_in_catalog', 'name': name, 'source_file': path})

    # semantic checks
    required_catalog_keys = ['name', 'module', 'file', 'condition_type', 'hooks', 'parser_mode', 'argument_contract', 'confidence', 'evidence']
    for name, entry in by_name.items():
        src = f'{ROOT}/Condition/{name}.pm'
        if not os.path.exists(src):
            mismatches.append({'severity': 'CRITICO', 'type': 'catalog_points_to_missing_module', 'name': name, 'source_file': src})
            continue

        for key in required_catalog_keys:
            if key not in entry:
                mismatches.append({'severity': 'ALTO', 'type': 'missing_catalog_key', 'name': name, 'key': key})

        pkg = f'eventMacro::Condition::{name}'
        source_type = 'EVENT' if resolve_event(meta, pkg) else 'STATE'
        if entry.get('condition_type') != source_type:
            mismatches.append({'severity': 'CRITICO', 'type': 'wrong_condition_type', 'name': name, 'catalog': entry.get('condition_type'), 'source': source_type})

        source_hooks = meta.get(pkg, {}).get('hooks', [])
        if entry.get('hooks') != source_hooks:
            mismatches.append({'severity': 'ALTO', 'type': 'hooks_mismatch', 'name': name, 'catalog': entry.get('hooks'), 'source': source_hooks})

    # knowledge_ready budget
    knowledge_files = list_files(f'{AUDIT}/knowledge_ready')
    knowledge_file_count = len(knowledge_files)
    upload_budget_ok = knowledge_file_count <= 20

    # parser_mode distribution
    parser_mode_counts = {}
    for c in catalog:
        parser_mode_counts[c['parser_mode']] = parser_mode_counts.get(c['parser_mode'], 0) + 1

    # markdown<->json consistency for condition tables
    state_table_1 = parse_condition_names_from_table(f'{AUDIT}/knowledge_ready/07_conditions_state_part_1.md')
    state_table_2 = parse_condition_names_from_table(f'{AUDIT}/knowledge_ready/08_conditions_state_part_2.md')
    event_table = parse_condition_names_from_table(f'{AUDIT}/knowledge_ready/09_conditions_event.md')

    state_from_tables = state_table_1 + state_table_2
    state_from_json = [c['name'] for c in catalog if c['condition_type'] == 'STATE']
    event_from_json = [c['name'] for c in catalog if c['condition_type'] == 'EVENT']

    if sorted(state_from_tables) != sorted(state_from_json):
        mismatches.append({'severity': 'ALTO', 'type': 'state_tables_vs_json_mismatch', 'table_count': len(state_from_tables), 'json_count': len(state_from_json)})
    if sorted(event_table) != sorted(event_from_json):
        mismatches.append({'severity': 'ALTO', 'type': 'event_table_vs_json_mismatch', 'table_count': len(event_table), 'json_count': len(event_from_json)})

    # upload_manifest <-> knowledge_ready file list consistency
    manifest_path = f'{AUDIT}/knowledge_ready/16_upload_manifest.md'
    manifest_files = []
    if os.path.exists(manifest_path):
        for line in read(manifest_path).splitlines():
            m = re.match(r'^\d+\.\s+(.+)$', line.strip())
            if m:
                manifest_files.append(m.group(1).strip())
    if manifest_files and sorted(manifest_files) != sorted(knowledge_files):
        mismatches.append({'severity': 'ALTO', 'type': 'upload_manifest_vs_files_mismatch', 'manifest_count': len(manifest_files), 'actual_count': len(knowledge_files)})

    out = {
        'audit_full_files': list_files(f'{AUDIT}/audit_full'),
        'knowledge_ready_files': knowledge_files,
        'tools_files': list_files(f'{AUDIT}/tools'),
        'source_condition_count': source_condition_count,
        'catalog_count': catalog_count,
        'knowledge_file_count': knowledge_file_count,
        'knowledge_upload_budget_ok': upload_budget_ok,
        'parser_mode_counts': parser_mode_counts,
        'state_table_count': len(state_from_tables),
        'event_table_count': len(event_table),
        'manifest_file_count': len(manifest_files),
        'mismatches': mismatches,
    }

    with open(VALIDATION_OUT, 'w', encoding='utf-8') as f:
        json.dump(out, f, indent=2, ensure_ascii=False)

    print('wrote', VALIDATION_OUT)
    print('mismatches', len(mismatches))
    print('knowledge_file_count', knowledge_file_count, 'budget_ok', upload_budget_ok)


if __name__ == '__main__':
    main()
