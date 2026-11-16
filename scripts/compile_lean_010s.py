#!/usr/bin/env python3
"""Compile exactly the local Lean import closure of a target with Lean 4.33.0."""
from pathlib import Path
import os
import re
import subprocess
import sys

BASE = Path('proofs')
DEP = re.compile(r'^\s*import\s+proofs\.([A-Za-z0-9_]+)\s*$', re.M)

def closure(name, visiting=None, done=None, order=None):
    visiting = set() if visiting is None else visiting
    done = set() if done is None else done
    order = [] if order is None else order
    if name in done: return order
    if name in visiting: raise ValueError(f'cyclic local import: {name}')
    path = BASE / (name + '.lean')
    if not path.is_file(): raise ValueError(f'missing import: {path}')
    visiting.add(name)
    for dep in DEP.findall(path.read_text()):
        closure(dep, visiting, done, order)
    visiting.remove(name)
    done.add(name)
    order.append(name)
    return order

def main():
    target = sys.argv[1] if len(sys.argv) > 1 else 'FieldAttachment010s'
    ordered = closure(target)
    print('010s source import closure (' + str(len(ordered)) + '): ' + ', '.join(ordered),flush=True)
    if '--dry-run' in sys.argv: return 0
    Path('build/proofs').mkdir(parents=True, exist_ok=True)
    env = os.environ.copy()
    env['LEAN_PATH'] = 'build'
    log = Path('build/010s-lean.log')
    with log.open('w') as out:
        for name in ordered:
            cmd = ['lean', '--root=.', '-o', f'build/proofs/{name}.olean',
                   f'proofs/{name}.lean']
            run = subprocess.run(cmd, text=True, capture_output=True, env=env)
            body = run.stdout + run.stderr
            out.write(body)
            print('Lean',name,'PASS' if run.returncode == 0 else 'FAIL',flush=True)
            if run.returncode:
                print(body, file=sys.stderr)
                return run.returncode
    print('010s compile PASSED. Log:',log,flush=True)
    return 0

if __name__ == '__main__':
    raise SystemExit(main())
