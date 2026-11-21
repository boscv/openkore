import glob
import json
import os
import re
from typing import Dict, List

ROOT = 'plugins/eventMacro/eventMacro'
COND_FILES = sorted(glob.glob(f'{ROOT}/Condition/*.pm'))
META_FILES = sorted(glob.glob(f'{ROOT}/Condition/*.pm')) + sorted(glob.glob(f'{ROOT}/Condition/Base/*.pm')) + sorted(glob.glob(f'{ROOT}/Conditiontypes/*.pm')) + [f'{ROOT}/Condition.pm']


def first_line(text: str, pattern: str) -> int:
    m = re.search(pattern, text, re.S)
    if not m:
        return -1
    return text[:m.start()].count('\n') + 1


def extract_hooks(text: str) -> List[str]:
    hm = re.search(r'sub\s+_hooks\s*\{\s*\[(.*?)\]\s*;?\s*\}', text, re.S)
    if not hm:
        return []
    return re.findall(r"'([^']+)'", hm.group(1))


meta: Dict[str, Dict] = {}
for path in META_FILES:
    text = open(path, encoding='utf-8').read()
    pkg_m = re.search(r'package\s+([\w:]+);', text)
    if not pkg_m:
        continue
    pkg = pkg_m.group(1)
    base_m = re.search(r"use base '([^']+)'", text)
    base = base_m.group(1) if base_m else None

    explicit_event = bool(re.search(r'sub\s+condition_type\s*\{\s*EVENT_TYPE\s*;?\s*\}', text, re.S))
    explicit_unique = bool(re.search(r'sub\s+is_unique_condition\s*\{\s*1\s*;?\s*\}', text, re.S))

    meta[pkg] = {
        'file': path,
        'base': base,
        'hooks': extract_hooks(text),
        'explicit_event': explicit_event,
        'explicit_unique': explicit_unique,
        'text': text,
    }


def ancestry(pkg: str) -> List[str]:
    out = []
    seen = set()
    while pkg and pkg not in seen:
        seen.add(pkg)
        out.append(pkg)
        pkg = meta.get(pkg, {}).get('base')
    return out


def resolve_event(pkg: str) -> str:
    for p in ancestry(pkg):
        if meta.get(p, {}).get('explicit_event'):
            return 'EVENT'
    return 'STATE'


def resolve_unique(pkg: str) -> bool:
    for p in ancestry(pkg):
        if meta.get(p, {}).get('explicit_unique'):
            return True
    return False


def parser_mode(pkg: str) -> str:
    chain = ancestry(pkg)
    chain_text = '\\n'.join(meta[p]['text'] for p in chain if p in meta)
    if any('Conditiontypes::NumericCondition' in p for p in chain):
        return 'numeric_comparison'
    if any('Conditiontypes::RegexCondition' in p for p in chain):
        return 'regex_literal'
    if any('Conditiontypes::ListCondition' in p for p in chain):
        return 'csv_list'
    if any('Conditiontypes::SimpleEvent' in p for p in chain):
        return 'simple_event'
    has_numeric_validator = 'Validator::NumericComparison' in chain_text
    has_regex_validator = 'Validator::RegexCheck' in chain_text
    has_list_validator = 'Validator::ListMemberCheck' in chain_text
    if has_regex_validator and has_numeric_validator:
        return 'composite_regex_numeric'
    if has_regex_validator and has_list_validator:
        return 'composite_regex_list'
    if has_numeric_validator and has_list_validator:
        return 'composite_numeric_list'
    if has_regex_validator:
        return 'regex_literal'
    if has_numeric_validator:
        return 'numeric_comparison'
    if has_list_validator:
        return 'csv_list'
    return 'custom'


def collect_new_vars(text: str) -> List[str]:
    return sorted(set(re.findall(r'\{"\.(.*?)"\}', text)))


catalog = []
for path in COND_FILES:
    text = open(path, encoding='utf-8').read()
    pkg = re.search(r'package\s+([\w:]+);', text).group(1)
    name = pkg.split('::')[-1]
    mode = parser_mode(pkg)

    syntax_fragments = []
    for pat in [
        r'\$condition_code\s*=~\s*/(.*?)/',
        r'if\s*\(\s*\$condition_code\s*=~\s*/(.*?)/',
        r'my\s+\@members\s*=\s*split\((.*?)\$condition_code\)',
    ]:
        for m in re.finditer(pat, text):
            syntax_fragments.append(m.group(1).strip())

    chain = ancestry(pkg)
    uses_find_variable = any('find_variable(' in meta[p]['text'] for p in chain if p in meta)

    accepts_regex = mode in ('regex_literal', 'composite_regex_numeric', 'composite_regex_list')
    accepts_range = mode in ('numeric_comparison', 'composite_regex_numeric', 'composite_numeric_list')
    accepts_csv = mode in ('csv_list', 'composite_regex_list', 'composite_numeric_list')
    accepts_variable = uses_find_variable

    operators = []
    if accepts_range:
        operators.extend(['=', '==', '!=', '!', '<', '<=', '>', '>=', 'range(..)'])
    if accepts_regex:
        operators.append('regex(/.../i?)')
    if accepts_csv:
        operators.append('csv membership')

    new_vars = collect_new_vars(text)

    entry = {
        'name': name,
        'module': pkg,
        'file': path,
        'base': meta[pkg]['base'],
        'ancestry': chain,
        'condition_type': resolve_event(pkg),
        'is_unique_condition': resolve_unique(pkg),
        'hooks': meta[pkg]['hooks'],
        'parser_mode': mode,
        'argument_contract': {
            'accepts_regex': accepts_regex,
            'accepts_range': accepts_range,
            'accepts_csv_list': accepts_csv,
            'accepts_variable': accepts_variable,
            'operators': operators,
            'regex_flags_supported': ['i'] if accepts_regex else [],
            'implicit_comparison_default': '==' if accepts_range else None,
        },
        'syntax_regex_fragments': syntax_fragments[:8],
        'sets_special_variables': new_vars,
        'confidence': {
            'condition_type': 'PROVADO',
            'hooks': 'PROVADO',
            'parser_mode': 'INFERIDO' if mode == 'custom' else 'PROVADO',
            'argument_contract': 'INFERIDO' if mode == 'custom' else 'PROVADO',
        },
        'evidence': {
            'package_line': first_line(text, r'package\s+[\w:]+;'),
            'hooks_line': first_line(text, r'sub\s+_hooks\s*\{'),
            'parse_syntax_line': first_line(text, r'sub\s+_parse_syntax\s*\{'),
            'validate_condition_line': first_line(text, r'sub\s+validate_condition\s*\{'),
            'new_vars_line': first_line(text, r'sub\s+get_new_variable_list\s*\{'),
            'file': path,
        },
    }

    catalog.append(entry)

print(json.dumps(catalog, indent=2, ensure_ascii=False))
