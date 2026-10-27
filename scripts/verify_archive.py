#!/usr/bin/env python3
"""Verify archive checksums, tracked-file coverage, and declared aliases."""

from __future__ import annotations

import hashlib
import json
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
LEDGER = ROOT / "SHA256SUMS"
ALIASES = ROOT / "ALIASES.json"


def digest(path: Path) -> str:
    value = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            value.update(block)
    return value.hexdigest()


def tracked_files() -> set[str]:
    result = subprocess.run(
        ["git", "ls-files", "-z"],
        cwd=ROOT,
        check=True,
        capture_output=True,
    )
    return {
        item.decode("utf-8")
        for item in result.stdout.split(b"\0")
        if item and item.decode("utf-8") != "SHA256SUMS"
    }


def read_ledger() -> tuple[dict[str, str], list[str]]:
    entries: dict[str, str] = {}
    failures: list[str] = []
    for number, raw in enumerate(
        LEDGER.read_text(encoding="utf-8").splitlines(), start=1
    ):
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        try:
            expected, relative = line.split(maxsplit=1)
        except ValueError:
            failures.append(f"ledger line {number} is malformed")
            continue
        relative = relative.lstrip("* ")
        if relative in entries:
            failures.append(f"duplicate ledger path: {relative}")
        entries[relative] = expected
    return entries, failures


def main() -> int:
    failures: list[str] = []
    entries, ledger_failures = read_ledger()
    failures.extend(ledger_failures)

    tracked = tracked_files()
    ledger_paths = set(entries)

    for relative in sorted(tracked - ledger_paths):
        failures.append(f"tracked file absent from ledger: {relative}")
    for relative in sorted(ledger_paths - tracked):
        failures.append(f"ledger path is not tracked: {relative}")

    for relative, expected in sorted(entries.items()):
        path = ROOT / relative
        if not path.is_file():
            failures.append(f"missing file: {relative}")
            continue
        actual = digest(path)
        if actual != expected:
            failures.append(
                f"checksum mismatch: {relative}\n"
                f"  expected {expected}\n"
                f"  actual   {actual}"
            )

    alias_data = json.loads(ALIASES.read_text(encoding="utf-8"))
    for relation in alias_data["aliases"]:
        alias = ROOT / relation["alias"]
        canonical = ROOT / relation["canonical"]
        if not alias.is_file() or not canonical.is_file():
            failures.append(
                f"alias relation has a missing endpoint: "
                f"{relation['alias']} -> {relation['canonical']}"
            )
            continue
        if digest(alias) != digest(canonical):
            failures.append(
                f"alias differs from canonical: "
                f"{relation['alias']} -> {relation['canonical']}"
            )

    if failures:
        print("ARCHIVE VERIFICATION FAILED")
        for failure in failures:
            print(f"- {failure}")
        return 1

    print(f"PASS: {len(entries)} tracked files match SHA256SUMS")
    print(f"PASS: {len(alias_data['aliases'])} declared aliases match canonical files")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
