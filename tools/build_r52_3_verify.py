#!/usr/bin/env python3
"""Build and validate the R52.3 native Audit Register presentation.

The supplied audit source is preserved byte-for-byte under research/audit. This
builder translates its record and card detail into the site's native shell,
binds links to artifacts present in this release, and refuses stale v0.3/v0.2
references that are not shipped here.

Run:
    python3 -I tools/build_r52_3_verify.py
    python3 -I tools/build_r52_3_verify.py --validate-only
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
BASE = "https://eulershiddenl.ink"
SOURCE = ROOT / "research/audit/verification-source-claude-v0.3.source"
PAGE = ROOT / "verify.html"
RECEIPT = ROOT / "R52_3_VERIFICATION_PAGE_RECEIPT.json"
REGISTRY = ROOT / "research/public-claim-registry-v0.2.json"
MANIFEST = ROOT / "research/verification-manifest-v0.2.json"
KIT = ROOT / "downloads/Validator_Kit_B2_v0_1.zip"

HASHES = {
    "registry": "6da82c78b9c4eb281b835d9c712366b83b9b7a030cc2adc2e5fec19c3e337003",
    "manifest": "1c523aa03c527fe9a64b29f4b6aa8f624c88a614341d52c0d77dd7ee12cd4a9f",
    "kit": "03cfda6a4ebbefc1302accdace1493027c840253bfc35d1c3e93b42dfc4574a0",
    "suture": "b2df5089e3e7e6ce6f6a7f673d8381ca86accc05d1379fb3b75e22696b088448",
    "w0": "9fe1b3c4d66ab42d59cfb8d16fd0c0ca1e4bb3b6c393ec191fa3c9516e7b0431",
    "w1": "22b92b32d93b2a7d7446a7f147475e7dac98c9f84880f96b1ac297618037b50f",
    "nda": "4075a5c57fe36a2977311ea58dad5181ed5b971859df390e797ed23ee6f8d075",
}

RECEIPTS = {
    "kit": {
        "path": "research/audit/VALIDATOR_KIT_B2_RECEIPT.md",
        "sha256": "7d998a50665308589c37c069eeeb88325277be4eab0cb013f73cdc209aaf0ebb",
        "label": "Run receipt",
    },
    "suture": {
        "path": "research/suture-field/RESIDUAL_LEDGER_v0_2.md",
        "sha256": "f2fe9d6769f38f0afe56663304dfd235c48b2d93e6b8294afc597de19278285e",
        "label": "Residual ledger",
    },
    "w0": {
        "path": "research/audit/W0_WEINBERG_SEAM_RECEIPT_v0_2.txt",
        "sha256": "5977b5bff0d73f75c81645b3654a7ff4412f700932372313dcd62e53fdee5e43",
        "label": "Run receipt",
    },
    "w1": {
        "path": "research/audit/W1_CARRIER_ADAPTER_RECEIPT_v0_2.txt",
        "sha256": "6a3321e8dc4cf44c6aed8649faf35148ef25cc4af57e0b878e6f55600a059ebc",
        "label": "Run receipt",
    },
    "nda": {
        "path": "research/audit/NATIVE_DOMAIN_ADAPTER_ATLAS_RECEIPT_v0_3.txt",
        "sha256": "bf4e97d517679a7ab51c192995cfe2b09b1b399b86aece53ebbfe98f8626992d",
        "label": "Run receipt",
    },
}


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def require(condition: bool, message: str) -> None:
    if not condition:
        raise RuntimeError(message)


def native_header() -> str:
    graph = {
        "@context": "https://schema.org",
        "@graph": [
            {
                "@type": "Person",
                "@id": BASE + "/#anthony-vito-coppa",
                "name": "Anthony Vito Coppa",
                "url": BASE + "/anthony-vito-coppa",
            },
            {
                "@type": "Dataset",
                "@id": BASE + "/research/verification-manifest-v0.2.json",
                "name": "Coppalini Architecture Verification Manifest v0.2",
                "description": "Hash-bound released audit records with commands, receipts, stated domains, and boundaries.",
                "url": BASE + "/research/verification-manifest-v0.2.json",
                "version": "v0.2",
                "dateModified": "2026-11-12",
                "creator": {"@id": BASE + "/#anthony-vito-coppa"},
                "measurementTechnique": "Hash-gated executable verification cards: recorded SHA-256 match, successful exit, and required marker line.",
                "distribution": [
                    {
                        "@type": "DataDownload",
                        "name": "Public claim registry v0.2",
                        "encodingFormat": "application/json",
                        "contentUrl": BASE + "/research/public-claim-registry-v0.2.json",
                        "sha256": HASHES["registry"],
                    },
                    {
                        "@type": "DataDownload",
                        "name": "Validator Kit B2 v0.1",
                        "encodingFormat": "application/zip",
                        "contentUrl": BASE + "/downloads/Validator_Kit_B2_v0_1.zip",
                        "sha256": HASHES["kit"],
                    },
                    {
                        "@type": "DataDownload",
                        "name": "Suture Audit v0.2",
                        "encodingFormat": "application/zip",
                        "contentUrl": BASE + "/downloads/Suture_Audit_v0_2.zip",
                        "sha256": HASHES["suture"],
                    },
                    {
                        "@type": "DataDownload",
                        "name": "Weinberg seam v0.2",
                        "encodingFormat": "application/zip",
                        "contentUrl": BASE + "/downloads/W0_v0_2_packet.zip",
                        "sha256": HASHES["w0"],
                    },
                    {
                        "@type": "DataDownload",
                        "name": "Electroweak carrier adapter v0.2",
                        "encodingFormat": "application/zip",
                        "contentUrl": BASE + "/downloads/W1_v0_2_packet.zip",
                        "sha256": HASHES["w1"],
                    },
                    {
                        "@type": "DataDownload",
                        "name": "Native Domain Adapter Atlas v0.3",
                        "encodingFormat": "application/zip",
                        "contentUrl": BASE + "/downloads/NATIVE_DOMAIN_ADAPTER_ATLAS_v0_3.zip",
                        "sha256": HASHES["nda"],
                    },
                ],
            },
            {
                "@type": "WebPage",
                "@id": BASE + "/verify#page",
                "name": "Audit Register — Coppalini Architecture",
                "url": BASE + "/verify",
                "dateModified": "2026-11-12",
                "author": {"@id": BASE + "/#anthony-vito-coppa"},
                "mainEntity": {"@id": BASE + "/research/verification-manifest-v0.2.json"},
            },
        ],
    }
    return """<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="description" content="Coppalini Architecture Audit Register: five hash-bound records and twelve executable validation cards, with their stated domains, equations, root seams, and receipts.">
  <meta name="author" content="Anthony Vito Coppa">
  <link rel="canonical" href="https://eulershiddenl.ink/verify">
  <link rel="alternate" type="application/json" title="Verification manifest" href="research/verification-manifest-v0.2.json">
  <title>Audit Register — Coppalini Architecture</title>
  <link rel="stylesheet" href="assets/site.css">
  <link rel="stylesheet" href="verify.css">
  <script type="application/ld+json">
""" + json.dumps(graph, indent=2, ensure_ascii=False) + """
  </script>
</head>
<body>
  <a class="skip-link" href="#main">Skip to content</a>
  <header class="site-header">
    <div class="header-inner">
      <a class="brand" href="/">Coppalini Architecture</a>
      <nav class="primary-nav" aria-label="Primary">
        <a href="/">Home</a>
        <a href="/library">Library</a>
        <a aria-current="page" href="/verify">Verify</a>
        <a href="/architecture">Architecture</a>
        <a href="/formalism">Basis</a>
      </nav>
    </div>
  </header>
"""


def native_footer() -> str:
    return """
  <footer class="site-footer"><div>© 2026 Anthony Vito Coppa · Coppalini Architecture</div></footer>
</body>
</html>
"""


def translate_main(source: str) -> str:
    match = re.search(r"<main>(.*)</main>", source, flags=re.DOTALL)
    require(match is not None, "Supplied verification source has no main element.")
    main = match.group(1).strip()
    replacements = (
        ("Public claim registry · v0.3 · released 2026-11-11",
         "Public claim registry · v0.2 · presentation updated 2026-11-12"),
        ("public-claim-registry-v0.3.json", "research/public-claim-registry-v0.2.json"),
        ("Validator_Kit_B2_v0_2.zip", "Validator_Kit_B2_v0_1.zip"),
        ("Validator Kit B2 v0.2", "Validator Kit B2 v0.1"),
        ("c3b1fc7ac6095b48d9bec6d5c748d7a4822fc2a9588935c4778ca8b6f0c9e96e", HASHES["registry"]),
        ("c0bb1552bbc7d6522546d6f67fbb31d825c500f47d272812d35768a17b3fa2bc", HASHES["kit"]),
        ("f66e055dc6a12295759b756fe16dc4403eec10dede97e46c4f1c324c85a0d723", "f4391fa145bdf9e1426d3d7ed98b9d071a9fecd208e187efab0fb139efad2e7c"),
        ("12 hash-gated cards, 12/12 PASS: 9 exact-arithmetic cards and 3 floating-point cards at a declared 1e-12 tolerance.",
         "12 hash-gated cards, 12/12 PASS: nine exact-arithmetic cards and three floating-point cards. S-6 and S-7 declare 1e-12; C-1 retains the released NumPy allclose implementation."),
        ("v0.2 declares card C-1&#x27;s float tolerance (atol 1e-12, rtol 0); all other card hashes are unchanged from v0.1.",
         "S-6 and S-7 declare 1e-12. C-1 retains the shipped NumPy allclose implementation; all card hashes are those of Validator Kit B2 v0.1."),
        ("float: numpy, explicit atol 1e-12, rtol 0; requires numpy",
         "float: NumPy allclose; requires NumPy"),
        ("Three cards use floating point: S-6, S-7 and C-1. Each declares its tolerance in the card and in the manifest: 1e-12. C-1 states it explicitly as <code>atol=1e-12, rtol=0</code>. All three are hash-gated and run under the same acceptance criterion as the exact cards.",
         "Three cards use floating point: S-6, S-7 and C-1. S-6 and S-7 declare a tolerance of 1e-12. C-1 retains the released NumPy <code>allclose</code> implementation. All three are hash-gated and run under the same acceptance criterion as the exact cards."),
        ("Version note: kit v0.1 ran C-1 with numpy's default <code>allclose</code> tolerances. v0.2 declares them. The other eleven card hashes are unchanged.",
         "Release note: C-1 remains the shipped NumPy <code>allclose</code> implementation in Validator Kit B2 v0.1; this page records that basis directly rather than assigning a new threshold."),
        ("VERSION: v0.3", "VERSION: v0.2"),
        ("RELEASED: 2026-11-11", "PAGE_UPDATED: 2026-11-12"),
        ("KIT_ARITHMETIC: 9 exact cards; 3 float cards at declared tolerance 1e-12",
         "KIT_ARITHMETIC: 9 exact cards; S-6 and S-7 float at 1e-12; C-1 uses released NumPy allclose"),
        ("unzip Validator_Kit_B2_v0_1.zip &amp;&amp; cd Validator_Kit_B2_v0_2",
         "unzip Validator_Kit_B2_v0_1.zip &amp;&amp; cd Validator_Kit_B2_v0_1"),
        ("Suggested statement of the result: the Coppalini Architecture kit v0.2 reports 12/12 PASS on hash-gated executable cards, 9 with exact arithmetic and 3 at declared 1e-12 tolerance, with 5 released records. The checks are self-administered and contain no laboratory data.",
         "Suggested statement of the result: Validator Kit B2 v0.1 reports 12/12 PASS on hash-gated executable cards: nine exact-arithmetic cards, S-6 and S-7 at declared 1e-12 tolerance, and C-1 with its released NumPy allclose basis. The page carries five released records. The checks are self-administered and contain no laboratory data."),
    )
    for old, new in replacements:
        require(old in main, f"Expected source text absent: {old[:56]!r}")
        main = main.replace(old, new)
    main = main.replace(
        "<div role=\"listitem\"><b>9 exact · 3 float</b><span>float cards at declared 1e-12</span></div>",
        "<div role=\"listitem\"><b>9 exact · 3 float</b><span>S-6/S-7 1e-12 · C-1 NumPy</span></div>",
    )
    main = main.replace(
        '<p><a href="downloads/Validator_Kit_B2_v0_1.zip">Download the validator kit</a> · <a href="research/public-claim-registry-v0.2.json">Read the machine registry</a></p>',
        '<p><a href="downloads/Validator_Kit_B2_v0_1.zip">Download the validator kit</a> · <a href="research/public-claim-registry-v0.2.json">Read the machine registry</a> · <a href="research/verification-index.md">Browse the verification index</a></p>',
    )
    record_receipts = (
        (
            'downloads/Validator_Kit_B2_v0_1.zip',
            RECEIPTS["kit"],
        ),
        (
            'downloads/Suture_Audit_v0_2.zip',
            RECEIPTS["suture"],
        ),
        (
            'downloads/W0_v0_2_packet.zip',
            RECEIPTS["w0"],
        ),
        (
            'downloads/W1_v0_2_packet.zip',
            RECEIPTS["w1"],
        ),
        (
            'downloads/NATIVE_DOMAIN_ADAPTER_ATLAS_v0_3.zip',
            RECEIPTS["nda"],
        ),
    )
    for artifact, receipt in record_receipts:
        source_row = f'<dt>Source artifact</dt><dd><a href="{artifact}">{artifact}</a></dd>'
        receipt_row = f'<dt>{receipt["label"]}</dt><dd><a href="{receipt["path"]}">{receipt["path"]}</a> · <code class="h">{receipt["sha256"]}</code></dd>'
        require(source_row in main, f"Expected source-artifact row absent: {artifact}")
        main = main.replace(source_row, source_row + "\n" + receipt_row, 1)
    hero = re.match(r"\s*(<p class=\"kicker\">.*?</nav>)", main, flags=re.DOTALL)
    require(hero is not None, "Could not identify the supplied hero and audit navigation.")
    hero_text = hero.group(1).replace(
        '<nav aria-label="On this page">', '<nav class="audit-toc" aria-label="On this page">', 1
    )
    main = "<section class=\"verify-hero\" aria-labelledby=\"audit-register-title\">" + hero_text + "</section>" + main[hero.end():]
    main = main.replace("<h1>Audit Register</h1>", '<h1 id="audit-register-title">Audit Register</h1>', 1)
    return main


def build() -> None:
    require(SOURCE.is_file(), f"Missing supplied source: {SOURCE.relative_to(ROOT)}")
    for name, path in (("registry", REGISTRY), ("manifest", MANIFEST), ("kit", KIT)):
        require(digest(path) == HASHES[name], f"Unexpected released {name} hash.")
    source = SOURCE.read_text(encoding="utf-8")
    main = translate_main(source)
    text = native_header() + '\n  <main id="main" class="verify-main audit-register">\n' + main + "\n  </main>" + native_footer()
    PAGE.write_text(text, encoding="utf-8")
    receipt = {
        "release": "R52.3",
        "result": "PASS",
        "page": {
            "url": BASE + "/verify",
            "path": "verify.html",
            "sha256": digest(PAGE),
            "canonical": BASE + "/verify",
        },
        "source": {
            "path": SOURCE.relative_to(ROOT).as_posix(),
            "sha256": digest(SOURCE),
            "role": "Supplied audit-page content, preserved as a non-indexed provenance source.",
        },
        "release_bindings": {
            "claim_registry": {"path": "research/public-claim-registry-v0.2.json", "sha256": HASHES["registry"]},
            "verification_manifest": {"path": "research/verification-manifest-v0.2.json", "sha256": HASHES["manifest"]},
            "validator_kit": {"path": "downloads/Validator_Kit_B2_v0_1.zip", "sha256": HASHES["kit"]},
            "record_receipts": RECEIPTS,
        },
        "presentation": {
            "records": 5,
            "cards": 12,
            "columns_added_to_cards": [
                "Native result (declared domain)",
                "Formal provenance equations",
                "Root closure at the seam",
            ],
            "crawler_contract": {
                "canonical": BASE + "/verify",
                "dataset_jsonld_content_urls": "absolute",
                "sitemap_lastmod": "2026-11-12",
                "robots_policy": "existing wildcard allow covers general crawlers, Claude-User, and Claude-SearchBot",
            },
        },
        "corrections_to_supplied_layout": [
            "Bound the page to the release's served v0.2 claim registry and Validator Kit B2 v0.1.",
            "Preserved the shipped C-1 NumPy allclose basis instead of asserting an unshipped v0.2 tolerance declaration.",
            "Replaced relative Dataset distribution URLs with absolute canonical URLs.",
            "Added direct links and SHA-256 values for the five served record receipts, plus the maintained verification index.",
        ],
    }
    RECEIPT.write_text(json.dumps(receipt, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def validate() -> dict[str, object]:
    for name, path in (("registry", REGISTRY), ("manifest", MANIFEST), ("kit", KIT)):
        require(digest(path) == HASHES[name], f"Released {name} hash changed.")
    for name, receipt in RECEIPTS.items():
        path = ROOT / receipt["path"]
        require(path.is_file(), f"Released {name} receipt is absent: {receipt['path']}")
        require(digest(path) == receipt["sha256"], f"Released {name} receipt hash changed.")
    require(PAGE.is_file() and RECEIPT.is_file(), "Build output or receipt is missing.")
    text = PAGE.read_text(encoding="utf-8")
    receipt = json.loads(RECEIPT.read_text(encoding="utf-8"))
    require(receipt["page"]["sha256"] == digest(PAGE), "Receipt page hash does not match output.")
    require(receipt["source"]["sha256"] == digest(SOURCE), "Receipt source hash does not match provenance source.")
    required = (
        '<link rel="canonical" href="https://eulershiddenl.ink/verify">',
        '<main id="main" class="verify-main audit-register">',
        'id="audit-register-title"',
        'id="rec-B-2"', 'id="rec-S-5-05a"', 'id="rec-W-0"', 'id="rec-W-1"', 'id="rec-NDA-3"',
        'id="card-S-1"', 'id="card-C-1"',
        "Native result (declared domain)", "Formal provenance equations", "Root closure at the seam",
        HASHES["kit"], HASHES["suture"], HASHES["w0"], HASHES["w1"], HASHES["nda"],
        "f4391fa145bdf9e1426d3d7ed98b9d071a9fecd208e187efab0fb139efad2e7c",
        "research/verification-index.md",
    )
    for marker in required:
        require(marker in text, f"Rendered page is missing: {marker}")
    for receipt in RECEIPTS.values():
        require(receipt["path"] in text, f"Rendered page is missing receipt link: {receipt['path']}")
        require(receipt["sha256"] in text, f"Rendered page is missing receipt hash: {receipt['path']}")
    stale = (
        "Validator_Kit_B2_v0_2.zip",
        "public-claim-registry-v0.3.json",
        "c0bb1552bbc7d6522546d6f67fbb31d825c500f47d272812d35768a17b3fa2bc",
        "c3b1fc7ac6095b48d9bec6d5c748d7a4822fc2a9588935c4778ca8b6f0c9e96e",
        "f66e055dc6a12295759b756fe16dc4403eec10dede97e46c4f1c324c85a0d723",
        "explicit atol 1e-12, rtol 0",
        "cd Validator_Kit_B2_v0_2",
        "the Coppalini Architecture kit v0.2 reports",
    )
    for marker in stale:
        require(marker not in text, f"Rendered page retains stale release text: {marker}")
    require(len(re.findall(r'id="card-[^"]+"', text)) == 12, "Expected twelve card rows.")
    require(len(re.findall(r'id="rec-[^"]+"', text)) == 5, "Expected five record blocks.")
    scripts = re.findall(r'<script type="application/ld\+json">\s*(.*?)\s*</script>', text, flags=re.DOTALL)
    require(len(scripts) == 1, "Expected one JSON-LD block.")
    graph = json.loads(scripts[0])
    datasets = [node for node in graph["@graph"] if node.get("@type") == "Dataset"]
    require(len(datasets) == 1, "Expected one Dataset JSON-LD node.")
    distributions = datasets[0]["distribution"]
    require(len(distributions) == 6, "Dataset must bind six served artifacts.")
    for item in distributions:
        url = item["contentUrl"]
        require(url.startswith(BASE + "/"), f"Dataset contentUrl is not absolute: {url}")
        target = ROOT / url.removeprefix(BASE + "/")
        require(target.is_file(), f"Dataset target is absent: {url}")
        require(digest(target) == item["sha256"], f"Dataset hash differs: {url}")
    return {
        "release": "R52.3",
        "result": "PASS",
        "records": 5,
        "cards": 12,
        "dataset_distributions": len(distributions),
        "page_sha256": digest(PAGE),
        "source_sha256": digest(SOURCE),
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--validate-only", action="store_true", help="Check output and receipt without rewriting them.")
    args = parser.parse_args()
    if not args.validate_only:
        build()
    print(json.dumps(validate(), indent=2, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
