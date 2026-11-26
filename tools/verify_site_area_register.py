#!/usr/bin/env python3
"""Verify the locked/development/archive routing register.

Run from the repository root:
    python3 -I tools/verify_site_area_register.py
"""
from __future__ import annotations

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
REGISTER = ROOT / "research/site-area-register-v0.1.json"
SITEMAP = ROOT / "sitemap.xml"
LLM_FILES = (ROOT / "llms.txt", ROOT / "llms-full.txt")
AREAS = {"locked", "development", "archive"}


def fail(message: str) -> None:
    print("FAIL:", message)
    raise SystemExit(1)


def route_file(route: str) -> Path | None:
    if route == "/":
        return ROOT / "index.html"
    target = ROOT / route.lstrip("/")
    for candidate in (target, Path(str(target) + ".html"), target / "index.html"):
        if candidate.is_file():
            return candidate
    return None


def source_file(source: str) -> Path | None:
    return route_file(source.split("#", 1)[0].split("?", 1)[0])


def main() -> int:
    try:
        register = json.loads(REGISTER.read_text(encoding="utf-8"))
    except FileNotFoundError:
        fail("site-area register is missing")
    except json.JSONDecodeError as exc:
        fail("site-area register is invalid JSON: " + str(exc))

    if register.get("schema") != "CoppaliniArchitecture.Site-Area-Register/v0.1":
        fail("unexpected register schema")
    area_ids = {entry.get("id") for entry in register.get("areas", [])}
    if area_ids != AREAS:
        fail("register must define exactly locked, development, and archive areas")

    records = register.get("records")
    if not isinstance(records, list) or not records:
        fail("register has no records")
    seen_ids: set[str] = set()
    seen_routes: set[str] = set()
    by_id: dict[str, dict] = {}
    for record in records:
        if not isinstance(record, dict):
            fail("register record is not an object")
        record_id = record.get("id")
        if not isinstance(record_id, str) or not record_id or record_id in seen_ids:
            fail("record identifiers must be unique non-empty strings")
        seen_ids.add(record_id)
        by_id[record_id] = record
        if record.get("area") not in AREAS:
            fail(record_id + ": invalid area")
        sources = record.get("source_records")
        if not isinstance(sources, list) or not sources or not all(isinstance(item, str) and item.startswith("/") for item in sources):
            fail(record_id + ": source_records must be non-empty site-relative paths")
        for source in sources:
            if source_file(source) is None:
                fail(record_id + ": missing source record " + source)
        route = record.get("route")
        if route is not None:
            if not isinstance(route, str) or not route.startswith("/"):
                fail(record_id + ": route must be site-relative or null")
            if route in seen_routes:
                fail(record_id + ": duplicated route " + route)
            seen_routes.add(route)
            if route_file(route) is None:
                fail(record_id + ": missing route target " + route)

    required = {"field-result", "moonlight-reader", "moonlight-receipt-drafts", "autotune-projection", "r58-public-arrangement"}
    if not required <= set(by_id):
        fail("register is missing a required first-area record")
    if by_id["moonlight-reader"].get("area") != "locked":
        fail("pinned MOONLIGHT reader must remain in locked record")
    if by_id["moonlight-receipt-drafts"].get("discovery") != "noindex":
        fail("MOONLIGHT receipt drafts must remain noindex")
    if by_id["autotune-projection"].get("route") is not None or by_id["autotune-projection"].get("discovery") != "hold-only":
        fail("Autotune must remain hold-only without a public route")

    development = ROOT / "development/index.html"
    development_text = development.read_text(encoding="utf-8") if development.is_file() else ""
    for marker in (
        '<meta name="robots" content="noindex">',
        "Work that is readable but not yet admitted to the locked record.",
        "HARMONIZER-001, RELAX-001, and RELAX-RECEIPT-001 remain draft/local",
        "The candidate is retained as HOLD.",
        "These are routing classes, not additions to the canonical seven-status key.",
    ):
        if marker not in development_text:
            fail("development index missing marker: " + marker)

    receipt = (ROOT / "moonlight/receipts/index.html").read_text(encoding="utf-8")
    if 'href="/development/">Development index</a>' not in receipt:
        fail("MOONLIGHT receipt drafts lack development-index link")
    try:
        receipt_manifest = json.loads((ROOT / "moonlight/receipts/release.json").read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        fail("MOONLIGHT receipt draft manifest is invalid JSON: " + str(exc))
    if receipt_manifest.get("retained_boundaries", {}).get("fd020d0") != "HOLD":
        fail("MOONLIGHT receipt draft manifest no longer marks fd020d0 HOLD")
    for public_page in ("moonlight/index.html", "moonlight/dome/index.html"):
        if "/moonlight/autotune/" in (ROOT / public_page).read_text(encoding="utf-8"):
            fail(public_page + " exposes held Autotune route")

    sitemap_text = SITEMAP.read_text(encoding="utf-8")
    for route in ("/development/", "/moonlight/receipts/", "/moonlight/autotune/"):
        if route in sitemap_text:
            fail("non-locked route appears in sitemap: " + route)
    for llm in LLM_FILES:
        text = llm.read_text(encoding="utf-8")
        for route in ("/development/", "/moonlight/receipts/", "/moonlight/autotune/"):
            if route in text:
                fail(llm.name + " exposes non-locked route: " + route)

    print("PASS: locked/development/archive area register and discovery boundaries")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
