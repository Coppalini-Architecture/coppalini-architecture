"""MOONLIGHT relax receipt: one relax step on (q, s, d) at schedule index k  (local draft, O-X6 of RELAX-001).

State: phase q in 0..3, tone sector s in 0..136, offset d in [-1/2, 1/2) from the tone, address a = s + 137*((q - s) mod 4).
Relax step k (2 <= k <= 300):  q' = q + 2 mod 4 (half-turn, N2),  s' = s,  d' = (Fib_{k-1}/Fib_k) * d,  a' = addr(q', s').
kappa_k = 1 - Fib_{k-1}/Fib_k = Fib_{k-2}/Fib_k, the HARMONIZER-001 pull on the plateau.  Exact fractions throughout.
Display-side and one-way.  No clock.  Run:  python3 -I relax_receipt.py
"""
import re
from fractions import Fraction as F
from math import gcd

Q, S, N = 4, 137, 548
KMIN, KMAX = 2, 300
SCHEMA = "CoppaliniArchitecture.MOONLIGHT-Relax-Receipt/v0.1"
RULE = {"id": "fibonacci_quotient_relax", "schedule": "rho_k=Fib_{k-1}/Fib_k"}
CHECKS = {"s_preserved": True, "address_relation_input": True, "address_relation_output": True, "non_expansion": True}
TOP = {"schema", "rule", "input", "trace", "recomputed", "recorded", "checks", "delta", "reader"}
OUT = {"q", "s", "a", "d"}
FRA = re.compile(r"-?(0|[1-9][0-9]*)/[1-9][0-9]*")
FIB = [0, 1]
for _ in range(KMAX + 2):
    FIB.append(FIB[-1] + FIB[-2])


def addr(q, s):
    return s + S * ((q - s) % Q)


def fs(f):
    return "%d/%d" % (f.numerator, f.denominator)


def unfs(text):
    """Canonical reduced fraction text -> Fraction, else None."""
    if type(text) is not str or len(text) > 200 or not FRA.fullmatch(text):
        return None
    n, d = text.split("/")
    n, d = int(n), int(d)
    if gcd(abs(n), d) != 1:
        return None
    v = F(n, d)
    return v if fs(v) == text else None


def rho(k):
    return F(FIB[k - 1], FIB[k])


def step(q, s, d, k):
    q2 = (q + 2) % Q
    return {"q": q2, "s": s, "a": addr(q2, s), "d": fs(rho(k) * d)}


def make_receipt(q, s, d, k, label, recorded=None):
    want = step(q, s, d, k)
    rec = want if recorded is None else dict(recorded)
    return {
        "schema": SCHEMA,
        "rule": dict(RULE),
        "input": {"q": q, "s": s, "a": addr(q, s), "d": fs(d), "k": k},
        "trace": {"rho": fs(rho(k)), "kappa": fs(1 - rho(k)), "phase_step": 2},
        "recomputed": want,
        "recorded": rec,
        "checks": dict(CHECKS),
        "delta": [] if rec == want else [{"recorded": dict(rec), "recomputed": dict(want)}],
        "reader": {"label": label},
    }


def _int(v, lo, hi):
    return type(v) is int and lo <= v <= hi


def same(a, b):
    if type(a) is not type(b):
        return False
    if isinstance(a, dict):
        return a.keys() == b.keys() and all(same(a[k], b[k]) for k in a)
    if isinstance(a, list):
        return len(a) == len(b) and all(same(x, y) for x, y in zip(a, b))
    return a == b


def _out_ok(o):
    if not isinstance(o, dict) or set(o) != OUT:
        return False
    if not (_int(o["q"], 0, 3) and _int(o["s"], 0, S - 1) and _int(o["a"], 0, N - 1)) or o["a"] != addr(o["q"], o["s"]):
        return False
    d = unfs(o["d"])
    return d is not None and abs(d) <= F(1, 2)


def check(rc):
    """Return OK, OK_WITH_DELTA or INVALID for a relax receipt."""
    try:
        if rc.get("schema") != SCHEMA or set(rc) != TOP or not same(rc["rule"], RULE):
            return "INVALID"
        rd = rc["reader"]
        if not isinstance(rd, dict) or set(rd) != {"label"} or type(rd["label"]) is not str or not rd["label"].strip():
            return "INVALID"
        i = rc["input"]
        if not isinstance(i, dict) or set(i) != {"q", "s", "a", "d", "k"}:
            return "INVALID"
        if not (_int(i["q"], 0, 3) and _int(i["s"], 0, S - 1) and _int(i["a"], 0, N - 1) and _int(i["k"], KMIN, KMAX)):
            return "INVALID"
        d = unfs(i["d"])
        if d is None or not (-F(1, 2) <= d < F(1, 2)) or i["a"] != addr(i["q"], i["s"]):
            return "INVALID"
        want = step(i["q"], i["s"], d, i["k"])
        tr = {"rho": fs(rho(i["k"])), "kappa": fs(1 - rho(i["k"])), "phase_step": 2}
        rec, rcp, dl = rc["recorded"], rc["recomputed"], rc["delta"]
        if not (_out_ok(rec) and _out_ok(rcp)):
            return "INVALID"
        if not same(rcp, want) or not same(rc["trace"], tr) or not same(rc["checks"], CHECKS) or not isinstance(dl, list):
            return "INVALID"
        if same(rec, rcp):
            return "OK" if dl == [] else "INVALID"
        return "OK_WITH_DELTA" if same(dl, [{"recorded": rec, "recomputed": rcp}]) else "INVALID"
    except (KeyError, TypeError, AttributeError):
        return "INVALID"


def main():
    import random
    rnd = random.Random(20261125)
    half = F(1, 2)
    n_ok = n_delta = n_empty = n_wit = 0
    for _ in range(400):
        q, s, k = rnd.randrange(4), rnd.randrange(S), rnd.randrange(KMIN, KMAX + 1)
        d = F(rnd.randrange(-500, 500), 1000)
        rc = make_receipt(q, s, d, k, "check")
        assert check(rc) == "OK"
        n_ok += 1
        w = rc["recomputed"]
        for _ in range(15):
            q2, s2 = rnd.randrange(4), rnd.randrange(S)
            rec = {"q": q2, "s": s2, "a": addr(q2, s2), "d": fs(F(rnd.randrange(-500, 501), 1000))}
            if rec == w:
                continue
            rc["recorded"] = rec
            rc["delta"] = [{"recorded": dict(rec), "recomputed": dict(w)}]
            assert check(rc) == "OK_WITH_DELTA"
            n_delta += 1
            rc["delta"] = []
            assert check(rc) == "INVALID"
            n_empty += 1
            rc["delta"] = [{"recorded": dict(rec), "recomputed": dict(w, d="1/3")}]
            assert check(rc) == "INVALID"
            n_wit += 1
        rc["recorded"] = dict(w)
        rc["delta"] = []
        assert check(rc) == "OK"
    print("honest receipts OK:", n_ok)
    print("wrong recorded output, true delta -> OK_WITH_DELTA:", n_delta)
    print("same, empty delta -> INVALID:", n_empty)
    print("same, wrong recomputed in delta -> INVALID:", n_wit)
    base = make_receipt(1, 5, F(1, 4), 10, "x")

    def mut(f):
        x = make_receipt(1, 5, F(1, 4), 10, "x")
        f(x)
        return check(x)
    cases = {
        "extra top key": lambda x: x.update(extra=1), "missing delta": lambda x: x.pop("delta"),
        "label int": lambda x: x["reader"].update(label=5), "label blank": lambda x: x["reader"].update(label=" "),
        "checks int 1": lambda x: x["checks"].update(non_expansion=1), "checks false": lambda x: x["checks"].update(s_preserved=False),
        "rule changed": lambda x: x["rule"].update(schedule="rho_k=1/2"),
        "q True": lambda x: x["input"].update(q=True), "q float": lambda x: x["input"].update(q=1.0),
        "k 1": lambda x: x["input"].update(k=1), "k 301": lambda x: x["input"].update(k=301), "k True": lambda x: x["input"].update(k=True),
        "a wrong": lambda x: x["input"].update(a=x["input"]["a"] + 1),
        "d 1/2 (out of [-1/2,1/2))": lambda x: x["input"].update(d="1/2"), "d non-reduced": lambda x: x["input"].update(d="2/8"),
        "d -0/1": lambda x: x["input"].update(d="-0/1"), "d decimal": lambda x: x["input"].update(d="0.25"), "d int": lambda x: x["input"].update(d=0),
        "trace rho off": lambda x: x["trace"].update(rho="1/2"), "trace phase_step 3": lambda x: x["trace"].update(phase_step=3),
        "recomputed d off": lambda x: x["recomputed"].update(d="1/7"),
        "recorded extra key": lambda x: x["recorded"].update(extra=1),
        "recorded a inconsistent": lambda x: x["recorded"].update(a=0),
        "recorded d -0/1": lambda x: x["recorded"].update(d="-0/1"),
        "recorded d |d|>1/2": lambda x: x["recorded"].update(d="3/4"),
        "delta not list": lambda x: x.update(delta={}),
    }
    n_cases = 0
    for name, f in cases.items():
        v = mut(f)
        assert v == "INVALID", (name, v)
        n_cases += 1
    for bad in (None, [], "x", 5, {}):
        assert check(bad) == "INVALID"
        n_cases += 1
    print("type, key, label, range, canonical-fraction, trace and non-dict cases -> INVALID:", n_cases)
    print("ALL PASS")


if __name__ == "__main__":
    main()
