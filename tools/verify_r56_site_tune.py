#!/usr/bin/env python3
"""R56 candidate checks: recomputation priority, concise author header, navigation, and explicit reader loading."""

from __future__ import annotations

import hashlib
import json
import re
import subprocess
import sys
from html.parser import HTMLParser
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
KERNEL = ROOT / "exact" / "recompute-kernel"
ZIP = ROOT / "downloads" / "Coppalini_Recompute_Kernel_v0_2.zip"
PACKET_SHA256 = "f83943f6399226366cb63cff7494dbd17703d2cde9738415fd97335a90205c60"
CORE_SHA256 = "d8a27ca8e1344ab2e3583b300b505ef1d0536aebfa6df3e7cc415529509daa4b"
LEDGER_SHA256 = "101b97c8c71e5246cbfb91a339d0fca1eadc8e45615c375420dcf37b8ddbdf00"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


class Probe(HTMLParser):
    def __init__(self) -> None:
        super().__init__()
        self.h1 = 0
        self.anchors: list[tuple[str, str]] = []
        self._anchor_stack: list[dict[str, object]] = []

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        if tag == "h1":
            self.h1 += 1
        if tag == "a":
            data = dict(attrs)
            self._anchor_stack.append({"href": data.get("href") or "", "text": []})

    def handle_endtag(self, tag: str) -> None:
        if tag == "a" and self._anchor_stack:
            anchor = self._anchor_stack.pop()
            self.anchors.append((str(anchor["href"]), "".join(anchor["text"]).strip()))

    def handle_data(self, data: str) -> None:
        for anchor in self._anchor_stack:
            text = anchor["text"]
            assert isinstance(text, list)
            text.append(data)


def probe(path: Path) -> Probe:
    result = Probe()
    result.feed(path.read_text(encoding="utf-8"))
    return result


def check_kernel() -> None:
    require(sha256(ZIP) == PACKET_SHA256, "Recompute Kernel packet hash differs")
    runner = subprocess.run([sys.executable, "-I", "run_all.py"], cwd=KERNEL, text=True, capture_output=True)
    require(runner.returncode == 0, runner.stderr or "kernel runner failed")
    require("A10  PASS" in runner.stdout, "kernel lost a core atom")
    require("K01  EXPECTED_FALSE" in runner.stdout and "K02  EXPECTED_FALSE" in runner.stdout, "kernel controls changed")
    require(f"CORE_TABLE_SHA256 {CORE_SHA256}" in runner.stdout, "core output fingerprint differs")
    sync = subprocess.run([sys.executable, "-I", "run_all.py", "--check-ledger", "ledger.md"], cwd=KERNEL, text=True, capture_output=True)
    require(sync.returncode == 0, sync.stderr or "kernel ledger sync failed")
    require(f"LEDGER_SHA256 {LEDGER_SHA256}" in sync.stdout and "LEDGER_SYNC PASS" in sync.stdout, "kernel ledger differs")
    stdlib = subprocess.run([sys.executable, "-S", "run_all.py"], cwd=KERNEL, text=True, capture_output=True)
    require(stdlib.returncode == 0 and "S01  SKIP" in stdlib.stdout, "stdlib-only core run changed")
    print("KERNEL PASS  exact runner, controls, fingerprint, and generated ledger")


def check_verify_surface() -> None:
    page = ROOT / "verify.html"
    text = page.read_text(encoding="utf-8")
    parsed = probe(page)
    require(parsed.h1 == 1, "Verify must retain one H1")
    start = text.index('id="recompute-kernel"')
    audit = text.index('id="audit-register-title"')
    require(start < audit, "Recompute Kernel must precede the Audit Register")
    for marker in (
        "Recompute Kernel v0.2",
        "Ten core exact-integer atoms, two expected-false controls",
        "python3 -I run_all.py",
        CORE_SHA256,
        "/exact/recompute-kernel/",
        "/downloads/Coppalini_Recompute_Kernel_v0_2.zip",
        "/exact/recompute-kernel/run_all.py",
        "/exact/recompute-kernel/manifest.json",
    ):
        require(marker in text, f"Verify lacks kernel binding: {marker}")
    print("VERIFY PASS  Recompute Kernel is the first computation on /verify")


def check_machine_entrypoints() -> None:
    home = (ROOT / "index.html").read_text(encoding="utf-8")
    short = (ROOT / "llms.txt").read_text(encoding="utf-8")
    full = (ROOT / "llms-full.txt").read_text(encoding="utf-8")
    kernel = "https://eulershiddenl.ink/exact/recompute-kernel/"
    require('title="Recompute Kernel manifest" href="exact/recompute-kernel/manifest.json"' in home, "homepage lacks kernel manifest alternate")
    require(home.index('"name": "Recompute Kernel v0.2"') < home.index('"name": "Canonical reader contract"'), "homepage schema does not prioritize kernel")
    require('href="/exact/recompute-kernel/">Recompute Kernel</a>' in home, "homepage canonical reader lacks direct kernel path")
    require(short.index(kernel) < short.index("- [Home](https://eulershiddenl.ink/)"), "llms.txt does not start with kernel")
    require(full.index(kernel) < full.index("- https://eulershiddenl.ink/ — home"), "llms-full route order does not start with kernel")
    print("MACHINE PASS  Recompute Kernel leads the declared machine reading paths")


def check_author() -> None:
    path = ROOT / "anthony-vito-coppa.html"
    text = path.read_text(encoding="utf-8")
    parsed = probe(path)
    require(parsed.h1 == 1, "author page must have one H1")
    required = (
        "Anthony Vito Coppa",
        "Field investigation and authorship",
        "Short version ↓",
        "Suture Field Theorem",
        "Memory Return",
        "Metric Mirror Symmetry",
        "Language Mechanics",
        "LLM Diaper",
        "Mirror_Audit",
        "Zero-Noise Runtime",
        "Clear Onyx laboratory",
        "The Stopping Point of Enough",
        "The Condition of Trust",
        "12 of 12 passing hash-gated cards, 48 of 48 exact checks, and 8 of 8 Suture verifiers",
    )
    for marker in required:
        require(marker in text, f"author page lost bound term: {marker}")
    for removed in ("Author record · field investigation", "Independent software architect · formal-grammar auditor", "Here for the short version?", "Color Meaning Memory Motion"):
        require(removed not in text, f"author header retained removed wind-up: {removed}")
    require(("#short-version", "Short version ↓") in parsed.anchors, "author short-version link is missing")
    print("AUTHOR PASS  name-only header, concise short link, and source-bound long record")


def check_navigation() -> None:
    count = 0
    for path in ROOT.rglob("*.html"):
        text = path.read_text(encoding="utf-8")
        navs = re.findall(r'<nav\b[^>]*\bclass="[^"]*\bprimary-nav\b[^"]*"[^>]*>(.*?)</nav>', text, flags=re.DOTALL)
        for nav in navs:
            labels = re.findall(r'<a\b[^>]*\bhref="/architecture"[^>]*>(.*?)</a>', nav, flags=re.DOTALL)
            require(all(label.strip() == "Constructions" for label in labels), f"{path.relative_to(ROOT)} retains a stale Architecture navigation label")
            count += len(labels)
    require(count >= 1, "no public /architecture navigation was found")
    print(f"NAVIGATION PASS  {count} /architecture links read Constructions")


def check_explicit_reader_loading() -> None:
    script = (ROOT / "architecture-page.js").read_text(encoding="utf-8")
    require(script.count("frame.src = selected.dataset.src;") == 1, "selected Clear Onyx source is not isolated to explicit load")
    require("load.addEventListener('click', loadSelected);" in script, "Clear Onyx explicit load listener is missing")
    require("[data-reader-load]" in script and script.count("frame.src = source;") == 1, "secondary reader explicit load gate is missing")
    for relative in ("architecture/index.html", "architecture.html"):
        text = (ROOT / relative).read_text(encoding="utf-8")
        require("%3Fmodel=" not in text, f"{relative} retains encoded model path")
        for frame in ("architecture-model-frame", "mitosis-reader-frame", "field-matrix-frame"):
            require(f'id="{frame}"' in text and 'src="about:blank"' in text[text.index(f'id="{frame}"') - 180:text.index(f'id="{frame}"') + 280], f"{relative} does not hold {frame} unloaded")
        require('id="architecture-model-load"' in text, f"{relative} lacks Clear Onyx load control")
        require('data-reader-load="#mitosis-reader-frame"' in text, f"{relative} lacks Mitosis load control")
        require('data-reader-load="#field-matrix-frame"' in text, f"{relative} lacks Field Matrix load control")
    syntax = subprocess.run(["node", "--check", "architecture-page.js"], cwd=ROOT, text=True, capture_output=True)
    require(syntax.returncode == 0, syntax.stderr or "architecture script does not parse")
    print("ARCHITECTURE PASS  every embedded reader begins unloaded and has an explicit load action")


def main() -> int:
    check_kernel()
    check_verify_surface()
    check_machine_entrypoints()
    check_author()
    check_navigation()
    check_explicit_reader_loading()
    print("R56 PASS")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (AssertionError, OSError, ValueError, json.JSONDecodeError) as error:
        print(f"R56 FAIL  {error}", file=sys.stderr)
        raise SystemExit(1)
