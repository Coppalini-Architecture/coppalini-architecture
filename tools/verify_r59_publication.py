#!/usr/bin/env python3
"""Static publication contract: source provenance, links, route and copy checks.

No external dependencies. Run at the static-site repository root:
    python3 tools/verify_r59_publication.py
"""
from __future__ import annotations
import hashlib
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import urlparse, unquote
import json
import re
import sys
import zipfile

ROOT = Path(".")
CURRENT = ("index.html","notice/index.html","about.html","library.html","verify.html",
           "architecture.html","architecture/index.html","formalism.html",
           "language-mechanics.html",
           "archive/index.html","proofs/minimum-mechanics/index.html",
           "formal-correspondence/index.html","papers/symmetric-minimum/index.html")
HISTORY = ("archive/r58-home.html","archive/r58-library.html",
           "archive/r58-verify.html","archive/r58-constructions.html",
           "archive/r58-basis.html")
REQUIRED_PAPERS = (
 "papers/suture-field/05_suture_field.pdf",
 "papers/suture-field/05a_suture_field_dynamics.pdf",
 "papers/the_structure_of_survival_v66.pdf",
 "papers/contact_recognition_continuum.pdf",
 "assets/authors/anthony-vito-coppa-camera-self-portrait.jpeg",
 "papers/four-dual-forms/pdf/01_gravity_light.pdf",
 "models/view/clear-onyx-gauge-laboratory-v0.5.3.html",
)
PROOF_PIN = "b9e939d514a63fb021592f79a316f70cbc70ed8a"
SYMMETRIC_MINIMUM_VERSION = "1.7.16"
SYMMETRIC_MINIMUM_FILES = {
 "papers/symmetric-minimum/symmetric_minimum_v1_7_16.pdf": "74af9c4df7221853594c6290df261950d5294b5e9f88c9be015ab72457ae22c1",
 "papers/symmetric-minimum/symmetric_minimum_v1_7_16.tex": "1b180213be067ebeec79d083ce0776e52e544c5bfc537bf6f099761c3511d965",
 "verification/symmetric-minimum-v1.7.16/check_symmetric_minimum_independent.py": "a6d6464d5026647c0e788b4be638f8d9fab5e156078d403a8931c5d13af27330",
 "verification/symmetric-minimum-v1.7.16/repair_ledger_v1_7_16.pdf": "b9f178c2ccee7c8333543d542ee584fbb2da731225a6e158c80674bb0f0fcef4",
 "verification/symmetric-minimum-v1.7.16/repair_ledger_v1_7_16.tex": "758f4aa49c23e6a653c5fc5a8a6d343b072f30898c3f0d84677d557e0992f481",
}
SYMMETRIC_MINIMUM_MANIFEST = "verification/symmetric-minimum-v1.7.16/SHA256SUMS"
SYMMETRIC_MINIMUM_BUNDLE = "downloads/symmetric-minimum-v1.7.16-source-and-verification.zip"
SYMMETRIC_MINIMUM_BUNDLE_SHA256 = "3960f7a78edc21805f31672ec126d26c9e474702b6b0d641c0ba5aa2a8e5b4e2"
NOTICE_SOURCES = (
 "https://www.who.int/news/item/23-09-2020-managing-the-covid-19-infodemic-promoting-healthy-behaviours-and-mitigating-the-harm-from-misinformation-and-disinformation/",
 "https://www.oecd.org/en/publications/2024/07/oecd-survey-on-drivers-of-trust-in-public-institutions-2024-results_eeb36452.html",
 "https://reutersinstitute.politics.ox.ac.uk/digital-news-report/2026/dnr-executive-summary",
)

class Reader(HTMLParser):
    def __init__(self):
        super().__init__()
        self.links = []
        self.ids = []
        self.h1 = 0
        self.noindex = False
        self.base = None
        self.missing_alt = []
        self.canonical = False
    def handle_starttag(self, tag, attrs):
        a = dict(attrs)
        if tag == "h1": self.h1 += 1
        if tag == "base": self.base = a.get("href")
        if a.get("id"): self.ids.append(a["id"])
        if tag in ("a", "link") and a.get("href"):
            self.links.append(a["href"])
        if tag in ("img", "script", "iframe") and a.get("src"):
            self.links.append(a["src"])
        if tag == "img" and not a.get("alt"):
            self.missing_alt.append(a.get("src", "<unknown>"))
        if tag == "meta" and a.get("name") == "robots" and "noindex" in a.get("content",""):
            self.noindex = True
        if tag == "link" and a.get("rel") == "canonical":
            self.canonical = True

def redirects():
    entries = {}
    for line in (ROOT/"_redirects").read_text().splitlines():
        line = line.strip()
        if not line or line.startswith("#"): continue
        terms = line.split()
        if len(terms) >= 3 and terms[2].startswith(("301","302")):
            if terms[0] in entries: raise AssertionError(f"duplicate redirect: {terms[0]}")
            entries[terms[0]] = terms[1]
    for source, target in entries.items():
        source_norm = source.rstrip("/") or "/"
        target_norm = target.split("#", 1)[0].rstrip("/") or "/"
        if source_norm == target_norm:
            raise AssertionError(f"normalized self-redirect: {source} -> {target}")
    return entries

def location(path):
    path=path.split("#",1)[0].split("?",1)[0]
    if path == "/" or not path: return ROOT/"index.html"
    t = ROOT / path.lstrip("/")
    for q in (t, Path(str(t) + ".html"), t/"index.html"):
        if q.is_file(): return q
    return None

def sha256(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def symmetric_minimum_release(errors):
    manifest_path = ROOT / SYMMETRIC_MINIMUM_MANIFEST
    if not manifest_path.is_file():
        errors.append("Symmetric Minimum release manifest missing")
        return
    manifest = {}
    for line in manifest_path.read_text(encoding="utf-8").splitlines():
        if not line.strip():
            continue
        digest, name = line.split(maxsplit=1)
        manifest[name.strip()] = digest
    for relative, expected in SYMMETRIC_MINIMUM_FILES.items():
        artifact = ROOT / relative
        if not artifact.is_file():
            errors.append("Symmetric Minimum artifact missing: " + relative)
            continue
        if sha256(artifact) != expected:
            errors.append("Symmetric Minimum hash mismatch: " + relative)
        if manifest.get(artifact.name) != expected:
            errors.append("Symmetric Minimum manifest mismatch: " + artifact.name)
    bundle = ROOT / SYMMETRIC_MINIMUM_BUNDLE
    if not bundle.is_file():
        errors.append("Symmetric Minimum source bundle missing")
        return
    if sha256(bundle) != SYMMETRIC_MINIMUM_BUNDLE_SHA256:
        errors.append("Symmetric Minimum source bundle hash mismatch")
    try:
        with zipfile.ZipFile(bundle) as release:
            names = set(release.namelist())
            expected_names = set(manifest) | {"SHA256SUMS"}
            if names != expected_names:
                errors.append("Symmetric Minimum bundle membership mismatch")
            for relative, expected in SYMMETRIC_MINIMUM_FILES.items():
                name = Path(relative).name
                if name in names and hashlib.sha256(release.read(name)).hexdigest() != expected:
                    errors.append("Symmetric Minimum bundle artifact mismatch: " + name)
    except zipfile.BadZipFile:
        errors.append("Symmetric Minimum source bundle is not a readable ZIP")

def verify():
    errors = []
    aliases = redirects()
    checked = 0
    repairs = 0
    for page in CURRENT + HISTORY:
        p = ROOT/page
        if not p.is_file(): errors.append("missing page: "+page); continue
        parser=Reader()
        parser.feed(p.read_text(encoding="utf-8"))
        if parser.h1 != 1: errors.append(f"{page}: expected one h1, found {parser.h1}")
        if len(set(parser.ids)) != len(parser.ids): errors.append(page+": duplicate IDs")
        if not parser.canonical: errors.append(page+": missing canonical")
        if parser.missing_alt: errors.append(f"{page}: missing image alt {parser.missing_alt}")
        if page in HISTORY and not parser.noindex: errors.append(page+": historic page must be noindex")
        if page in CURRENT and page != "archive/index.html" and parser.noindex: errors.append(page+": current page unexpectedly noindex")
        for href in parser.links:
            if href.startswith(("https://","http://","mailto:","tel:","data:","//")): continue
            if href.startswith("#"):
                if href[1:] not in parser.ids: errors.append(f"{page}: missing anchor {href}")
                continue
            url = urlparse(href)
            loc = unquote(url.path)
            if not loc: continue
            if loc.startswith("/"): local=loc
            else:
                prefix = "/" if parser.base == "/" else "/"+str(p.parent).replace(".","").strip("/")+"/"
                local=prefix+loc
            if not location(local):
                if local in aliases and location(aliases[local]): repairs+=1
                else: errors.append(f"{page}: broken local link {href}")
            checked+=1
    for paper in REQUIRED_PAPERS:
        if not (ROOT/paper).is_file(): errors.append("required source missing: "+paper)
    proof = json.loads((ROOT/"research/minimum-mechanics-010u.json").read_text())
    if proof.get("pinned_commit") != PROOF_PIN: errors.append("proof pin mismatch")
    if proof.get("modules") != 45 or len(proof.get("stages",[])) != 21:
        errors.append("proof index count mismatch")
    proof_files = [n for stage in proof["stages"] for n in stage["sources"]]
    if len(proof_files) != 45 or len(set(proof_files)) != 45:
        errors.append("proof source list not 45 unique files")
    correspondence = json.loads((ROOT/"research/formal-correspondence-v0.1.json").read_text())
    if correspondence.get("version") != "0.1" or len(correspondence.get("records", [])) != 7:
        errors.append("formal correspondence ledger count or version mismatch")
    notice=(ROOT/"notice/index.html").read_text()
    for marker in ("The Notice", "reader-obstruction", "Independent technical examination",
                   "https://github.com/Coppalini-Architecture/coppalini-architecture/issues") + NOTICE_SOURCES:
        if marker not in notice: errors.append("notice missing required route or source: "+marker)
    symmetric_minimum_release(errors)
    symmetric_page = (ROOT/"papers/symmetric-minimum/index.html").read_text(encoding="utf-8")
    for marker in (
        "Symmetric Minimum", "reference edition v1.7.16", "140/140 exact checks",
        "33 refusal controls", "hDensityCovariance", "source-and-verification.zip",
        "Bottom line.", "C(8,2) = 28 pair reads", "word → map → condition → source",
        "Einstein", "Maxwell", "Dirac", "Noether", "Gödel",
        "Π<sup>A</sup><sub>μ</sub>", "F<sub>em</sub>",
        "Source-declared field construction", "Conditional Lean theorem",
    ):
        if marker not in symmetric_page:
            errors.append("Symmetric Minimum page missing marker: " + marker)
    for placeholder in (
        "an exact operational closure",
        "a finite root",
        "field-facing",
    ):
        if placeholder in symmetric_page.lower():
            errors.append("Symmetric Minimum page retains untyped placeholder: " + placeholder)
    home=(ROOT/"index.html").read_text()
    if "Computational Gauge Invariance — Coppalini Architecture</title>" in home:
        errors.append("old home title retained")
    if "<iframe" in home: errors.append("homepage should not auto-start a heavy field engine")
    if 'href="/formal-correspondence/">Map to the literature</a>' not in home:
        errors.append("homepage lacks map-to-literature entrance")
    if 'class="notice-feature"' in home:
        errors.append("homepage retains Notice feature")
    if "Field Investigations</title>" in home:
        errors.append("homepage retains obsolete Field Investigations title")
    correspondence_page = (ROOT/"formal-correspondence/index.html").read_text()
    for marker in ("Formal Correspondence Ledger", "Public form", "Minimum Mechanics", "Suture"):
        if marker not in correspondence_page:
            errors.append("formal correspondence page missing marker: "+marker)
    for page in ROOT.rglob("*.html"):
        relative = page.relative_to(ROOT).as_posix()
        if relative == "404.html" or relative.startswith("archive/"):
            continue
        text = page.read_text(encoding="utf-8")
        if '<nav class="primary-nav"' in text and 'href="/notice/"' not in text:
            errors.append(relative+": current primary navigation lacks Notice route")
    for page in CURRENT:
        if page.startswith("archive/"): continue
        if page=="proofs/minimum-mechanics/index.html": continue
        if "proofs/minimum-mechanics" not in (ROOT/page).read_text():
            errors.append(page+": missing proof atlas route")
    for page in ("archive/r58-home.html","archive/r58-library.html","archive/r58-verify.html",
                 "archive/r58-constructions.html","archive/r58-basis.html"):
        if "<base href=\"/\">" not in (ROOT/page).read_text():
            errors.append(page+": missing archival base correction")
    print(f"Static candidate checked {len(CURRENT)} current pages, {len(HISTORY)} archived pages, "
          f"{checked} local references, {repairs} backward-compatible redirects, "
          f"{len(proof_files)} pinned proof source addresses, and Symmetric Minimum v{SYMMETRIC_MINIMUM_VERSION}")
    if errors:
        for e in errors: print("FAIL:",e)
        return 1
    print("PASS: page structure, source preservation, archival links, claim routes, and Symmetric Minimum release hashes")
    return 0

if __name__ == "__main__": raise SystemExit(verify())
