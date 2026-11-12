# Recompute Kernel v0.2

This ledger is generated from the atom registry in `run_all.py`. Verify that this saved copy remains synchronized with:

```sh
python3 -I run_all.py --check-ledger ledger.md
```

`core-stdlib` means exact integer arithmetic and Python's standard library only. `exact-finite-range` records its stated interval exactly; it does not silently become an all-integers theorem. `optional-symbolic` reports `SKIP` only when SymPy is unavailable.

| id | claim | check kind | establishes | does not establish |
|---|---|---|---|---|
| A01 | G = [Q,Omega] = [C1,Q] = [[-2,1],[1,2]] | exact-integer | matrix equality from stated inputs | any physical meaning of G |
| A02 | G^2 = 5I and det G = -5 | exact-integer | matrix equality from stated inputs | any physical meaning of G |
| A03 | C1^2 = -I, C1^4 = I, Omega = -C1 | exact-integer | matrix equality | identification of C1 with any physical rotation |
| A04 | Q^2 = Q + I and det Q = -1 | exact-integer | matrix equality | role of Q beyond the algebra |
| A05 | Q^n = F_n Q + F_(n-1) I for n = 1..40 | exact-finite-range | equality for n=1..40 | the identity for all n (standard induction, not run here) |
| A06 | Cassini: F_(n+1)F_(n-1) - F_n^2 = (-1)^n for n = 1..40 | exact-finite-range | equality for n=1..40 | the identity for all n |
| A07 | T = G*C1 satisfies T^2 = 5I and T symmetric; with S = T/sqrt5: S^2 = I | exact-integer | matrix equality after removing sqrt5 by scaling | anything outside this scaling |
| A08 | TG + GT = 0 and GTG = -5T (equivalent to S G = -G S and H S H = -S) | exact-integer | the two anticommutation identities used below | nothing further |
| A09 | <C1, Pi> is an 8-element dihedral matrix realization: Pi^2=I and Pi*C1*Pi=C1^(-1) | exhaustive-closure | the stated finite matrix-group relations and order by explicit generation | a physical rotation or symmetry identification |
| A10 | m = 4 is the only m in 1..3000 solving F_m+F_(2m-1)=m^2 and L_(m+1)^2+m^2=1+m*F_(2m+1); both sides give 137 at m=4 | exact-finite-range | uniqueness on 1..3000; value at m=4 | uniqueness for all m (paper's growth-inequality argument, not run here) |
| S01 | (optional, sympy) L(s)^T G L(s) = G and H L(s) H = L(-s) for symbolic s, L(s)=cosh(s) I + sinh(s) S | exact-symbolic | the identities for arbitrary real s | nothing further |
| K01 | control, expected False: G^2 = 6I | exact-integer | that the runner reports False for a false relation | - |
| K02 | control, expected False: det G = +5 | exact-integer | that the runner reports False for a false relation | - |
