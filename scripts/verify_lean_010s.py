#!/usr/bin/env python3
"""010s: fail-closed Lean source, axiom output, and SHA-256 auditing."""
from __future__ import annotations
import argparse
import hashlib
from pathlib import Path
import re
import sys

ALLOWED_AXIOMS = frozenset({'propext', 'Quot.sound', 'Classical.choice'})
FORBIDDEN_SOURCE = re.compile(r'\b(sorry|sorryAx|admit|axiom|native_decide|unsafe)\b|\b(?:Lean\.)?ofReduceBool\b')
FORBIDDEN_LOG = re.compile(r'\bsorryAx\b|\b(?:Lean\.)?ofReduceBool\b')
AUDIT = re.compile(r'depends on axioms:\s*\[([^\]]*)\]')
SUM_LINE = re.compile(r'^([0-9a-f]{64})\s{2}(\S+)$')

def uncomment(src: str) -> str:
    """Remove nested Lean block and line comments, retaining string literals."""
    out = []
    i = 0
    depth = 0
    in_string = False
    escape = False
    while i < len(src):
        if depth:
            if src.startswith('/-', i):
                depth += 1; i += 2
            elif src.startswith('-/', i):
                depth -= 1; i += 2
            else:
                if src[i] == '\n': out.append('\n')
                i += 1
            continue
        if in_string:
            ch = src[i]
            out.append(ch)
            if escape: escape = False
            elif ch == '\\': escape = True
            elif ch == '"': in_string = False
            i += 1
            continue
        if src.startswith('--', i):
            i = src.find('\n', i)
            if i < 0: break
            out.append('\n'); i += 1
        elif src.startswith('/-', i):
            depth = 1; i += 2
        elif src[i] == '"':
            in_string = True; out.append(src[i]); i += 1
        else:
            out.append(src[i]); i += 1
    if depth: raise ValueError('unterminated Lean block comment')
    return ''.join(out)

def verify_sources(paths: list[str]) -> int:
    for name in paths:
        p = Path(name)
        if not p.is_file() or not p.stat().st_size:
            raise ValueError(f'missing/empty Lean source: {p}')
        m = FORBIDDEN_SOURCE.search(uncomment(p.read_text()))
        if m: raise ValueError(f'forbidden Lean token in {p}: {m.group()}')
    return len(paths)

def verify_logs(paths: list[str]) -> int:
    total = 0
    for name in paths:
        p = Path(name)
        if not p.is_file() or not p.stat().st_size:
            raise ValueError(f'missing/empty compiler log: {p}')
        s = p.read_text(errors='replace')
        bad = FORBIDDEN_LOG.search(s)
        if bad: raise ValueError(f'forbidden kernel axiom in {p}: {bad.group()}')
        lines = AUDIT.findall(s)
        if not lines: raise ValueError(f'no #print axioms result in {p}')
        for l in lines:
            extras = set(x.strip() for x in l.split(',') if x.strip()) - ALLOWED_AXIOMS
            if extras: raise ValueError(f'foreign Lean axioms in {p}: {sorted(extras)}')
        total += len(lines)
    return total

def verify_hashes(registry: str, files: list[str]) -> int:
    if not files: return 0
    p = Path(registry)
    if not p.is_file(): raise ValueError(f'missing checksum registry: {p}')
    mapping: dict[str, list[str]] = {}
    for ln in p.read_text().splitlines():
        match = SUM_LINE.fullmatch(ln.strip())
        if match: mapping.setdefault(match.group(2), []).append(match.group(1))
    for name in files:
        if name not in mapping or len(mapping[name]) != 1:
            raise ValueError(f'hash entry missing/duplicated for {name}: {len(mapping.get(name, []))}')
        q = Path(name)
        if not q.is_file(): raise ValueError(f'missing hash target: {name}')
        actual = hashlib.sha256(q.read_bytes()).hexdigest()
        if actual != mapping[name][0]:
            raise ValueError(f'SHA-256 mismatch: {name} expected {mapping[name][0]}, got {actual}')
    return len(files)

def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--source', action='append', required=True)
    ap.add_argument('--log', action='append', required=True)
    ap.add_argument('--hash-file', action='append', required=True)
    ap.add_argument('--registry', default='SHA256SUMS')
    ns = ap.parse_args()
    try:
        x = verify_sources(ns.source)
        y = verify_logs(ns.log)
        z = verify_hashes(ns.registry, ns.hash_file)
    except (ValueError, OSError) as e:
        print('010s FAIL:', e, file=sys.stderr)
        return 1
    print(f'010s PASS: {x} Lean sources scanned; {y} theorem audits checked; {z} SHA-256 entries verified')
    return 0

if __name__ == '__main__':
    raise SystemExit(main())
