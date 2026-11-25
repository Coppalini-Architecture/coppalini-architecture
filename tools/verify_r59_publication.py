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
import subprocess
import sys
import zipfile

ROOT = Path(".")
CURRENT = ("index.html","notice/index.html","about.html","library.html","publication-records.html","verify.html",
           "architecture.html","architecture/index.html","formalism.html",
           "language-mechanics.html","external-formalization/index.html",
           "archive/index.html","proofs/minimum-mechanics/index.html",
           "proofs/smooth-completion/index.html","formal-correspondence/index.html","moonlight/index.html",
           "moonlight/manual/index.html","moonlight/dome/index.html","moonlight/receipts/index.html",
           "papers/symmetric-minimum/index.html","development/index.html")
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
 "models/view/clear-onyx-gauge-laboratory-v0.5.4.html",
 "papers/eternity-time-mirror-zeta.pdf",
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
CIVIC_NOTICE_MARKERS = (
 "Notice:",
 "We operate inside a readable condition called reality.",
    "Public declaration / local language rule",
    "In this notice, each term is used as a declared reference.",
 "A frame admits a reference. A reference admits a center coordinate.",
 "1 + 1 = 2",
 "Keep 4. Turn 2. Fold 1. Return 0.",
)
# Homepage contract: lead with the source field map, then preserve each proof
# record and named boundary at its own carrier and conditions.
HOMEPAGE_RESULT_SCOPE_MARKERS = (
 "Coppalini Architecture | Gravity &amp; Electromagnetism Field Map",
 "Gravity and electromagnetism from one geometric field.",
 "Π → (g,F<sub>sol</sub>) → F<sub>em</sub>",
 "On the Maxwell regular branch",
 "rank D𝒮<sub>Π</sub>=16",
 "b(g,F)&lt;|χ|",
 "Local Einstein–Maxwell reduction",
 "140 finite identities and 33 negative controls",
 "real <code>C∞</code> Einstein–Maxwell field construction on compact boundaryless <code>𝕋³</code>",
 "Given a <code>SmoothCompletion</code> with those seven named roles, Lean proves the six canonical brackets.",
 "original <code>Int</code>-valued <code>SmoothCompletion</code> constructor",
 "P14’s finite-root-to-variational/Hamiltonian adapter",
 "selected spin-two TT readout remain open",
 'href="/papers/symmetric-minimum/#status-lineage">canonical seven-status key</a>',
 "Proof in order of force",
    "Read the result first; then follow its named source, carrier, condition, and check.",
)
SMOOTH_COMPLETION_RECORD = "research/smooth-completion-cinf-t3-v0.1.json"
SMOOTH_COMPLETION_PREMISES = (
 "hDensityCovariance",
 "gaugeHamiltonianVariationZero",
 "gaussSmearingCovariance",
 "boundaryH",
 "sourceNormalGradient",
 "sourceMomentumAddress",
 "boundaryNormal",
)
ROOT28_MANIFEST = "research/metric-minimum-root28-v0.1.json"
MOONLIGHT_ARTIFACT = "models/view/moonlight-phase-reader-v0.8.4.html"
MOONLIGHT_RECORD = "verification/receipts/MOONLIGHT-MC-001-P.public-recheck.json"
MOONLIGHT_MANUAL = "moonlight/manual/index.html"
MOONLIGHT_DOME = "moonlight/dome/index.html"
MOONLIGHT_LAMBDA_SCHEMA = "verification/receipts/MOONLIGHT-LAMBDA-001.schema.json"
MOONLIGHT_SHA256 = "70adec4bc28bf55590920cd3f402d469bbc592e2dbadd2409e69e6ea2ca080cb"
MOONLIGHT_LEGACY_ARTIFACT = "/models/view/moonlight-phase-reader-v0.8.3.html"

ROOT28_ARTIFACTS = (
 "research/metric-minimum-root28-v0.1.md",
 "proofs/Root28Reader.lean",
 "verification/root28/check_root28.py",
 "verification/root28/ROOT28_RECEIPT_v0.1.md",
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

def smooth_completion_receipt(errors):
    path = ROOT / SMOOTH_COMPLETION_RECORD
    if not path.is_file():
        errors.append("smooth-completion source record missing")
        return
    try:
        record = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        errors.append("smooth-completion source record is invalid JSON: " + str(exc))
        return
    if record.get("status") != "source-documented classical mathematics":
        errors.append("smooth-completion record status mismatch")
    if record.get("reader_handles", {}).get("sequence") != ["Φ", "Ψ", "i", "g", "e", "θ", "Λ"]:
        errors.append("smooth-completion reader handle sequence mismatch")
    premises = record.get("premises", [])
    if [entry.get("name") for entry in premises] != list(SMOOTH_COMPLETION_PREMISES):
        errors.append("smooth-completion seven-premise order mismatch")
    for entry in premises:
        if not all(entry.get(field) for field in ("classical_counterpart", "condition", "source")):
            errors.append("smooth-completion premise lacks counterpart, condition, or source: " + entry.get("name", "<unnamed>"))
    if len(record.get("six_secondary_brackets", [])) != 6:
        errors.append("smooth-completion bracket count mismatch")
    namespace = record.get("presentation_namespace", {})
    for key in ("gauss_generator", "finite_root_boundary"):
        if key not in namespace:
            errors.append("smooth-completion namespace record missing: " + key)
    lean = record.get("lean_boundary", {})
    if "Conditional Lean theorem" not in lean.get("theorem_status", "") or "open" not in lean.get("open", "").lower():
        errors.append("smooth-completion Lean boundary missing")
    if "P14" not in record.get("separate_open_obligation", ""):
        errors.append("smooth-completion P14 boundary missing")

def root28_reader_candidate(errors):
    manifest_path = ROOT / ROOT28_MANIFEST
    if not manifest_path.is_file():
        errors.append("Root28 manifest missing")
        return
    for relative in ROOT28_ARTIFACTS:
        if not (ROOT / relative).is_file():
            errors.append("Root28 artifact missing: " + relative)
    try:
        record = json.loads(manifest_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        errors.append("Root28 manifest is invalid JSON: " + str(exc))
        return
    if record.get("schema") != "CoppaliniArchitecture.Root28/v0.1":
        errors.append("Root28 schema mismatch")
    if record.get("status") != "LOCAL_CANDIDATE":
        errors.append("Root28 candidate status mismatch")
    scan = record.get("scan", {})
    if scan.get("rows") != ["Q", "J_rot", "Omega_root", "G_root", "H", "L_s", "F_esc_Lambda_ax"]:
        errors.append("Root28 row sequence mismatch")
    if scan.get("slots") != ["carrier", "relation", "read", "boundary"]:
        errors.append("Root28 slot sequence mismatch")
    if scan.get("row_count") != 7 or scan.get("slot_count") != 4 or len(record.get("cards", [])) != 28:
        errors.append("Root28 7x4 card count mismatch")
    projection = record.get("display_projection", {})
    if projection.get("id") != "pi_color" or projection.get("status") != "DECLARED_DISPLAY":
        errors.append("Root28 display projection status mismatch")
    if len(projection.get("codomain", [])) != 7 or len(set(projection.get("codomain", []))) != 7:
        errors.append("Root28 display projection cardinality mismatch")
    boundaries = "\n".join(record.get("global_boundaries", []))
    for marker in ("SmoothCompletion", "P14", "zeta", "RH", "external proof"):
        if marker.lower() not in boundaries.lower():
            errors.append("Root28 boundary missing: " + marker)
    page = (ROOT / "papers/symmetric-minimum/index.html").read_text(encoding="utf-8")
    for marker in (
        'id="root28-reader"',
        "Root28 is a local candidate",
        "28/28 reader obligations; 8/8 refusal controls.",
        "The seven-colour order is a declared display legend",
        "original <code>Int</code>-valued interface and P14 remain open",
        "/research/metric-minimum-root28-v0.1.md",
        "/research/metric-minimum-root28-v0.1.json",
        "/proofs/Root28Reader.lean",
        "/verification/root28/check_root28.py",
        "/verification/root28/ROOT28_RECEIPT_v0.1.md",
    ):
        if marker not in page:
            errors.append("Symmetric Minimum page missing Root28 marker: " + marker)

def external_reader_release_boundary(errors):
    page = (ROOT / "external-formalization/index.html").read_text(encoding="utf-8")
    required = (
        "EXTERNALLY CERTIFIED",
        "Lean and Mathlib communities · 21 November 2026",
        "40e56bab026552e089d7afcfeff08d2defb9c005",
        "Not performed by this site",
        "LOCAL_REPLAYED · self-attested",
        "semantic adapter schema is not declared",
        "This page does not publish, link, or distribute the EARR-001 packet.",
    )
    for marker in required:
        if marker not in page:
            errors.append("external reader missing release-boundary marker: " + marker)
    packet_paths = (
        "/verification/external-anchor-receipt/",
        "/proofs/ExternalAnchorReceipt.lean",
        "EXTERNAL_ANCHOR_SHA256SUMS",
        "EARR-001_Review_Packet",
    )
    for marker in packet_paths:
        if marker in page:
            errors.append("external reader publishes or links a gated EARR packet path: " + marker)
    semantic_adapter_markers = (
        "A_clock_to_occurrence",
        "A_clock_to_measurement",
        "A_CA_to_zeta",
        "A_zeta_to_RH",
        "OPEN adapter",
    )
    for marker in semantic_adapter_markers:
        if marker in page:
            errors.append("external reader promotes a retained adapter name into page semantics: " + marker)
    for stale in ("SOURCE_REPORTED", "PENDING_REPLAY"):
        if stale in page:
            errors.append("external reader retains stale global external status: " + stale)
    for name in ("llms.txt", "llms-full.txt"):
        text = (ROOT / name).read_text(encoding="utf-8")
        if "does not publish, link, or distribute the EARR-001 packet" not in text:
            errors.append(name + ": missing packet-withheld declaration")
        for marker in packet_paths:
            if marker in text:
                errors.append(name + ": exposes a gated EARR packet path: " + marker)

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
        if page == "moonlight/receipts/index.html" and not parser.noindex:
            errors.append(page+": draft receipt page must be noindex")
        if page in CURRENT and page not in ("archive/index.html", "moonlight/receipts/index.html", "development/index.html") and parser.noindex:
            errors.append(page+": current page unexpectedly noindex")
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
    moonlight = ROOT / MOONLIGHT_ARTIFACT
    if not moonlight.is_file():
        errors.append("MOONLIGHT v0.8.4 artifact missing")
    elif sha256(moonlight) != MOONLIGHT_SHA256:
        errors.append("MOONLIGHT v0.8.4 artifact hash mismatch")
    moonlight_record = ROOT / MOONLIGHT_RECORD
    if not moonlight_record.is_file():
        errors.append("MOONLIGHT MC-001-P record missing")
    else:
        try:
            record = json.loads(moonlight_record.read_text(encoding="utf-8"))
        except json.JSONDecodeError as exc:
            errors.append("MOONLIGHT MC-001-P record is invalid JSON: " + str(exc))
        else:
            if record.get("carrier", {}).get("sha256") != MOONLIGHT_SHA256:
                errors.append("MOONLIGHT MC-001-P carrier hash mismatch")
    lambda_schema = ROOT / MOONLIGHT_LAMBDA_SCHEMA
    if not lambda_schema.is_file():
        errors.append("MOONLIGHT Lambda schema missing")
    else:
        try:
            lambda_record = json.loads(lambda_schema.read_text(encoding="utf-8"))
        except json.JSONDecodeError as exc:
            errors.append("MOONLIGHT Lambda schema is invalid JSON: " + str(exc))
        else:
            if lambda_record.get("sources", {}).get("moonlight_reader", {}).get("sha256") != MOONLIGHT_SHA256:
                errors.append("MOONLIGHT Lambda schema carrier hash mismatch")
            if lambda_record.get("axial_lift", {}).get("period_T") != "2 log Phi":
                errors.append("MOONLIGHT Lambda schema period mismatch")
            dome_adapter = lambda_record.get("display_adapter", {}).get("iris_dome", {})
            if dome_adapter.get("path") != "/moonlight/dome/":
                errors.append("MOONLIGHT Iris Dome adapter path mismatch")
            if dome_adapter.get("law") != "a mod 4 = q; a mod 137 = s":
                errors.append("MOONLIGHT Iris Dome adapter law mismatch")
    moonlight_page = (ROOT/"moonlight/index.html").read_text(encoding="utf-8")
    for marker in (
        "MOONLIGHT · Minimum Wheel v0.8.4",
        MOONLIGHT_SHA256,
        "/models/view/moonlight-phase-reader-v0.8.4.html",
        "/verification/receipts/MOONLIGHT-MC-001-P.public-recheck.json",
        "no clock, time-standard, or UTC claim",
        "Gate and Survival are inherited interfaces",
        "evaluators remain uninstantiated",
    ):
        if marker not in moonlight_page:
            errors.append("MOONLIGHT public page missing marker: " + marker)
    for public_ref in ("moonlight/index.html", "library.html", "llms.txt", "llms-full.txt"):
        public_text = (ROOT / public_ref).read_text(encoding="utf-8")
        if MOONLIGHT_LEGACY_ARTIFACT in public_text:
            errors.append(public_ref + ": retains legacy MOONLIGHT reader path")
    manual = (ROOT / MOONLIGHT_MANUAL).read_text(encoding="utf-8")
    for marker in (
        "MOONLIGHT / user manual",
        "Four phase · 137 iris · 548 address",
        "Λ = (k + u)T",
        "Riemann’s i machine",
        "D4 retained",
    ):
        if marker not in manual:
            errors.append("MOONLIGHT manual missing marker: " + marker)
    dome = (ROOT / MOONLIGHT_DOME).read_text(encoding="utf-8")
    for marker in (
        "Iris Dome · 548 Address Surface",
        "four phase bands, 137 sectors per band, 548 visible addresses",
        "const sectors=137",
        "const addressFor=(phase,iris)=>iris+sectors*mod(phase-iris,4)",
        "Rendering this address never updates the MOONLIGHT phase mirror.",
    ):
        if marker not in dome:
            errors.append("MOONLIGHT dome missing marker: " + marker)
    receipt_page = (ROOT / "moonlight/receipts/index.html").read_text(encoding="utf-8")
    for marker in (
        "MOONLIGHT Draft Receipt Verifier — Verification Pending",
        "DRAFT, local",
        "not released, pinned, or gated",
        "not a closed receipt endpoint",
        "Known admitted-input boundary cases remain under correction.",
        "Verification status and known gaps",
    ):
        if marker not in receipt_page:
            errors.append("MOONLIGHT draft receipt page missing status marker: " + marker)
    try:
        receipt_manifest = json.loads((ROOT / "moonlight/receipts/release.json").read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        errors.append("MOONLIGHT draft receipt manifest is invalid JSON: " + str(exc))
    else:
        if receipt_manifest.get("promotion_status") != "DRAFT_LOCAL_VERIFICATION_PENDING":
            errors.append("MOONLIGHT draft receipt promotion status mismatch")
        if len(receipt_manifest.get("known_implementation_gaps", [])) != 4:
            errors.append("MOONLIGHT draft receipt gap ledger mismatch")
    sitemap = (ROOT / "sitemap.xml").read_text(encoding="utf-8")
    if "/moonlight/receipts/" in sitemap:
        errors.append("MOONLIGHT draft receipt route must not be sitemap-indexed")
    if "/development/" in sitemap:
        errors.append("development route must not be sitemap-indexed")
    proof = json.loads((ROOT/"research/minimum-mechanics-010u.json").read_text())
    if proof.get("pinned_commit") != PROOF_PIN: errors.append("proof pin mismatch")
    if proof.get("modules") != 45 or len(proof.get("stages",[])) != 21:
        errors.append("proof index count mismatch")
    proof_files = [n for stage in proof["stages"] for n in stage["sources"]]
    if len(proof_files) != 45 or len(set(proof_files)) != 45:
        errors.append("proof source list not 45 unique files")
    correspondence_v1 = json.loads((ROOT/"research/formal-correspondence-v0.1.json").read_text())
    correspondence = json.loads((ROOT/"research/formal-correspondence-v0.2.json").read_text())
    if correspondence_v1.get("version") != "0.1" or len(correspondence_v1.get("records", [])) != 7:
        errors.append("formal correspondence v0.1 preservation mismatch")
    if correspondence.get("version") != "0.2" or len(correspondence.get("records", [])) != 7:
        errors.append("formal correspondence v0.2 count or version mismatch")
    namespace = correspondence.get("namespace_ledger", {})
    for key in ("finite_root", "finite_axial_coordinate", "centered_rail_coordinate", "einstein_maxwell_field_record", "jurisdiction"):
        if key not in namespace:
            errors.append("formal correspondence v0.2 missing namespace record: " + key)
    notice=(ROOT/"notice/index.html").read_text()
    for marker in CIVIC_NOTICE_MARKERS:
        if marker not in notice: errors.append("notice missing required marker: "+marker)
    for marker in ("LOCAL_CANDIDATE", "SOURCE_REPORTED", "PENDING_REPLAY", "External Formalization Reader", "EARR-001_Review_Packet", "EXTERNAL_ANCHOR_SHA256SUMS", "ExternalAnchorReceipt.lean"):
        if marker in notice:
            errors.append("notice carries a removed internal-record marker: " + marker)
    landing=(ROOT/"index.html").read_text()
    for marker in HOMEPAGE_RESULT_SCOPE_MARKERS:
        if marker not in landing: errors.append("landing page missing result/scope marker: "+marker)
    if "It is not a Riemann-hypothesis proof." in landing:
        errors.append("landing page retains withdrawn Riemann-hypothesis disclaimer")
    if "Read the relation before extending the claim." in landing:
        errors.append("landing page retains withdrawn method-first closure heading")
    for stale in (
        "Source-Indexed Proof Ledger",
        "Exact finite records, conditional theorems, stated field conditions, and open adapters.",
        "Four homepage status groups; no transfer across them.",
    ):
        if stale in landing:
            errors.append("landing page retains superseded process-first marker: "+stale)
    symmetric_minimum_release(errors)
    smooth_completion_receipt(errors)
    root28_reader_candidate(errors)
    external_reader_release_boundary(errors)
    symmetric_page = (ROOT/"papers/symmetric-minimum/index.html").read_text(encoding="utf-8")
    for marker in (
        "Symmetric Minimum", "reference edition v1.7.16", "140/140 exact checks",
        "33 negative controls", "hDensityCovariance", "source-and-verification.zip",
        "Bottom line.", "C(8,2) = 28 pair reads", "word → map → condition → source",
        "Einstein", "Maxwell", "Dirac", "Noether", "Gödel",
        "Π<sup>A</sup><sub>μ</sub>", "F<sub>em</sub>",
        "Coframe field construction", "Conditional Lean theorem",
        "Classical field closure.", "Open in Lean.",
        "/proofs/smooth-completion/", "Public reader handles (site display)",
        "Ψ · Θ · θ · π · e · Φ · Λ", "id=\"status-lineage\"", "id=\"open-ledger\"",
        "G<sub>root</sub>", "G<sub>EM</sub>", "λ<sub>root</sub>",
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
    if "Mathematics and physics papers by Anthony Vito Coppa" in home:
        errors.append("homepage retains withdrawn author-credit copy")
    for marker in (
        'href="/papers/symmetric-minimum/">Field result and source edition.</a>',
        'href="/proofs/smooth-completion/">Classical Einstein–Maxwell record.</a>',
        'href="/proofs/minimum-mechanics/#field-mechanics">Canonical theorem and premises.</a>',
        'href="/verify#scope">Finite checks and verification record.</a>',
        'href="/formal-correspondence/">External correspondence ledger.</a>',
        'href="/papers/suture-field/05a_suture_field_dynamics.pdf">Read the regular-branch dynamics</a>',
        'href="/papers/symmetric-minimum/#open-ledger">Read the remaining source ledger</a>',
    ):
        if marker not in home:
            errors.append("homepage missing result/proof entrance: " + marker)
    if 'class="notice-feature"' in home:
        errors.append("homepage retains Notice feature")
    if "Field Investigations</title>" in home:
        errors.append("homepage retains obsolete Field Investigations title")
    for architecture_file in ("architecture.html", "architecture/index.html"):
        architecture = (ROOT/architecture_file).read_text(encoding="utf-8")
        for marker in (
            'class="architecture-lab-landing"',
            'clear-onyx-gauge-laboratory-v0.5.7?embed=1',
            "One 2D signal aperture. Many declared physical models.",
            "The Signal Frame names exactly what every visible quantity means for the selected model.",
        ):
            if marker not in architecture:
                errors.append(architecture_file + ": missing lab-first marker: " + marker)
    lab = (ROOT/"models/view/clear-onyx-gauge-laboratory-v0.5.7.html").read_text(encoding="utf-8")
    for marker in ("body.lab-embed", "location.search).has('embed')", "requestAnimationFrame(frame)", "ONE VISUAL LANGUAGE · MANY EQUATIONS", "signal-carrier", "rgb-basis", "modeEquationResidual", "exact harmonic step"):
        if marker not in lab:
            errors.append("Gauge & Matter Laboratory missing embed or autostart marker: " + marker)
    source_zip = ROOT / "downloads/clear-onyx-gauge-laboratory-v0.5.7-source.zip"
    if not source_zip.is_file():
        errors.append("Gauge & Matter v0.5.7 source package missing")
    else:
        try:
            with zipfile.ZipFile(source_zip) as package:
                required = {
                    "clear-onyx-gauge-laboratory-v0.5.7/clear-onyx-gauge-laboratory-v0.5.7.html",
                    "clear-onyx-gauge-laboratory-v0.5.7/source-manifest.json",
                    "clear-onyx-gauge-laboratory-v0.5.7/AUDIT.md",
                    "clear-onyx-gauge-laboratory-v0.5.7/tests/check-water-normal-mode.cjs",
                }
                if not required <= set(package.namelist()):
                    errors.append("Gauge & Matter v0.5.7 source package membership mismatch")
                else:
                    prefix = "clear-onyx-gauge-laboratory-v0.5.7/"
                    bundled = package.read(prefix + "clear-onyx-gauge-laboratory-v0.5.7.html")
                    if hashlib.sha256(bundled).hexdigest() != sha256(ROOT / "models/view/clear-onyx-gauge-laboratory-v0.5.7.html"):
                        errors.append("Gauge & Matter v0.5.7 source package entry differs from live laboratory")
                    manifest = json.loads(package.read(prefix + "source-manifest.json"))
                    if not any(entry.get("path") == "tests/check-water-normal-mode.cjs" for entry in manifest.get("files", [])):
                        errors.append("Gauge & Matter v0.5.7 source manifest omits water normal-mode test")
                    audit = package.read(prefix + "AUDIT.md").decode("utf-8")
                    if "Water normal-mode receipt" not in audit:
                        errors.append("Gauge & Matter v0.5.7 source package omits water normal-mode receipt")
        except zipfile.BadZipFile:
            errors.append("Gauge & Matter v0.5.7 source package is not a readable ZIP")
    about = (ROOT/"about.html").read_text(encoding="utf-8")
    for marker in (
        "Existing field formalism, read together.",
        "What is closed in the stated record.",
        "An exact inverse, with its quartic boundary visible.",
        "Reality, imagination, and form keep distinct offices.",
    ):
        if marker not in about:
            errors.append("About page missing stated scope marker: " + marker)
    for overstatement in ("global linearization", "global linear straightening"):
        if overstatement in about:
            errors.append("About page overstates the local three-body boundary: " + overstatement)
    if "verified, audited closure" in about:
        errors.append("About page conflates verified and conditional/source-declared components")
    correspondence_page = (ROOT/"formal-correspondence/index.html").read_text()
    for marker in ("Formal Correspondence Ledger", "Public form", "Minimum Mechanics", "Suture", "Ω<sub>root</sub>", "G<sub>EM</sub>", "λ<sub>root</sub>", "P14"):
        if marker not in correspondence_page:
            errors.append("formal correspondence page missing marker: "+marker)
    for page in ROOT.rglob("*.html"):
        relative = page.relative_to(ROOT).as_posix()
        if relative == "404.html" or relative.startswith("archive/") or relative.split("/", 1)[0].startswith("public"):
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
    area_register = subprocess.run(
        [sys.executable, "-I", str(ROOT / "tools/verify_site_area_register.py")],
        cwd=ROOT,
        capture_output=True,
        text=True,
    )
    if area_register.returncode:
        detail = (area_register.stdout + area_register.stderr).strip().replace("\n", " | ")
        errors.append("site-area register validation failed: " + detail)
    print(f"Static candidate checked {len(CURRENT)} current pages, {len(HISTORY)} archived pages, "
          f"{checked} local references, {repairs} backward-compatible redirects, "
          f"{len(proof_files)} pinned proof source addresses, and Symmetric Minimum v{SYMMETRIC_MINIMUM_VERSION}")
    if errors:
        for e in errors: print("FAIL:",e)
        return 1
    print("PASS: page structure, source preservation, archival links, claim routes, and Symmetric Minimum release hashes")
    return 0

if __name__ == "__main__": raise SystemExit(verify())
