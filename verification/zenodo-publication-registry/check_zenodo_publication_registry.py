#!/usr/bin/env python3
"""Check the finite Coppalini Architecture Zenodo citation registry.

This is an offline consistency check.  It verifies the identifiers, fixed
version/concept distinction, and local archive routes already retained in the
registry; it does not contact Zenodo or assert live metadata.
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path
from urllib.parse import urlparse

ROOT = Path(__file__).resolve().parents[2]
REGISTRY_PATH = ROOT / "research/zenodo-publication-registry-v0.1.json"
PUBLIC_PAGE = ROOT / "publication-records.html"
LIBRARY_PAGE = ROOT / "library.html"
LANGUAGE_PAGE = ROOT / "language-mechanics.html"
SITE_DATA = ROOT / "site-data.js"
SITEMAP = ROOT / "sitemap.xml"

VERSION_DOI_RE = re.compile(r"^10\.5281/zenodo\.(\d+)$")
DATE_RE = re.compile(r"^2026-\d{2}-\d{2}$")
EXPECTED_KEYS = {
    "independent-tunability",
    "motion-and-difference",
    "metric-mirror-symmetry",
    "continuum-closure",
    "contact-recognition",
    "structure-of-survival",
    "three-body-mirror",
    "four-dual-forms",
    "nop-workbench",
    "linear-infinity",
    "mirror-escapement-time-lift",
    "twenty-eight-seam-reader",
    "mirror-recognition",
    "infinity-one-zero-lift",
}


def fail(message: str) -> None:
    raise AssertionError(message)


def route_exists(route: str) -> bool:
    route = route.split("#", 1)[0].split("?", 1)[0]
    if not route or route == "/":
        return (ROOT / "index.html").is_file()
    candidate = ROOT / route.lstrip("/")
    return any(path.is_file() for path in (candidate, Path(str(candidate) + ".html"), candidate / "index.html"))


def check_record(record: dict) -> None:
    for field in ("key", "title", "resource_type", "published", "version_doi", "record_url", "concept_doi", "site_forms"):
        if field not in record:
            fail(f"registry record missing {field}: {record.get('key', '<unnamed>')}")
    if not record["title"].strip():
        fail(f"empty title: {record['key']}")
    if not DATE_RE.fullmatch(record["published"]):
        fail(f"invalid publication date: {record['key']}")
    doi_match = VERSION_DOI_RE.fullmatch(record["version_doi"])
    if not doi_match:
        fail(f"invalid version DOI: {record['key']}")
    record_id = doi_match.group(1)
    if record["record_url"] != f"https://zenodo.org/records/{record_id}":
        fail(f"record URL and version DOI diverge: {record['key']}")
    if not VERSION_DOI_RE.fullmatch(record["concept_doi"]):
        fail(f"invalid concept DOI: {record['key']}")
    if not isinstance(record["site_forms"], list) or not record["site_forms"]:
        fail(f"missing Coppalini form paths: {record['key']}")
    for route in record["site_forms"]:
        if not route_exists(route):
            fail(f"missing local route for {record['key']}: {route}")


def main() -> int:
    registry = json.loads(REGISTRY_PATH.read_text(encoding="utf-8"))
    if registry.get("schema") != "coppalini/zenodo-publication-registry/v0.1":
        fail("registry schema mismatch")
    if registry.get("status") != "LOCAL_RECONCILED":
        fail("registry status mismatch")
    audit = registry.get("live_metadata_audit", {})
    if audit.get("current_release_count") != 14 or audit.get("historical_version_count") != 1:
        fail("registry release counts mismatch")
    records = registry.get("records", [])
    if len(records) != 14:
        fail("registry must carry exactly fourteen current releases")
    keys = [record.get("key") for record in records]
    if len(keys) != len(set(keys)) or set(keys) != EXPECTED_KEYS:
        fail("registry key set mismatch")
    doi_set = set()
    for record in records:
        check_record(record)
        if record["version_doi"] in doi_set:
            fail(f"duplicate version DOI: {record['version_doi']}")
        doi_set.add(record["version_doi"])

    page = PUBLIC_PAGE.read_text(encoding="utf-8")
    for record in records:
        for marker in (record["title"].rstrip("."), record["version_doi"], record["concept_doi"]):
            if marker not in page:
                fail(f"publication page missing {record['key']} marker: {marker}")
    if "10.5281/zenodo.24150161" not in page:
        fail("publication page missing Infinity One Zero Lift historical version")
    if "creates no Zenodo deposition or version" not in page:
        fail("publication page lacks no-deposition boundary")

    library = LIBRARY_PAGE.read_text(encoding="utf-8")
    library_keys = EXPECTED_KEYS - {"twenty-eight-seam-reader"}
    by_key = {record["key"]: record for record in records}
    for key in library_keys:
        if by_key[key]["version_doi"] not in library:
            fail(f"current Library lacks version DOI: {key}")
    language = LANGUAGE_PAGE.read_text(encoding="utf-8")
    if by_key["twenty-eight-seam-reader"]["version_doi"] not in language:
        fail("Language Mechanics shelf lacks LM 011 version DOI")

    site_data = SITE_DATA.read_text(encoding="utf-8")
    for key in ("independent-tunability", "metric-mirror-symmetry", "continuum-closure"):
        if by_key[key]["version_doi"] not in site_data:
            fail(f"legacy archive data lacks fixed version DOI: {key}")
        if by_key[key]["concept_doi"] not in site_data:
            fail(f"legacy archive data lacks concept DOI: {key}")
    if "https://eulershiddenl.ink/publication-records" not in SITEMAP.read_text(encoding="utf-8"):
        fail("sitemap lacks publication records route")
    print("PASS: Zenodo publication registry has 14 fixed release citations and local reading routes")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (AssertionError, FileNotFoundError, json.JSONDecodeError) as exc:
        print(f"FAIL: {exc}", file=sys.stderr)
        raise SystemExit(1)
