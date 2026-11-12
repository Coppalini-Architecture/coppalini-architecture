# R52 external metadata packet

This file specifies account-level changes that are intentionally outside the
static-site artifact. Apply each only in the named account and retain the
resulting platform receipt.

## GitHub repository

Target: `Coppalini-Architecture/coppalini-architecture`

### About panel

- Website: `https://eulershiddenl.ink`
- Topics: `mathematical-physics`, `symplectic-geometry`,
  `lorentzian-geometry`, `clifford-algebra`, `lean4`,
  `formal-verification`, `lie-algebra`, `gauge-theory`,
  `reproducible-research`

### README insertion

Insert immediately after the opening repository description:

```markdown
## Four Dual Forms / source-indexed entry

The shared finite root is \(G=[Q,\Omega]\), with
\(Q^2=Q+I\), \(G^2=5I\), and \(\det G=-5\) in the stated
two-by-two carrier. The released Four Dual Forms record comprises
[*Gravity Light*](https://eulershiddenl.ink/papers/four-dual-forms/gravity-light),
[*Memory Motion*](https://eulershiddenl.ink/papers/four-dual-forms/memory-motion),
[*Time Scope*](https://eulershiddenl.ink/papers/four-dual-forms/time-scope), and
[*Horizon Silence*](https://eulershiddenl.ink/papers/four-dual-forms/horizon-silence).
Each entry carries its PDF, TeX source, shared verifier, receipt, and declared
boundary. The released Zenodo record is
[10.5281/zenodo.24073596](https://doi.org/10.5281/zenodo.24073596).
```

### Citation handling

The root `CITATION.cff` is a repository-wide collection record. Keep it
repository-scoped unless the repository itself is formally versioned as the
same Zenodo object. Place the Four Dual Forms DOI in the README insertion and
in a paper-specific citation file or release notes; do not silently recast a
set-level Zenodo DOI as the DOI of every unrelated repository object.

### Release

When the Four Dual Forms source folder is fixed to a commit, publish a GitHub
release tagged `four-dual-forms-v0.3` that links its Zenodo record and names
the exact commit. The release should include or point to the same source
package named by the Zenodo record.

## Search-console submission set

Submit these canonical URLs after R52 is deployed:

```text
https://eulershiddenl.ink/
https://eulershiddenl.ink/anthony-vito-coppa
https://eulershiddenl.ink/library
https://eulershiddenl.ink/verify
https://eulershiddenl.ink/architecture
https://eulershiddenl.ink/papers/four-dual-forms/gravity-light
https://eulershiddenl.ink/papers/four-dual-forms/memory-motion
https://eulershiddenl.ink/papers/four-dual-forms/time-scope
https://eulershiddenl.ink/papers/four-dual-forms/horizon-silence
```

1. Verify `eulershiddenl.ink` as a DNS Domain property in Google Search
   Console and Bing Webmaster Tools.
2. Submit `https://eulershiddenl.ink/sitemap.xml` to both consoles.
3. Request inspection/indexing for the URLs above where each platform offers
   the operation.
4. Retain the verification, sitemap, inspection, and submission receipts.

## Zenodo related identifiers

Target record: `10.5281/zenodo.24073596`

- Add `https://eulershiddenl.ink/papers/four-dual-forms/gravity-light` as a
  website description of the release, or use the collection URL when the
  record metadata supports one.
- Add `https://github.com/Coppalini-Architecture/coppalini-architecture` as
  the public source/archive relation.
- Choose the relation type only after its Zenodo label is shown in the edit
  form; retain a screenshot or exported metadata receipt showing the chosen
  relation, URL, and version.

## Completion receipt

R52 static publication is complete when its archive checks pass. Search,
GitHub, and Zenodo completion remains a separate four-part receipt: account,
exact target, saved payload, and platform confirmation.
