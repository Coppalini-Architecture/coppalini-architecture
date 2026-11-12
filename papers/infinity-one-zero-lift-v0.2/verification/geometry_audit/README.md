# Infinity One Zero Lift — source-grounded geometry audit

Start with AUDIT.md. Open incidence_reader.html locally to inspect all 28 comparisons, a single four-edge matching, or an individual scanner address. The SVG/PDF is a technical graph, not a new proposed cover.

- Exact mathematics and incidence: verify_graph.py, verification.json, verification.txt.
- Source-matching ledger: edge_ledger.csv.
- Exact spatial and page-display coordinates: graph_coordinates.json.
- Graph generation and template tests: build_graph.py, render_receipt.json.
- Measured style authority: COPPALINI_COVER_STYLE_REFERENCE.md, COPPALINI_COVER_STYLE_LOCK.json, COPPALINI_COVER_FRAME.svg, five original SVGs in references/.

Reproduce with `python -m pip install -r requirements.txt`, then `python verify_graph.py` and `python build_graph.py`. CairoSVG may need the Cairo system library. Mathematical verification uses SymPy only. No font files are distributed.

All new arithmetic assertions were checked exactly. This bundle carries no new Lean receipt and does not modify any published source.
