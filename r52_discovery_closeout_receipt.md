# R52 · Discovery closeout candidate

Prepared 12 November 2026 from the R51.1 public-site candidate. This release
adds discovery metadata and paper entry points; it does not alter a scientific
source, executable verifier, recorded verification result, or an audit
artifact.

## Changed public records

- Four static paper records now exist for **Gravity Light**, **Memory Motion**,
  **Time Scope**, and **Horizon Silence**. Each exposes a canonical URL,
  visible title and abstract, Highwire citation metadata, a `ScholarlyArticle`
  record, a `SoftwareSourceCode` verifier record, the PDF, TeX source, shared
  verifier, receipt, and declared boundary.
- The Library and home carousel now route readers to those paper records while
  retaining direct PDF, source, verifier, receipt, and Zenodo links.
- `llms.txt` and `llms-full.txt` now use canonical public paths and list the
  four paper records.
- The author record now points to the current verification manifest v0.2.
- `sitemap.xml` retains the full canonical HTML and unique-PDF inventory and
  adds `lastmod` only to HTML routes changed or created by R52. The source
  declaration is `research/sitemap-lastmod-r52.json`.

## Citation scope

The per-paper pages cite `10.5281/zenodo.24073596` as the released Zenodo
record containing the four PDF editions. The DOI is visibly identified as the
release record; no separate per-paper DOI is invented.

## Retained boundary

Search metadata describes released sources and their declared scope. It is a
discovery surface, not a ranking guarantee or a replacement for the source,
verifier, receipt, or native evidence record.

## Reproduce

```sh
python3 -I tools/build_r52_discovery.py --validate-only
node tools/test_exact_reader.cjs
sha256sum -c SHA256SUMS
```

The R52 builder checks canonical URLs, redirects, citation fields, JSON-LD,
local source/verifier/receipt targets, sitemap route membership, permitted
`lastmod` values, robots policy, machine-reading pointers, integrity bindings,
and the full checksum inventory.

## External records intentionally not claimed complete

Search Console ownership/submission receipts, Bing submission receipts,
GitHub About/topics/release settings, and Zenodo Related Identifier edits are
account-level operations. They remain separate from this static release until
their own retained receipts exist.
