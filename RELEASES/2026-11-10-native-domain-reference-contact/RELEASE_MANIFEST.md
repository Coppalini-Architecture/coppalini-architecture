# Release manifest

This directory is designed for one atomic Git commit on `Coppalini-Architecture/coppalini-architecture` branch `main`.

| Path | Role |
|---|---|
| `A1H_PREREGISTRATION_v0_2.md` | current frozen A1/H protocol |
| `A1H_PREREGISTRATION_v0_2.sha256` | sidecar hash of the current protocol |
| `NATIVE_DOMAIN_ADAPTER_ATLAS_v0_3.zip` | verified atlas package and its inherited closure receipts |
| `lineage/A1H_PREREGISTRATION_v0_1.md` | original frozen protocol |
| `lineage/A1H_PREREGISTRATION_v0_1.sha256` | original sidecar |
| `SHA256SUMS` | hashes of all release files other than itself |

The `SHA256SUMS` sidecar is the file-integrity receipt. Git’s commit hash is the external timestamp and tree receipt.
