# Root28 local compiler receipt — v0.1

**Date:** 2026-11-21
**Status:** local candidate; no commit, deployment, or external replay

## Bound artifacts

| Artifact | SHA-256 |
|---|---|
| `research/metric-minimum-root28-v0.1.json` | `32e9d3c14f0d44aab329d18b0f15011fffd6d0be4344d9b97c0836025a2667f0` |
| `research/metric-minimum-root28-v0.1.md` | `6275a056815fe3706d3691dedcbd9a15e09c4678fe96341b4b77c2cf3236bcbf` |
| `proofs/Root28Reader.lean` | `ce5ccd993439e7e1643a6ee45583f7fd9390a46b97f59fcdefd303ed27e34447` |
| `verification/root28/check_root28.py` | `545d92895162c1a2e66750a80e220e47652d071e36990289525bf18f03efa983` |
| local `build/proofs/Root28Reader.olean` | `356f8d1e061bf3d682ca56ce617c86d8e38c7aa1726f9130b35b7c4cbf83d7da` |

The manifest's canonical JSON digest is
`1f0e02d6be0fba44efabe67bc700d178e2624a4d585b8989dd2f466f9fef6ef1`.
`Root28Reader.lean` embeds that digest; the Python verifier refuses a manifest
whose canonical digest differs from the declared Lean binding.

## Replayed local checks

```text
python3 -I verification/root28/check_root28.py --self-test
PASS ROOT28.1–ROOT28.7
PASS 8/8 refusal controls
PASS 28/28 reader obligations passed

lean --root=. -o build/proofs/Root28Reader.olean proofs/Root28Reader.lean
'Root28Reader.root28_punchcard' does not depend on any axioms
```

The check recomputes the K8 scan, integer root identities, scaled axial
identities, card status partition, source-path retention, and the declared
display legend. The refusal controls cover missing/duplicate cards, broken
scanner residue, boundary promotion, transport-coordinate collapse, external
claim promotion, non-bijective display legend, and manifest/Lean digest drift.

## Scope

This is a reader receipt. It does not instantiate `SmoothCompletion`, assert
an identity between the finite mirror and the geometric cup, prove a physical
colour relation, or replay an external formalization.
