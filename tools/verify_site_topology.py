#!/usr/bin/env python3
"""Validate the source or staged output of the site-topology renderer."""
from __future__ import annotations

import argparse
import importlib.util
import sys
from pathlib import Path


DEFAULT_ROOT = Path(__file__).resolve().parents[1]
sys.dont_write_bytecode = True


def renderer_for(root: Path):
    path = root / "tools/render_site_topology.py"
    spec = importlib.util.spec_from_file_location("site_topology_renderer", path)
    if spec is None or spec.loader is None:
        raise RuntimeError("cannot load site topology renderer")
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=DEFAULT_ROOT, help="site root; defaults to this repository")
    parser.add_argument("--mode", choices=("source", "staged"), required=True)
    args = parser.parse_args()
    root = args.root.resolve()
    renderer = renderer_for(root)
    manifest = renderer.load_manifest(root)
    renderer.validate_manifest(root, manifest, rendered_nav=args.mode == "staged")
    renderer.check_outputs(root, manifest)
    print("PASS: site topology", args.mode, "validation")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, RuntimeError, ValueError) as error:
        print("FAIL:", error)
        raise SystemExit(1)
