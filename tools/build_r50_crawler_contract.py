#!/usr/bin/env python3
"""Generate the R50 discovery records from the released static-site payload.

The script is deliberately local: it neither fetches sources nor alters any
released mathematical payload. It resolves canonical links, exposes receipt
copies already bound inside released archives, and writes two discovery maps.
"""

from __future__ import annotations

import hashlib
import json
import re
import zipfile
from datetime import datetime, timezone
from pathlib import Path
from urllib.parse import urlparse
from xml.etree.ElementTree import Element, ElementTree, SubElement, register_namespace


ROOT = Path(__file__).resolve().parents[1]
BASE = "https://eulershiddenl.ink"
CANONICAL_RE = re.compile(
    r'(<link\b[^>]*\brel=["\']canonical["\'][^>]*\bhref=["\'])[^"\']*(["\'][^>]*>)',
    re.IGNORECASE,
)


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def public_path(path: Path) -> str:
    relative = path.relative_to(ROOT)
    if relative.name == "index.html":
        parent = relative.parent.as_posix()
        return "/" if parent == "." else f"/{parent}/"
    if relative.suffix == ".html":
        return f"/{relative.with_suffix('').as_posix()}"
    return f"/{relative.as_posix()}"


def public_url(path: Path) -> str:
    return BASE + public_path(path)


def canonical_from_href(page: Path, href: str) -> str:
    parsed = urlparse(href)
    if parsed.scheme in {"http", "https"}:
        if parsed.netloc == "eulershiddenl.ink":
            target = parsed.path or "/"
            if target.endswith(".html"):
                candidate = ROOT / target.lstrip("/")
                if candidate.exists():
                    return public_url(candidate)
            return f"{BASE}{target}"
        return href

    clean = href.split("#", 1)[0].split("?", 1)[0]
    target = (page.parent / clean).resolve()
    try:
        target.relative_to(ROOT)
    except ValueError as error:
        raise RuntimeError(f"canonical leaves site root: {page}: {href}") from error
    return public_url(target)


def normalize_canonicallinks() -> dict[Path, str]:
    results: dict[Path, str] = {}
    for page in sorted(ROOT.rglob("*.html")):
        if "?" in page.name:
            continue
        text = page.read_text(encoding="utf-8")
        matches = list(CANONICAL_RE.finditer(text))
        if len(matches) > 1:
            raise RuntimeError(f"multiple canonical links: {page}")
        canonical = public_url(page)
        if matches:
            current = matches[0].group(0)
            # Recover only the href value from the matched tag.
            href_match = re.search(r'\bhref=["\']([^"\']+)["\']', current, re.IGNORECASE)
            if href_match:
                canonical = canonical_from_href(page, href_match.group(1))
            text = text[: matches[0].start()] + f'<link rel="canonical" href="{canonical}">' + text[matches[0].end() :]
        else:
            marker = "</head>"
            if marker not in text:
                raise RuntimeError(f"missing </head>: {page}")
            text = text.replace(marker, f'  <link rel="canonical" href="{canonical}">\n{marker}', 1)
        page.write_text(text, encoding="utf-8")
        results[page] = canonical
    return results


def extract_receipts() -> dict[str, dict[str, str]]:
    extracts = {
        "W-0": (
            "downloads/W0_v0_2_packet.zip",
            "W0_v0_2_packet/W0_WEINBERG_SEAM_RECEIPT_v0_2.txt",
            "research/audit/W0_WEINBERG_SEAM_RECEIPT_v0_2.txt",
        ),
        "W-1": (
            "downloads/W1_v0_2_packet.zip",
            "W1_CARRIER_ADAPTER_RECEIPT_v0_2.txt",
            "research/audit/W1_CARRIER_ADAPTER_RECEIPT_v0_2.txt",
        ),
        "NDA-3": (
            "downloads/NATIVE_DOMAIN_ADAPTER_ATLAS_v0_3.zip",
            "NATIVE_DOMAIN_ADAPTER_ATLAS_v0_3/ATLAS_RECEIPT_v0_3.txt",
            "research/audit/NATIVE_DOMAIN_ADAPTER_ATLAS_RECEIPT_v0_3.txt",
        ),
    }
    result: dict[str, dict[str, str]] = {}
    for record_id, (archive_rel, archive_member, destination_rel) in extracts.items():
        archive = ROOT / archive_rel
        destination = ROOT / destination_rel
        with zipfile.ZipFile(archive) as package:
            data = package.read(archive_member)
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(data)
        result[record_id] = {
            "archive_member": archive_member,
            "public_path": destination_rel,
            "sha256": hashlib.sha256(data).hexdigest(),
        }
    return result


def build_manifest(extracted: dict[str, dict[str, str]]) -> Path:
    registry_path = ROOT / "research/public-claim-registry-v0.2.json"
    contract_path = ROOT / "research/reader-contract.json"
    registry = json.loads(registry_path.read_text(encoding="utf-8"))
    receipt_paths = {
        "B-2": ("research/audit/VALIDATOR_KIT_B2_RECEIPT.md", "Validator_Kit_B2_v0_1/KIT_RECEIPT.md"),
        "S-5/05a": ("research/suture-field/RESIDUAL_LEDGER_v0_2.md", "Suture_Audit_v0_2/RESIDUAL_LEDGER_v0_2.md"),
        "W-0": (extracted["W-0"]["public_path"], extracted["W-0"]["archive_member"]),
        "W-1": (extracted["W-1"]["public_path"], extracted["W-1"]["archive_member"]),
        "NDA-3": (extracted["NDA-3"]["public_path"], extracted["NDA-3"]["archive_member"]),
    }

    records = []
    for source in registry["artifacts"]:
        receipt_rel, archive_member = receipt_paths[source["id"]]
        receipt_file = ROOT / receipt_rel
        records.append(
            {
                "id": source["id"],
                "label": source["label"],
                "result": source["result"],
                "command": source["command"],
                "artifact": {
                    "url": f"{BASE}/{source['artifact']}",
                    "sha256": source["sha256"],
                },
                "receipt": {
                    "url": public_url(receipt_file),
                    "sha256": sha256(receipt_file),
                    "archive_member": archive_member,
                },
                "scope": source["scope"],
            }
        )

    manifest = {
        "record_type": "CoppaliniArchitectureVerificationManifest",
        "version": "v0.1",
        "issued": "2026-11-11",
        "canonical_site": f"{BASE}/",
        "publisher": {
            "name": "Anthony Vito Coppa",
            "url": f"{BASE}/anthony-vito-coppa.html",
        },
        "reading_order": "source → verifier → receipt → scope → next record",
        "claim_registry": {
            "url": public_url(registry_path),
            "sha256": sha256(registry_path),
        },
        "reader_contract": {
            "url": public_url(contract_path),
            "sha256": sha256(contract_path),
        },
        "records": records,
        "next_records": registry["next_records"],
        "policy": "This manifest identifies released artifacts and their stated results and scope. It does not alter the claim strength of any underlying record.",
    }
    destination = ROOT / "research/verification-manifest-v0.1.json"
    destination.write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    return destination


def sitemap_targets(canonical_pages: dict[Path, str]) -> set[str]:
    urls = set(canonical_pages.values())
    include_suffixes = {".pdf", ".tex", ".py", ".md", ".json", ".txt", ".out"}
    include_roots = {"papers", "research", "verification", "exact"}
    for path in ROOT.rglob("*"):
        if not path.is_file() or path.suffix.lower() not in include_suffixes:
            continue
        rel = path.relative_to(ROOT)
        if rel.parts[0] not in include_roots or "__pycache__" in rel.parts or "?" in path.name:
            continue
        urls.add(public_url(path))
    # Core download packages are useful retrieval objects but not canonical pages.
    for relative in (
        "downloads/Validator_Kit_B2_v0_1.zip",
        "downloads/Suture_Audit_v0_2.zip",
        "downloads/W0_v0_2_packet.zip",
        "downloads/W1_v0_2_packet.zip",
        "downloads/NATIVE_DOMAIN_ADAPTER_ATLAS_v0_3.zip",
        "llms.txt",
        "llms-full.txt",
    ):
        urls.add(f"{BASE}/{relative}")
    return urls


def build_sitemap(canonical_pages: dict[Path, str]) -> Path:
    register_namespace("", "http://www.sitemaps.org/schemas/sitemap/0.9")
    root = Element("{http://www.sitemaps.org/schemas/sitemap/0.9}urlset")
    for url in sorted(sitemap_targets(canonical_pages)):
        parsed = urlparse(url)
        if parsed.netloc != "eulershiddenl.ink":
            continue
        local = ROOT / parsed.path.lstrip("/")
        if parsed.path.endswith("/"):
            local = local / "index.html"
        elif not local.exists():
            # Versioned route names such as `cordis-v0.3` already have a
            # numeric suffix, so append rather than replace any suffix.
            candidate = Path(f"{local}.html")
            if candidate.exists():
                local = candidate
        if not local.exists():
            raise RuntimeError(f"sitemap target does not exist locally: {url}")
        node = SubElement(root, "{http://www.sitemaps.org/schemas/sitemap/0.9}url")
        SubElement(node, "{http://www.sitemaps.org/schemas/sitemap/0.9}loc").text = url
        modified = datetime.fromtimestamp(local.stat().st_mtime, tz=timezone.utc).date().isoformat()
        SubElement(node, "{http://www.sitemaps.org/schemas/sitemap/0.9}lastmod").text = modified
    destination = ROOT / "sitemap.xml"
    ElementTree(root).write(destination, encoding="utf-8", xml_declaration=True)
    return destination


def main() -> None:
    canonical_pages = normalize_canonicallinks()
    extracted = extract_receipts()
    manifest = build_manifest(extracted)
    sitemap = build_sitemap(canonical_pages)
    print(f"normalized canonical links: {len(canonical_pages)}")
    print(f"verification manifest: {manifest.relative_to(ROOT)} {sha256(manifest)}")
    print(f"sitemap: {sitemap.relative_to(ROOT)} {sha256(sitemap)}")


if __name__ == "__main__":
    main()
