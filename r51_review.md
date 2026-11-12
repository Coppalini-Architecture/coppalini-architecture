# R51 · Exact Reader and indexing repair

## Review state

Prepared for review on 11 November 2026. Production has not been changed by this task.
Target: the existing Netlify project `legendary-daifuku-2ff888`, https://eulershiddenl.ink/.
Publish the complete ZIP contents as the site root after package-specific approval.

## Baseline

- Live page content matches the R49.2 source after Netlify's HTML-link rewriting.
- R49.2 source archive SHA-256: `92f351d360c64e169cde599c48e2172a11819fd76e0f536efa5d7ed949d7ea98`.
- This candidate carries forward the staged R50 discovery changes, then applies the bounded R51 presentation and metadata corrections.
- R50 source archive SHA-256: `ff14dc91fb52172ab30b27602229321a47b37f51f4cf1542a18ae5f01ba991e8`.
- Fresh live homepage SHA-256: `676e91db732c45b4515ed4dd0a7c2fee5b680ca6e2990dead6a5441903f3099c` (19,708 bytes).

## Witnessed defects and repairs

1. Live robots.txt advertises `/sitemap.xml`, which returned 404. The candidate supplies a sitemap with canonical HTML and unique public PDFs. Source, verifier, JSON, and ZIP objects remain directly linked from their reading pages and indexes.
2. Live subpage canonicals were relative and duplicate `.html`/`index.html` routes returned 200. The candidate supplies absolute canonical URLs, aligned HTML/structured-data links, and explicit 301 aliases. `/architecture` is the single selected Architecture route. Sitemap dates are omitted where content-change dates are not established.
3. The Exact Reader originally exposed a loading placeholder in static HTML and literal backslash-n output separators. The candidate presents the inputs and declared result in HTML, and runs the browser calculation only when the button is activated. The execution checks the displayed input against CA-ALG-001 and compares the computed output with the displayed declared result. Wrong displayed results, changed inputs, and malformed inputs are rejected.
4. The current registry index explicitly locates the three Exact Reader records, five Four Dual Forms claims across four papers, five released audit packages, and seven historical R28 preparation claims. Every source registry retains its own schema and edition.
5. Reader contract v1.2.0 generalizes the source-edition rule. The earlier contract, registry, JavaScript implementation, and verification index have byte-preserved historical copies. Verification manifest v0.2 carries the current bindings and the archived v0.1 contract relationship.
6. The homepage points to the current source inventory. The Audit Register displays v0.2 consistently and links the W-0, W-1, and NDA-3 receipts. Architecture's unfinished staging sentence is removed. The Library's program-shelf route points to Architecture.

## Verification performed

- Real browser: the initial status is ready; activating the check reproduces G, G², trace, and determinant and reports PASS.
- Narrow layout: inspected at a 340 CSS-pixel viewport; document client width and scroll width both 337 pixels.
- UI contract tests: both matrix pages agree with the machine-readable record; ready-before-activation, exact output, three negative witnesses, and restored-reference behavior pass.
- Required navigation and asset links from nine primary/Exact Reader pages resolve to local payload files.
- 115 scientific payload files from R49.2 (paper PDFs/sources, source archives, verification files) are byte-identical. The 97 embedded program script blocks checked outside Exact Reader are unchanged.
- Publication builder verifies canonical resolution, redirect targets and absence of chains/loops, sitemap contents, five artifact/receipt/archive-member bindings, current and historical Exact Reader hashes, and the final SHA256SUMS inventory.
- The published scientific assertions, commands, source ZIPs, and recorded verification results retain their source-owned strength.

## Reproduce the release checks

```sh
python3 -I tools/build_r51_exact_read.py --validate-only
node tools/test_exact_reader.cjs
sha256sum -c SHA256SUMS
```

The active publication builder is `tools/build_r51_exact_read.py`. It replaces the R50 builder for subsequent edits to this candidate. Run it after payload changes to refresh current metadata and checksums.

## Remaining URL-level question

Historical indexing categories require affected-URL evidence. This release addresses the live defects observed above; the historical noindex URL remains unidentified.

## Technical references

- Google canonicalization: https://developers.google.com/search/docs/crawling-indexing/consolidate-duplicate-urls
- Google sitemap guidance: https://developers.google.com/search/docs/crawling-indexing/sitemaps/build-sitemap
- Netlify redirect rules: https://docs.netlify.com/manage/routing/redirects/overview/

The existing papers, source packages, and verification records remain the scientific authorities; this receipt documents the website repair.
