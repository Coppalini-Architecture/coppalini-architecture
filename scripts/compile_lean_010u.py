#!/usr/bin/env python3
"""Compile all transitive 010u Lean imports, including both declared namespaces."""
from pathlib import Path
import os
import re
import subprocess
import sys

ROOT = Path("proofs")
IMPORT = re.compile(r"^\s*import\s+([\w.]+)\s*$", re.MULTILINE)


def path_for(name):
    if name == "Init" or name.startswith("Init."):
        return None
    if name.startswith("proofs."):
        return ROOT / (name[len("proofs."):] + ".lean")
    if name in {"YMDiracGapAudit010q", "YMGapRefusal010r"}:
        return ROOT / (name + ".lean")
    raise ValueError(f"Unexpected dependency: {name}")


def get_closure(target):
    result, visiting, visited = [], set(), set()

    def visit(name):
        if name in visited:
            return
        if name in visiting:
            raise ValueError(f"Import cycle at {name}")
        source = path_for(name)
        if source is None:
            return
        if not source.is_file():
            raise FileNotFoundError(source)
        visiting.add(name)
        for dep in IMPORT.findall(source.read_text()):
            visit(dep)
        visiting.remove(name)
        visited.add(name)
        result.append((name, source))

    visit(target)
    return result


def main():
    target = sys.argv[1] if len(sys.argv) > 1 else "proofs.UniversalClosure010u"
    closure = get_closure(target)
    print("010u import closure:", len(closure), flush=True)
    if "--dry-run" in sys.argv:
        for name, _ in closure:
            print(name)
        return 0
    os.makedirs("build/proofs", exist_ok=True)
    env = os.environ.copy()
    env["LEAN_PATH"] = "build:proofs"
    with open("build/010u-lean.log", "w") as log:
        for name, source in closure:
            olean = Path("build") / (name.replace(".", "/") + ".olean")
            olean.parent.mkdir(parents=True, exist_ok=True)
            command = ["lean", "--root=.", "-o", str(olean), str(source)]
            p = subprocess.run(command, capture_output=True, text=True, env=env)
            log.write(p.stdout + p.stderr)
            log.flush()
            if p.returncode:
                print(f"LEAN FAIL {name}", flush=True)
                print(p.stdout + p.stderr, file=sys.stderr, flush=True)
                return p.returncode
            print(f"LEAN PASS {name}", flush=True)
    print("010u verified transitive source compilation", flush=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
