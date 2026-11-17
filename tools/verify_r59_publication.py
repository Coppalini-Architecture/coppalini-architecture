#!/usr/bin/env python3
"""R59 static publication contract: source provenance, links, route and copy checks.

No external dependencies. Run at the static-site repository root:
    python3 tools/verify_r59_publication.py
"""
from __future__ import annotations
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import urlparse, unquote
import json
import re
import sys

ROOT = Path(".")
CURRENT = ("index.html","notice/index.html","about.html","library.html","verify.html",
           "architecture.html","architecture/index.html","formalism.html",
           "language-mechanics.html",
           "archive/index.html","proofs/minimum-mechanics/index.html")
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
    notice=(ROOT/"notice/index.html").read_text()
    for marker in ("The Notice", "reader-obstruction", "Independent technical examination",
                   "https://github.com/Coppalini-Architecture/coppalini-architecture/issues") + NOTICE_SOURCES:
        if marker not in notice: errors.append("notice missing required route or source: "+marker)
    home=(ROOT/"index.html").read_text()
    if "Computational Gauge Invariance — Coppalini Architecture</title>" in home:
        errors.append("old home title retained")
    if "<iframe" in home: errors.append("homepage should not auto-start a heavy field engine")
    if 'href="/notice/">Read The Notice</a>' not in home:
        errors.append("homepage lacks Notice entrance")
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
    print(f"R59 checked {len(CURRENT)} current pages, {len(HISTORY)} archived pages, "
          f"{checked} local references, {repairs} backward-compatible redirects, "
          f"{len(proof_files)} pinned proof source addresses")
    if errors:
        for e in errors: print("FAIL:",e)
        return 1
    print("R59 PASS: page structure, source preservation, archival links, noindex and proof scopes")
    return 0

if __name__ == "__main__": raise SystemExit(verify())
