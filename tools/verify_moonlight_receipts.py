#!/usr/bin/env python3
"""Check the public MOONLIGHT receipt release and its actual browser bundle."""
import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess
import sys

REPO = Path(__file__).resolve().parents[1]
ROOT = REPO / "moonlight/receipts"


def load(name):
    spec = importlib.util.spec_from_file_location(name, ROOT / "sources" / (name + ".py"))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def main():
    release = json.loads((ROOT / "release.json").read_text())
    pins = release["files_sha256"]
    actual = {p.relative_to(ROOT).as_posix() for p in ROOT.rglob("*")
              if p.is_file() and "__pycache__" not in p.parts and p.name != "release.json"}
    assert actual == set(pins), "release membership differs"
    for name, digest in pins.items():
        path = ROOT / name
        assert not path.is_symlink(), name
        assert hashlib.sha256(path.read_bytes()).hexdigest() == digest, name
    for name, digest in release["retained_artifact_pins"].items():
        assert hashlib.sha256((REPO / name).read_bytes()).hexdigest() == digest, name

    bundle = "/* Generated from the exact release sources; isolated CommonJS modules. */\n(function (root) {\n'use strict';\n"
    for key, name in (("harmonizer", "harmonizer.js"), ("relax", "relax_receipt.js")):
        source = (ROOT / "sources" / name).read_text()
        bundle += "const " + key + " = (function () {\nconst module = {exports: {}};\n" + source + "\nreturn Object.freeze(module.exports);\n})();\n"
    bundle += "root.MoonlightReceiptCheckers = Object.freeze({harmonizer, relax});\n})(globalThis);\n"
    assert (ROOT / "receipt-checkers.js").read_text() == bundle, "browser source binding differs"

    cases = []
    for name, module_name in (("harmonizer", "harmonizer"), ("relax", "relax_receipt")):
        module = load(module_name)
        base = json.loads((ROOT / "examples" / (name + ".json")).read_text())
        assert module.check(base) == "OK"
        variants = [(base, "OK")]
        for label, verdict in (("\u0085", "INVALID"), ("\ufeff", "OK"), ("\x1c", "INVALID"), ("reader", "OK")):
            item = json.loads(json.dumps(base))
            item["reader"]["label"] = label
            variants.append((item, verdict))
        difference = json.loads(json.dumps(base))
        field = "y" if name == "harmonizer" else "d"
        difference["recorded"][field] = "1/3"
        difference["delta"] = [{"recorded": dict(difference["recorded"]), "recomputed": dict(difference["recomputed"])}]
        variants.append((difference, "OK_WITH_DELTA"))
        invalid = json.loads(json.dumps(difference))
        invalid["recorded"][field] = "-0/1"
        invalid["delta"][0]["recorded"][field] = "-0/1"
        variants.append((invalid, "INVALID"))
        for value, verdict in variants:
            assert module.check(value) == verdict
            cases.append({"kind": name, "text": json.dumps(value), "expected": verdict})
        lexical = json.dumps(base).replace('"q": 1', '"q": 1.0', 1)
        assert module.check(json.loads(lexical)) == "INVALID"
        cases.append({"kind": name, "text": lexical, "expected": "INVALID"})
    javascript = """require(process.argv[1]);
const cases = JSON.parse(require('fs').readFileSync(0, 'utf8'));
const results = cases.map(c => globalThis.MoonlightReceiptCheckers[c.kind].checkText(c.text));
process.stdout.write(JSON.stringify(results));"""
    run = subprocess.run(["node", "-e", javascript, str(ROOT / "receipt-checkers.js")],
                         input=json.dumps(cases), text=True, capture_output=True, check=True)
    assert json.loads(run.stdout) == [c["expected"] for c in cases], "browser bundle verdict differs"
    adapter = load("reader_ledger_relax")
    assert adapter.check_relax_receipt(json.loads((ROOT / "examples/relax.json").read_text())) == "OK"
    labels = subprocess.run([sys.executable, "-I", str(ROOT / "verification/test_reader_label_parity.py")],
                            capture_output=True, text=True, check=True)
    label_result = json.loads(labels.stdout)
    assert label_result["status"] == "PASS" and label_result["case_count"] == 88
    print(f"PASS: {len(pins)} receipt-release file hashes; retained phase reader and Dome pins; exact browser module binding")
    print(f"PASS: {len(cases)} browser/Python verdict checks; 88 label regressions; reader-ledger callable adapter")
    if "--full" in sys.argv:
        for folder, name in (("sources", "harmonizer.py"), ("sources", "relax_receipt.py"),
                             ("verification", "test_independent.py"), ("verification", "test_relax_receipt.py"),
                             ("verification", "parity.py"), ("verification", "parity_relax.py")):
            subprocess.run([sys.executable, "-I", str(ROOT / folder / name)], check=True)


if __name__ == "__main__":
    main()
