#!/usr/bin/env python3
"""Apply the R56 public navigation label consistently across static pages."""

from __future__ import annotations

import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
ARCHITECTURE_LINK = re.compile(r'(<a\b[^>]*\bhref="/architecture"[^>]*>)Architecture(</a>)')


def main() -> int:
    changed = 0
    for path in sorted(ROOT.rglob("*.html")):
        text = path.read_text(encoding="utf-8")
        updated, replacements = ARCHITECTURE_LINK.subn(r"\1Constructions\2", text)
        if replacements:
            path.write_text(updated, encoding="utf-8")
            changed += 1
    print(f"R56 navigation: {changed} pages now label /architecture as Constructions.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
