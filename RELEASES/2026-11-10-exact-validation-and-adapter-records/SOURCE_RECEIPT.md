# A1/H CODATA raw-source custody bundle · v0.1

**Retrieved (UTC):** 11 November 2026
**Status:** raw-source material retained after the v0.5 freeze. This is a custody and identity receipt only: it contains no transcribed constant value, no extracted uncertainty, no model calculation, no ASD response, and no HO-1 material.

## Protocol binding

| Item | Binding |
|---|---|
| Active protocol | `A1H_PREREGISTRATION_v0_5.md`, SHA-256 `434ce73456aab7ff4ed1e36f8d2afa738f210003fe7599f2beff9d723336296a` |
| Freeze commit | [`ba5d7175fcb2d8039a3fbd074b5bf4bade748f59`](https://github.com/Coppalini-Architecture/coppalini-architecture/commit/ba5d7175fcb2d8039a3fbd074b5bf4bade748f59) |
| Authority asserted by the retained pages | NIST CODATA 2022 Web values |
| Retrieval method | `curl -sS -L --fail`; each raw response was written directly to the named file below |

## Retained source pages

| Input | Raw file | Requested/effective URL | UTC interval | HTTP | Title identity | Edition marker | Uncertainty field | SHA-256 |
|---|---|---|---|---:|---|---|---|---|
| \(R_\infty\) | `raw/ryd.html` | `https://physics.nist.gov/cgi-bin/cuu/Value?ryd` | 00:07:53–00:07:58 | 200 | `CODATA Value: Rydberg constant` | 2022 | present | `9edc3907eead2382e56682c6c59362e2ae1cbf33b240a1d8670c44ee21d7f967` |
| \(a_0\) | `raw/bohrrada0.html` | `https://physics.nist.gov/cgi-bin/cuu/Value?bohrrada0` | 00:07:58–00:08:01 | 200 | `CODATA Value: Bohr radius` | 2022 | present | `1b3a232e270bde869bf67a4823a10da1c9ac0f20b055186e1b5e8115264698c1` |
| \(m_p/m_e\) | `raw/mpsme.html` | `https://physics.nist.gov/cgi-bin/cuu/Value?mpsme` | 00:08:01–00:08:05 | 200 | `CODATA Value: proton-electron mass ratio` | 2022 | present | `77cb4af406c6ae20dafb1e41197fd2e871e7de0d7b55e3e6714b7801be05bd4a` |
| \(m_d/m_e\) | `raw/mdsme.html` | `https://physics.nist.gov/cgi-bin/cuu/Value?mdsme` | 00:08:05–00:08:08 | 200 | `CODATA Value: deuteron-electron mass ratio` | 2022 | present | `3d07b0147aa245746890e823e7001bf8a3081c09b398c88db2bdef4cfbac74b0` |

The retained bytes are the source of the four finite-decimal values and standard uncertainties. This receipt deliberately records page identity and integrity without independently transcribing, normalizing, or calculating from those fields.

## Custody boundary

- The pages are held intact in `raw/`; the table above is an identity index, not a substitute for their content.
- `SHA256SUMS` binds this receipt and all four raw files.
- A Phase 2 model receipt may use only these four hashes as its CODATA inputs, extract their values in its own recorded parse step, hash its parser and fixtures, and perform the frozen base-10 calculation.
- The ASD levels response, ASD Version History page, and HO-1 source remain unopened here.
