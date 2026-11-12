#!/usr/bin/env python3
"""Recompute Kernel v0.2: exact, self-contained checks for the 2x2 root algebra.

The claim table and its executable checks share one atom registry below.  This
keeps the machine-readable result, the Markdown ledger, and the stated scope
in one source of truth.

    python3 -I run_all.py                       # human-readable result table
    python3 -I run_all.py --json                # machine-readable result table
    python3 -I run_all.py --ledger              # generated Markdown ledger
    python3 -I run_all.py --check-ledger ledger.md
    python3 -I run_all.py --manifest            # release-oriented metadata

Core tier: Python standard library and integer arithmetic only.  S01 is an
optional symbolic SymPy tier: it reports SKIP when SymPy is absent, but FAIL
when SymPy is present and the symbolic identity does not reduce to zero.

Declared inputs:
    Q  = [[1,1],[1,0]]            C1 = [[0,-1],[1,0]]       Omega = -C1
    G  = [Q, Omega] = [C1, Q]     H  = G/sqrt(5)             S = H*C1
    Pi = [[1,0],[0,-1]]

The integer matrix T = G*C1 equals sqrt(5)*S, so the core tier does not
approximate irrational factors.  A PASS establishes only the atom's printed
claim at its printed scope; it does not add a physical identification.
"""
import argparse
import hashlib
import json
import sys
from pathlib import Path


VERSION = "Recompute Kernel v0.2"
SCRIPT = Path(__file__).resolve()


# ---------- exact 2x2 integer matrix helpers ----------
def mm(A, B):
    return [[sum(A[i][k] * B[k][j] for k in range(2)) for j in range(2)] for i in range(2)]


def add(A, B):
    return [[A[i][j] + B[i][j] for j in range(2)] for i in range(2)]


def sub(A, B):
    return [[A[i][j] - B[i][j] for j in range(2)] for i in range(2)]


def sc(k, A):
    return [[k * A[i][j] for j in range(2)] for i in range(2)]


def det(A):
    return A[0][0] * A[1][1] - A[0][1] * A[1][0]


def comm(A, B):
    return sub(mm(A, B), mm(B, A))


I2 = [[1, 0], [0, 1]]
Z2 = [[0, 0], [0, 0]]
Q = [[1, 1], [1, 0]]
C1 = [[0, -1], [1, 0]]
OM = sc(-1, C1)
PI = [[1, 0], [0, -1]]
G = comm(Q, OM)
T = mm(G, C1)  # = sqrt(5) * S


def fib(n):
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def luc(n):
    a, b = 2, 1
    for _ in range(n):
        a, b = b, a + b
    return a


# ---------- atoms: (id, claim, kind, establishes, does_not, fn) ----------
def a01():
    ok = G == [[-2, 1], [1, 2]] and comm(C1, Q) == G
    return ok, f"G={G}"


def a02():
    return mm(G, G) == sc(5, I2) and det(G) == -5, "G^2=5I, det G=-5"


def a03():
    C2 = mm(C1, C1)
    return C2 == sc(-1, I2) and mm(C2, C2) == I2 and OM == [[0, 1], [-1, 0]], "C1^2=-I, C1^4=I"


def a04():
    return mm(Q, Q) == add(Q, I2) and det(Q) == -1, "Q^2=Q+I, det Q=-1"


def a05():
    P = I2
    for n in range(1, 41):
        P = mm(P, Q)
        if P != add(sc(fib(n), Q), sc(fib(n - 1), I2)):
            return False, f"fails at n={n}"
    return True, "Q^n=F_n Q+F_(n-1) I, n=1..40"


def a06():
    for n in range(1, 41):
        if fib(n + 1) * fib(n - 1) - fib(n) ** 2 != (-1) ** n:
            return False, f"fails at n={n}"
    return True, "Cassini, n=1..40"


def a07():
    sym = T[0][1] == T[1][0]
    return mm(T, T) == sc(5, I2) and sym, f"T=G*C1={T}; T^2=5I => S^2=I, S symmetric"


def a08():
    anti = add(mm(T, G), mm(G, T)) == Z2
    gtg = mm(mm(G, T), G) == sc(-5, T)
    return anti and gtg, "TG+GT=0 and GTG=-5T"


def a09():
    gens = [C1, PI]
    seen = {tuple(map(tuple, I2))}
    frontier = [I2]
    while frontier:
        nxt = []
        for X in frontier:
            for g in gens:
                Y = mm(X, g)
                k = tuple(map(tuple, Y))
                if k not in seen:
                    seen.add(k)
                    nxt.append(Y)
        frontier = nxt
    neg = tuple(map(tuple, sc(-1, I2)))
    c1_inverse = mm(mm(C1, C1), C1)
    dihedral_relation = mm(mm(PI, C1), PI) == c1_inverse
    return (
        len(seen) == 8
        and neg in seen
        and mm(PI, PI) == I2
        and dihedral_relation
    ), f"|<C1,Pi>|={len(seen)}; Pi^2=I; Pi*C1*Pi=C1^(-1)"


def a10():
    N = 3000
    s1 = [m for m in range(1, N + 1) if fib(m) + fib(2 * m - 1) == m * m]
    s2 = [m for m in range(1, N + 1) if luc(m + 1) ** 2 + m * m == 1 + m * fib(2 * m + 1)]
    lhs, rhs = luc(5) ** 2 + 16, 1 + 4 * fib(9)
    return s1 == [4] and s2 == [4] and lhs == rhs == 137, f"solutions m<=3000: {s1},{s2}; both sides at m=4: {lhs},{rhs}"


def s01():
    try:
        import sympy as sp
    except ImportError:
        return None, "sympy not installed"
    s = sp.symbols("s", real=True)
    r5 = sp.sqrt(5)
    Gs, Cs = sp.Matrix(G), sp.Matrix(C1)
    H = Gs / r5
    S = H * Cs
    L = lambda t: sp.cosh(t) * sp.eye(2) + sp.sinh(t) * S
    e1 = (L(s).T * Gs * L(s) - Gs).applyfunc(lambda x: sp.simplify(x.rewrite(sp.exp)))
    e2 = (H * L(s) * H - L(-s)).applyfunc(lambda x: sp.simplify(x.rewrite(sp.exp)))
    return e1 == sp.zeros(2) and e2 == sp.zeros(2), "L(s)^T G L(s)=G and H L(s) H=L(-s), symbolic s"


def k01():
    return mm(G, G) == sc(6, I2), "control: G^2=6I"


def k02():
    return det(G) == 5, "control: det G=+5"


ATOMS = [
    ("A01", "G = [Q,Omega] = [C1,Q] = [[-2,1],[1,2]]", "exact-integer", "matrix equality from stated inputs", "any physical meaning of G", a01),
    ("A02", "G^2 = 5I and det G = -5", "exact-integer", "matrix equality from stated inputs", "any physical meaning of G", a02),
    ("A03", "C1^2 = -I, C1^4 = I, Omega = -C1", "exact-integer", "matrix equality", "identification of C1 with any physical rotation", a03),
    ("A04", "Q^2 = Q + I and det Q = -1", "exact-integer", "matrix equality", "role of Q beyond the algebra", a04),
    ("A05", "Q^n = F_n Q + F_(n-1) I for n = 1..40", "exact-finite-range", "equality for n=1..40", "the identity for all n (standard induction, not run here)", a05),
    ("A06", "Cassini: F_(n+1)F_(n-1) - F_n^2 = (-1)^n for n = 1..40", "exact-finite-range", "equality for n=1..40", "the identity for all n", a06),
    ("A07", "T = G*C1 satisfies T^2 = 5I and T symmetric; with S = T/sqrt5: S^2 = I", "exact-integer", "matrix equality after removing sqrt5 by scaling", "anything outside this scaling", a07),
    ("A08", "TG + GT = 0 and GTG = -5T (equivalent to S G = -G S and H S H = -S)", "exact-integer", "the two anticommutation identities used below", "nothing further", a08),
    ("A09", "<C1, Pi> is an 8-element dihedral matrix realization: Pi^2=I and Pi*C1*Pi=C1^(-1)", "exhaustive-closure", "the stated finite matrix-group relations and order by explicit generation", "a physical rotation or symmetry identification", a09),
    ("A10", "m = 4 is the only m in 1..3000 solving F_m+F_(2m-1)=m^2 and L_(m+1)^2+m^2=1+m*F_(2m+1); both sides give 137 at m=4", "exact-finite-range", "uniqueness on 1..3000; value at m=4", "uniqueness for all m (paper's growth-inequality argument, not run here)", a10),
    ("S01", "(optional, sympy) L(s)^T G L(s) = G and H L(s) H = L(-s) for symbolic s, L(s)=cosh(s) I + sinh(s) S", "exact-symbolic", "the identities for arbitrary real s", "nothing further", s01),
]
CONTROLS = [
    ("K01", "control, expected False: G^2 = 6I", "exact-integer", "that the runner reports False for a false relation", "-", k01),
    ("K02", "control, expected False: det G = +5", "exact-integer", "that the runner reports False for a false relation", "-", k02),
]


def tier(atom_id):
    return "optional-symbolic" if atom_id == "S01" else "core-stdlib"


def collect_rows():
    rows, valid = [], True
    for (atom_id, claim, kind, establishes, does_not, fn) in ATOMS:
        result, detail = fn()
        if result is None:
            status = "SKIP"
            accepted = True
        else:
            status = "PASS" if result else "FAIL"
            accepted = bool(result)
        rows.append({
            "id": atom_id,
            "claim": claim,
            "kind": kind,
            "tier": tier(atom_id),
            "establishes": establishes,
            "does_not_establish": does_not,
            "status": status,
            "detail": detail,
            "expectation": "true",
        })
        valid = valid and accepted
    for (atom_id, claim, kind, establishes, does_not, fn) in CONTROLS:
        result, detail = fn()
        accepted = not result
        rows.append({
            "id": atom_id,
            "claim": claim,
            "kind": kind,
            "tier": "core-stdlib",
            "establishes": establishes,
            "does_not_establish": does_not,
            "status": "EXPECTED_FALSE" if accepted else "UNEXPECTED_TRUE",
            "detail": detail,
            "expectation": "false",
        })
        valid = valid and accepted
    return rows, valid


def core_payload(rows):
    """Canonical core result object; the optional symbolic tier is excluded."""
    return [
        {
            "id": row["id"],
            "claim": row["claim"],
            "kind": row["kind"],
            "expectation": row["expectation"],
            "status": row["status"],
            "detail": row["detail"],
        }
        for row in rows
        if row["tier"] == "core-stdlib"
    ]


def digest_json(value):
    encoded = json.dumps(value, ensure_ascii=True, sort_keys=True, separators=(",", ":")).encode("utf-8")
    return hashlib.sha256(encoded).hexdigest()


def ledger():
    out = [
        "# Recompute Kernel v0.2",
        "",
        "This ledger is generated from the atom registry in `run_all.py`. Verify that this saved copy remains synchronized with:",
        "",
        "```sh",
        "python3 -I run_all.py --check-ledger ledger.md",
        "```",
        "",
        "`core-stdlib` means exact integer arithmetic and Python's standard library only. `exact-finite-range` records its stated interval exactly; it does not silently become an all-integers theorem. `optional-symbolic` reports `SKIP` only when SymPy is unavailable.",
        "",
        "| id | claim | check kind | establishes | does not establish |",
        "|---|---|---|---|---|",
    ]
    for (atom_id, claim, kind, establishes, does_not, fn) in ATOMS + CONTROLS:
        out.append(f"| {atom_id} | {claim} | {kind} | {establishes} | {does_not} |")
    return "\n".join(out) + "\n"


def human_table(rows):
    lines = [VERSION, "DECLARED_INPUTS Q, C1, Omega=-C1, Pi; all core entries use integer arithmetic."]
    for row in rows:
        lines.append(f"{row['id']}  {row['status']}  [{row['kind']}]  {row['detail']}")
    return "\n".join(lines)


def manifest(rows, valid):
    return {
        "schema": "coppalini-recompute-kernel/v0.2",
        "version": VERSION,
        "entrypoint": "python3 -I run_all.py",
        "declared_inputs": {"Q": Q, "C1": C1, "Omega": OM, "Pi": PI},
        "core_table_sha256": digest_json(core_payload(rows)),
        "ledger_sha256": hashlib.sha256(ledger().encode("utf-8")).hexdigest(),
        "script_sha256": hashlib.sha256(SCRIPT.read_bytes()).hexdigest(),
        "result": "PASS" if valid else "FAIL",
        "atoms": rows,
    }


def main(argv):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ledger", action="store_true", help="print the generated Markdown ledger")
    parser.add_argument("--check-ledger", metavar="PATH", help="verify a saved ledger against this atom registry")
    parser.add_argument("--json", action="store_true", help="print the machine-readable result object")
    parser.add_argument("--manifest", action="store_true", help="print result metadata, hashes, and atom rows as JSON")
    args = parser.parse_args(argv)

    if args.ledger:
        print(ledger(), end="")
        return 0

    if args.check_ledger:
        expected = ledger().encode("utf-8")
        try:
            observed = Path(args.check_ledger).read_bytes()
        except OSError as error:
            print(f"LEDGER_SYNC FAIL  {error}")
            return 1
        if observed != expected:
            print("LEDGER_SYNC FAIL  saved ledger differs from generated atom registry")
            return 1
        print("LEDGER_SYNC PASS  saved ledger exactly matches generated atom registry")
        print("LEDGER_SHA256 " + hashlib.sha256(expected).hexdigest())
        return 0

    rows, valid = collect_rows()
    record = manifest(rows, valid)
    if args.json or args.manifest:
        print(json.dumps(record, indent=2, ensure_ascii=False, sort_keys=True))
    else:
        print(human_table(rows))
        print("CORE_TABLE_SHA256 " + record["core_table_sha256"])
        print("LEDGER_SHA256 " + record["ledger_sha256"])
    return 0 if valid else 1


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
