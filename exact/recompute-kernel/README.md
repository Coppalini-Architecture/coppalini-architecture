# Recompute Kernel v0.2

A small, from-scratch reading surface for the Coppalini Architecture 2×2 root algebra. The stated inputs, executable checks, human ledger, machine record, and result fingerprints are carried by this packet.

```sh
sha256sum -c SHA256SUMS
python3 -I run_all.py
python3 -I run_all.py --check-ledger ledger.md
python3 -I run_all.py --json
```

The core tier uses Python's standard library and exact integer arithmetic only. It reports A01–A10 plus two public negative controls. A valid run ends with `CORE_TABLE_SHA256` and `LEDGER_SHA256`; the core result fingerprint is identical when optional SymPy is unavailable.

`S01` is an optional symbolic check of the continuous `L(s)` identities. It reports `SKIP` when SymPy is absent. If SymPy is present, a nonzero symbolic remainder makes the run fail.

## What the packet establishes

- Exact matrix identities for the declared matrices `Q`, `C1`, `Omega = -C1`, `G = [Q, Omega]`, and `T = G*C1`.
- Finite-range Fibonacci and Cassini checks with their interval printed in the claim.
- An exhaustive eight-element dihedral matrix realization of `<C1, Pi>`.
- A bounded search record for the two stated 137 identities, including its explicit domain `1..3000`.

Each atom states its own boundary in `ledger.md`. In particular, a finite-range check remains a finite-range check, and these algebraic computations do not add a physical identification.

## Reader contract

`run_all.py` is the source of truth for atoms and scopes. `ledger.md` is generated from that registry and can be checked byte-for-byte with `--check-ledger`. `manifest.json` provides stable JSON for a machine reader. `SHA256SUMS` binds the released files themselves.

The hashes are integrity and comparison aids: they let a reader compare a recomputed table or a retained artifact without interpreting prose. Direct computation remains the evidence for each listed relation.
