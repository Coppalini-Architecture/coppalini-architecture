#!/usr/bin/env python3
"""R55 author-record and Recompute Kernel binding checks."""

from __future__ import annotations

import hashlib
import json
import subprocess
import sys
import xml.etree.ElementTree as ET
from html.parser import HTMLParser
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
KERNEL = ROOT / "exact" / "recompute-kernel"
ZIP = ROOT / "downloads" / "Coppalini_Recompute_Kernel_v0_2.zip"
EXPECTED_PACKET = "f83943f6399226366cb63cff7494dbd17703d2cde9738415fd97335a90205c60"
EXPECTED_CORE = "d8a27ca8e1344ab2e3583b300b505ef1d0536aebfa6df3e7cc415529509daa4b"
EXPECTED_LEDGER = "101b97c8c71e5246cbfb91a339d0fca1eadc8e45615c375420dcf37b8ddbdf00"
EXPECTED_OG_IMAGE = "ce9e32697bad38eda1eee909fb466f01ee83e3f0aa0e6360ff7ef5bcd34c87ca"
OG_IMAGE_PATH = "https://eulershiddenl.ink/assets/social/root-matrices-link-card.jpg"


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


class PageProbe(HTMLParser):
    def __init__(self) -> None:
        super().__init__()
        self.h1 = 0
        self.images: list[dict[str, str]] = []
        self.links: list[str] = []
        self.anchors: list[tuple[str, str]] = []
        self.anchor_stack: list[dict[str, object]] = []

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        data = {key: value or "" for key, value in attrs}
        if tag == "h1":
            self.h1 += 1
        elif tag == "img":
            self.images.append(data)
        elif tag == "a":
            self.links.append(data.get("href", ""))
            self.anchor_stack.append({"href": data.get("href", ""), "text": []})

    def handle_endtag(self, tag: str) -> None:
        if tag == "a" and self.anchor_stack:
            item = self.anchor_stack.pop()
            self.anchors.append((str(item["href"]), "".join(item["text"]).strip()))

    def handle_data(self, data: str) -> None:
        for item in self.anchor_stack:
            text = item["text"]
            assert isinstance(text, list)
            text.append(data)


def check_author() -> None:
    path = ROOT / "anthony-vito-coppa.html"
    text = path.read_text(encoding="utf-8")
    probe = PageProbe()
    probe.feed(text)
    require(probe.h1 == 1, "author page must have one H1")
    required = (
        "Anthony Vito Coppa",
        "Independent software architect · formal-grammar auditor",
        "Field investigation and authorship",
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
        "Here for the short version?",
        "Recompute Kernel v0.2",
    )
    for phrase in required:
        require(phrase in text, f"author page is missing protected term: {phrase}")
    require("Color Meaning Memory Motion" not in text, "removed placeholder name returned")
    require("/assets/authors/anthony-vito-coppa-fieldwork.jpeg" in text, "portrait path is not bound")
    require((ROOT / "assets" / "authors" / "anthony-vito-coppa-fieldwork.jpeg").is_file(), "portrait file is missing")
    required_links = {
        "/library",
        "/exact/",
        "/papers/suture-field/05_suture_field.pdf",
        "/verify",
        "/exact/#recompute-kernel",
    }
    require(required_links <= set(probe.links), "author page link map is incomplete")
    protected_links = {
        ("/library", "Coppalini Architecture"),
        ("/exact/", "machine-checkable verifications"),
        ("/architecture", "machine-checked Lean 4 theorem packages"),
        ("/exact/", "Fibonacci transport Q, symplectic rotation Ω, and their commutator G = [Q, Ω]"),
        ("/research/four-dual-forms-v0.3.json", "complete 28-seam K₈ relation ledger"),
        ("/papers/memory-return-007-v0.2.pdf", "Memory Return"),
        ("/papers/suture-field/05_suture_field.pdf", "Einstein–Maxwell field constructions coupling gravity and electromagnetism"),
        ("/papers/suture-field/05_suture_field.pdf", "Suture Field Theorem"),
        ("/models/view/clear-onyx-gauge-laboratory-v0.5.3", "gauge and lattice verifications of the electroweak Higgs mass Hessian, relativistic spinor, and SU(3) QCD transport models"),
        ("/architecture", "correlated Hylleraas helium and atomic spectral dynamics"),
        ("/papers/the-3-body-mirror.pdf", "quartic resonant-obstruction proof for the collinear three-body problem"),
        ("/papers/metric-mirror-symmetry-riemanns-i-machine-2026-09-09.pdf", "Metric Mirror Symmetry"),
        ("/papers/language-mechanics-000-v0.2.1.pdf", "Language Mechanics"),
        ("/downloads/llm-diaper-1.2.0.zip", "LLM Diaper"),
        ("/architecture", "Mirror_Audit"),
        ("/code/zero-noise-runtime-v03.zip", "Zero-Noise Runtime"),
        ("/models/view/clear-onyx-gauge-laboratory-v0.5.3", "Clear Onyx laboratory"),
        ("/architecture", "C++20, Python, and Lean 4 tools"),
        ("/papers/ca_01_tool_and_technique_the_condition_of_enough_final.pdf", "The Stopping Point of Enough"),
        ("/papers/the-condition-of-trust.pdf", "The Condition of Trust"),
        ("/verify", "Verification page"),
        ("/exact/#recompute-kernel", "Recompute Kernel v0.2"),
    }
    require(protected_links <= set(probe.anchors), "one-to-one author source map is incomplete")
    print("AUTHOR PASS  long overview, protected terms, portrait, short byline, and link map")


def check_kernel_files() -> None:
    require(sha256(ZIP) == EXPECTED_PACKET, "published Recompute Kernel packet hash differs")
    required = ("run_all.py", "ledger.md", "manifest.json", "SHA256SUMS", "README.md", "index.html")
    for name in required:
        require((KERNEL / name).is_file(), f"missing kernel public file: {name}")
    sums = {}
    for line in (KERNEL / "SHA256SUMS").read_text(encoding="utf-8").splitlines():
        digest, raw_name = line.split(maxsplit=1)
        sums[raw_name.removeprefix("*")] = digest
    for name in ("README.md", "run_all.py", "ledger.md", "manifest.json"):
        require(sums[name] == sha256(KERNEL / name), f"kernel hash mismatch: {name}")
    proc = subprocess.run([sys.executable, "-I", "run_all.py"], cwd=KERNEL, text=True, capture_output=True)
    require(proc.returncode == 0, proc.stderr or "kernel runner failed")
    ledger_proc = subprocess.run([sys.executable, "-I", "run_all.py", "--check-ledger", "ledger.md"], cwd=KERNEL, text=True, capture_output=True)
    require(ledger_proc.returncode == 0, ledger_proc.stderr or "ledger runner failed")
    output = proc.stdout + ledger_proc.stdout
    require("A10  PASS" in output and "K01  EXPECTED_FALSE" in output and "K02  EXPECTED_FALSE" in output, "kernel output lost atom or control")
    require(f"CORE_TABLE_SHA256 {EXPECTED_CORE}" in output, "core fingerprint changed")
    require(f"LEDGER_SHA256 {EXPECTED_LEDGER}" in output and "LEDGER_SYNC PASS" in output, "ledger check changed")
    core_only = subprocess.run([sys.executable, "-S", "run_all.py"], cwd=KERNEL, text=True, capture_output=True)
    require(core_only.returncode == 0, core_only.stderr or "stdlib-only runner failed")
    require("S01  SKIP" in core_only.stdout and f"CORE_TABLE_SHA256 {EXPECTED_CORE}" in core_only.stdout, "core fingerprint differs without SymPy")
    manifest = json.loads((KERNEL / "manifest.json").read_text(encoding="utf-8"))
    require(manifest["core_table_sha256"] == EXPECTED_CORE, "manifest core fingerprint changed")
    require(manifest["ledger_sha256"] == EXPECTED_LEDGER, "manifest ledger fingerprint changed")
    require(len(manifest["atoms"]) == 13, "manifest atom count changed")
    print("KERNEL PASS  packet hash, raw files, runner, controls, ledger sync, and manifest")


def check_public_records() -> None:
    home = (ROOT / "index.html").read_text(encoding="utf-8")
    exact = (ROOT / "exact" / "index.html").read_text(encoding="utf-8")
    record = (KERNEL / "index.html").read_text(encoding="utf-8")
    registry = json.loads((ROOT / "exact" / "read-registry.json").read_text(encoding="utf-8"))
    require("id=\"recompute-kernel\"" in exact, "Exact Reader lacks Recompute Kernel surface")
    require("/downloads/Coppalini_Recompute_Kernel_v0_2.zip" in exact, "Exact Reader lacks packet link")
    require("Recompute Kernel v0.2" in record and EXPECTED_PACKET in record, "record page lacks bound packet")
    kernel_records = [item for item in registry["records"] if item["id"] == "RK-v0.2"]
    require(len(kernel_records) == 1, "Exact Reader registry lacks RK-v0.2")
    require(kernel_records[0]["output"]["core_table_sha256"] == EXPECTED_CORE, "registry fingerprint changed")
    require(registry["schema_version"] == "1.2.0", "Exact Reader registry version was not advanced")
    index = json.loads((ROOT / "research" / "registry-index.json").read_text(encoding="utf-8"))
    reader = next(item for item in index["registries"] if item["id"] == "exact-reader")
    require(reader["record_count"] == 4 and "RK-v0.2" in reader["record_ids"], "registry index was not advanced")
    sitemap = ET.parse(ROOT / "sitemap.xml")
    namespace = {"sm": "http://www.sitemaps.org/schemas/sitemap/0.9"}
    locs = [node.text for node in sitemap.findall("sm:url/sm:loc", namespace)]
    require("https://eulershiddenl.ink/exact/recompute-kernel/" in locs, "sitemap lacks Recompute Kernel")
    for name in ("llms.txt", "llms-full.txt"):
        require("Recompute Kernel v0.2" in (ROOT / name).read_text(encoding="utf-8"), f"{name} lacks Recompute Kernel")
    og_image = ROOT / "assets" / "social" / "root-matrices-link-card.jpg"
    require(og_image.is_file(), "social thumbnail is missing")
    require(sha256(og_image) == EXPECTED_OG_IMAGE, "social thumbnail hash differs")
    for metadata in (
        f'<meta property="og:image" content="{OG_IMAGE_PATH}">',
        '<meta property="og:image:width" content="1200">',
        '<meta property="og:image:height" content="630">',
        f'<meta name="twitter:image" content="{OG_IMAGE_PATH}">',
    ):
        require(metadata in home, f"homepage social preview is missing: {metadata}")
    print("PUBLIC PASS  Exact Reader, registry index, sitemap, machine maps, and root-matrix social preview")


def main() -> int:
    check_author()
    check_kernel_files()
    check_public_records()
    print("R55 PASS")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (AssertionError, KeyError, OSError, ValueError, json.JSONDecodeError, ET.ParseError) as error:
        print(f"R55 FAIL  {error}", file=sys.stderr)
        raise SystemExit(1)
