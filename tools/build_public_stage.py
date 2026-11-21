#!/usr/bin/env python3
"""Materialize the public static-site payload from a clean Git checkout.

The public payload contains tracked site material only.  The external-anchor
review packet is intentionally local-only and is rejected if it ever becomes
tracked in a deploy candidate.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import shutil
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SENTINEL = ".coppalini-public-stage"
REPOSITORY_ONLY_PREFIXES = (".github/",)
REPOSITORY_ONLY_NAMES = {".gitignore", "netlify.toml"}
FORBIDDEN_PUBLIC_PREFIXES = (
    "verification/external-anchor-receipt/",
    "proofs/ExternalAnchorReceipt.lean",
    "EXTERNAL_ANCHOR_SHA256SUMS",
    "EXTERNAL_ANCHOR_COMPILER_RECEIPT.md",
    "build/",
    "release/",
)


def fail(message: str) -> None:
    raise SystemExit(f"FAIL: {message}")


def git(*args: str) -> str:
    return subprocess.check_output(["git", "-C", str(ROOT), *args], text=True).strip()


def is_forbidden(relative: str) -> bool:
    return any(relative == item or relative.startswith(item) for item in FORBIDDEN_PUBLIC_PREFIXES)


def is_repository_only(relative: str) -> bool:
    return relative in REPOSITORY_ONLY_NAMES or any(relative.startswith(item) for item in REPOSITORY_ONLY_PREFIXES)


def file_digest(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def tree_digest(root: Path) -> tuple[str, int]:
    files: list[tuple[str, str]] = []
    for path in sorted(root.rglob("*")):
        if path.is_symlink():
            fail(f"symlink in staged payload: {path.relative_to(root)}")
        if path.is_file() and path.name not in {SENTINEL, "PUBLIC_STAGE_RECEIPT.json"}:
            files.append((path.relative_to(root).as_posix(), file_digest(path)))
    serial = "".join(f"{relative}\0{digest}\n" for relative, digest in files).encode("utf-8")
    return hashlib.sha256(serial).hexdigest(), len(files)


def clear_stage(stage: Path) -> None:
    if not stage.exists():
        return
    if not stage.is_dir():
        fail(f"stage target is not a directory: {stage}")
    if not (stage / SENTINEL).is_file():
        fail(f"refusing to clear a directory without {SENTINEL}: {stage}")
    shutil.rmtree(stage)


def tracked_files() -> list[str]:
    output = subprocess.check_output(["git", "-C", str(ROOT), "ls-files", "-z"])
    return sorted(item.decode("utf-8") for item in output.split(b"\0") if item)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", required=True, type=Path, help="fresh stage directory below the repository root")
    args = parser.parse_args()
    stage = args.output.resolve()
    try:
        stage.relative_to(ROOT)
    except ValueError:
        fail("stage directory must be below the repository root")
    if stage == ROOT:
        fail("repository root cannot be a stage directory")
    if git("status", "--porcelain"):
        fail("source checkout is dirty; build from a clean release commit")
    commit = git("rev-parse", "HEAD")
    files = tracked_files()
    forbidden = [relative for relative in files if is_forbidden(relative)]
    if forbidden:
        fail("local-only material is tracked in the release candidate: " + ", ".join(forbidden))
    clear_stage(stage)
    stage.mkdir(parents=True)
    (stage / SENTINEL).write_text("Coppalini Architecture public deploy stage\n", encoding="utf-8")
    for relative in files:
        if is_repository_only(relative):
            continue
        source = ROOT / relative
        if source.is_symlink():
            fail(f"symlink in source checkout: {relative}")
        target = stage / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, target)
    digest, count = tree_digest(stage)
    receipt = {
        "schema": "coppalini/public-stage/v0.1",
        "source_commit": commit,
        "source_state": "CLEAN_CHECKOUT",
        "file_count": count,
        "tree_sha256": digest,
        "excluded": list(FORBIDDEN_PUBLIC_PREFIXES),
    }
    (stage / "PUBLIC_STAGE_RECEIPT.json").write_text(json.dumps(receipt, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(f"PASS: staged {count} public files from {commit}; tree sha256 {digest}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
