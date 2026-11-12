# R51.1 Architecture redirect repair — review candidate

## Candidate status

Prepared for review. R51.1 has not been published. Its Netlify runtime
verification remains pending. This is a routing and publication-metadata repair.

## Exact source

- Base: the approved archive coppalini-r51-exact-read-and-indexing-candidate.zip.
- Base archive SHA-256:
  9da43a94374cc48f5bc72c1092c19756635bb3bc41dea56b15914059b160f5fe.
- The R51 archive is preserved unchanged.

## Retained R51 publication receipt

The following records the observed R51 deployment; it is historical evidence
for that release.

- Netlify deploy ID: 6af4d0b2f71b6466b5795679.
- Netlify publication display: “Nov 11, 2026 at 3:31 PM” (UI display).
  This records the display without assigning an exact UTC publication time.
- Deploy record:
  <https://app.netlify.com/projects/legendary-daifuku-2ff888/deploys/6af4d0b2f71b6466b5795679>.
- The live browser check was complete by the tool clock
  2026-11-11 20:32:41 UTC.
- The browser exact check began ready, ran on explicit button activation, and
  displayed PASS for four identities.
- The deployed manifest, JavaScript, read registry, sitemap, and Exact Reader
  HTML were byte-identical to the approved ZIP.
- The sitemap contained 106 unique URLs.
- Four selected file aliases returned 301 followed by 200.
- /architecture/index.html returned 301 to /architecture; that destination
  then returned 301 to itself, producing a redirect loop.

## Witnessed cause and minimum correction

The released redirects contained:

    /architecture/  /architecture  301!

Netlify normalizes trailing slashes before matching redirect rules. Its
official documentation gives this same slash-only forced-redirect pattern as
an infinite-loop example:

<https://docs.netlify.com/manage/routing/redirects/redirect-options/#trailing-slash>

R51.1 removes only that routing rule. The canonical /architecture, both
Architecture compatibility body files, and these file aliases remain:

    /architecture.html        /architecture  301!
    /architecture/index.html  /architecture  301!

The local validator now compares redirect endpoints and chains after the
documented trailing-slash normalization. The former offending rule is the
negative control for this repair. The local check rejected that rule after
slash normalization and accepted the corrected redirect graph.

## Publication bindings

- The manifest format and URL remain v0.2.
- The website release is R51.1.
- The manifest records the updated publication-builder SHA-256.
- SHA256SUMS is regenerated after all candidate files are final.
- The five scientific audit records, mathematical source files, verifier
  implementations, saved scientific receipts, and their hashes remain unchanged.
- No mathematical verifier is rerun for this routing repair.

## Local validation and runtime boundary

The existing publication validator checks canonical routes, redirects, sitemap,
artifact and receipt hashes, archive-member equality, Exact Reader current and
historical bindings, and the complete payload checksum inventory.

After any separately authorized deployment, the runtime check must confirm
that /architecture resolves successfully and that /architecture.html,
/architecture/index.html, and /architecture/ terminate successfully without
a redirect loop. Netlify's automatic slash handling is a runtime observation;
this local receipt does not declare it already tested for R51.1.
