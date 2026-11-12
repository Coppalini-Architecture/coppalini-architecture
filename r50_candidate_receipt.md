# R50 Exact-Reader Crawler Contract — candidate receipt

## Status

Prepared for review. This candidate has not been deployed, submitted to a search console, or sent through an indexing notification service.

## Base

- Base candidate: R49.2.
- Base candidate archive SHA-256: `92f351d360c64e169cde599c48e2172a11819fd76e0f536efa5d7ed949d7ea98`.
- Production baseline: `https://eulershiddenl.ink/`.

## Discovery changes

1. `robots.txt` explicitly allows `OAI-SearchBot` and points to the now-present absolute sitemap.
2. `sitemap.xml` enumerates canonical public routes and released paper, source, receipt, registry, and verification assets.
3. Every non-variant HTML page carries an absolute canonical URL; missing canonical links are supplied.
4. `llms.txt` and `llms-full.txt` provide a compact source-first map for agents that elect to read them.
5. `research/verification-manifest-v0.1.json` binds the five released audit records to their artifact hash, public receipt, command, scope, and next-record list.
6. The homepage, Audit Register, Library, Architecture, Basis, Exact Reader, and author record expose matching author and JSON-LD identity/data relationships.
7. The public author record is `anthony-vito-coppa.html` and carries the exact name **Anthony Vito Coppa** in visible text, title, metadata, canonical URL, and structured data.

## Scope preservation

No released theorem, verifier, source package, result, artifact hash, command, receipt payload, or claim boundary is changed. The three receipt copies added under `research/audit/` are byte-identical extracts from their already released packets.

## Explicitly outside this candidate

- Deployment to production.
- Google Search Console or Bing Webmaster Tools verification and sitemap submission.
- IndexNow notification.
- Any change to the separate `GPTBot` / model-training crawl policy.
- Any change to mathematical or empirical claim strength.
