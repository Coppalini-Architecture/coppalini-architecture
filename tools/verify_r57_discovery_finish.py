#!/usr/bin/env python3
"""R57 candidate checks: root favicon, readable headings, recovery page, and responsive raster delivery."""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def check_r56() -> None:
    result = subprocess.run([sys.executable, "-I", "tools/verify_r56_site_tune.py"], cwd=ROOT, text=True, capture_output=True)
    require(result.returncode == 0, result.stderr or result.stdout or "R56 regression check failed")
    require("R56 PASS" in result.stdout, "R56 receipt is incomplete")
    print("R56 BASELINE PASS  prior recompute, author, navigation, and consent checks retained")


def check_favicon() -> None:
    required = (
        "favicon.ico",
        "coppalini-seam-matrix-favicon.svg",
        "coppalini-seam-matrix-favicon-512.png",
        "android-chrome-192x192.png",
        "apple-touch-icon.png",
        "site.webmanifest",
    )
    for name in required:
        require((ROOT / name).is_file(), f"missing favicon asset: {name}")
    manifest = (ROOT / "site.webmanifest").read_text(encoding="utf-8")
    require('"name": "Coppalini Architecture"' in manifest, "manifest name drifted")
    for page in ("index.html", "verify.html", "library.html", "architecture.html", "formalism.html", "anthony-vito-coppa.html", "exact/index.html"):
        text = (ROOT / page).read_text(encoding="utf-8")
        for marker in ('href="/favicon.ico"', 'href="/coppalini-seam-matrix-favicon.svg"', 'href="/site.webmanifest"'):
            require(marker in text, f"{page} lacks favicon binding: {marker}")
    print("FAVICON PASS  seam-matrix icon, fallbacks, manifest, and primary head bindings present")


def check_headings_and_home() -> None:
    home = (ROOT / "index.html").read_text(encoding="utf-8")
    require("Computational</span> <span class=\"title-line\">Gauge Invariance" in home, "homepage H1 lacks text separation")
    require("One algebraic identity</span> <span class=\"title-line\">Four physical constructions" in home, "Four Dual Forms title lacks text separation")
    require("Computational Gauge Invariance — Coppalini Architecture" in home, "homepage title is not aligned to its H1")
    require("field investigation" in home and 'rel="author"' in home, "homepage concise author provenance is missing")
    require("public research library" in home, "homepage plain-language summary is missing")
    print("HOME PASS  title, headings, concise author provenance, and plain-language summary aligned")


def check_404() -> None:
    page = (ROOT / "404.html").read_text(encoding="utf-8")
    for marker in ("address not found", 'href="/library"', 'href="/verify"', 'href="/architecture"', 'name="robots" content="noindex"'):
        require(marker in page, f"404 page lacks recovery binding: {marker}")
    print("404 PASS  crawl-safe recovery page links back to the public record")


def check_raster_delivery() -> None:
    author = (ROOT / "anthony-vito-coppa.html").read_text(encoding="utf-8")
    library = (ROOT / "library.html").read_text(encoding="utf-8")
    home = (ROOT / "index.html").read_text(encoding="utf-8")
    require("anthony-vito-coppa-fieldwork-768.webp" in author, "author portrait has no WebP source")
    for page in (home, library):
        require("the-3-body-mirror-720.webp" in page, "Three Body cover has no WebP source")
    for path in (ROOT / "assets/authors/anthony-vito-coppa-fieldwork-768.webp", ROOT / "art/covers/mirror-recognition/the-3-body-mirror-720.webp"):
        require(path.is_file() and path.stat().st_size > 0, f"missing optimized raster: {path.name}")
    print("MEDIA PASS  responsive WebP sources bound for the largest live portrait and cover")


def main() -> int:
    check_r56()
    check_favicon()
    check_headings_and_home()
    check_404()
    check_raster_delivery()
    print("R57 PASS")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except AssertionError as error:
        print(f"R57 FAIL  {error}", file=sys.stderr)
        raise SystemExit(1)
