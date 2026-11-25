"""MOONLIGHT harmonizer: H(q, x; h, kappa) -> (a, y)  (local draft, HARMONIZER-001).

Carrier relation (as in the Iris Dome): a = s + 137*((q - s) mod 4).
q is fixed; x is an exact rational phase coordinate in iris-sector units; h, kappa are fresh scalars.

  x0 = x mod 137                         in [0, 137)
  k  = floor(x0 + 1/2)                   (tie rule: a half goes to the larger sector)
  s  = k mod 137                         selected sector, on-carrier
  d  = x0 - k                            in [-1/2, 1/2)
  m  = |d|
  w  = kappa                             if m <= h
     = kappa * S((1/2 - m)/(1/2 - h))    if h < m < 1/2,   S(u) = 3u^2 - 2u^3
  y  = (x0 - w*d) mod 137                off-carrier value coordinate
  a  = s + 137*((q - s) mod 4)           on-carrier address

h in [0, 1/2], kappa in [0, 1], x a finite decimal literal.  All arithmetic is exact (Fraction).
Display-side and one-way.  No clock.  Run:  python3 -I harmonizer.py
"""
import re
from fractions import Fraction as F
from math import gcd, floor

Q, S, N = 4, 137, 548
SCHEMA = "CoppaliniArchitecture.MOONLIGHT-Harmonizer-Receipt/v0.1"
RULE = {"id": "nearest_sector_pull", "tie": "half_up", "profile": "plateau_smoothstep"}
CHECKS = {"q_preserved": True, "address_relation": True}
TOP = {"schema", "rule", "input", "trace", "recomputed", "recorded", "checks", "delta", "reader"}
OUT = {"s", "a", "y"}
DEC = re.compile(r"-?(0|[1-9][0-9]*)(\.[0-9]+)?")
FRA = re.compile(r"-?(0|[1-9][0-9]*)/[1-9][0-9]*")


def addr(q, s):
    return s + S * ((q - s) % Q)


def dec(text, lo=None, hi=None):
    """Exact value of a finite decimal literal, or None."""
    if type(text) is not str or len(text) > 64 or not DEC.fullmatch(text):
        return None
    sign = -1 if text[0] == "-" else 1
    body = text.lstrip("-")
    ip, _, fp = body.partition(".")
    v = sign * F(int(ip + fp), 10 ** len(fp))
    if (lo is not None and v < lo) or (hi is not None and v > hi):
        return None
    return v


def fs(f):
    return "%d/%d" % (f.numerator, f.denominator)


def unfs(text):
    if type(text) is not str or len(text) > 200 or not FRA.fullmatch(text):
        return None
    n, d = text.split("/")
    n, d = int(n), int(d)
    if gcd(abs(n), d) != 1:
        return None
    v = F(n, d)
    return v if fs(v) == text else None          # canonical text only: "-0/1" is not "0/1"


def smooth(u):
    return 3 * u * u - 2 * u * u * u


def H(q, x, h, kappa):
    """x, h, kappa are exact Fractions."""
    x0 = x % S
    k = floor(x0 + F(1, 2))
    s = k % S
    d = x0 - k
    m = abs(d)
    if m <= h:
        w = kappa
    else:
        w = kappa * smooth((F(1, 2) - m) / (F(1, 2) - h))
    y = (x0 - w * d) % S
    return {"x0": x0, "s": s, "d": d, "w": w, "y": y, "a": addr(q, s)}


def out_record(r):
    return {"s": r["s"], "a": r["a"], "y": fs(r["y"])}


def make_receipt(q, x, h, kappa, label, recorded=None):
    r = H(q, dec(x), dec(h), dec(kappa))
    want = out_record(r)
    rec = want if recorded is None else dict(recorded)
    return {
        "schema": SCHEMA,
        "rule": dict(RULE),
        "input": {"q": q, "x": x, "h": h, "kappa": kappa},
        "trace": {"x_mod": fs(r["x0"]), "d": fs(r["d"]), "w": fs(r["w"])},
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


def _out_ok(q, o):
    if not isinstance(o, dict) or set(o) != OUT:
        return False
    if not (_int(o["s"], 0, S - 1) and _int(o["a"], 0, N - 1)) or o["a"] != addr(q, o["s"]):
        return False
    y = unfs(o["y"])
    return y is not None and 0 <= y < S


def check(rc):
    """Return OK, OK_WITH_DELTA or INVALID for a harmonizer receipt."""
    try:
        if rc.get("schema") != SCHEMA or set(rc) != TOP or not same(rc["rule"], RULE):
            return "INVALID"
        rd = rc["reader"]
        if not isinstance(rd, dict) or set(rd) != {"label"} or type(rd["label"]) is not str or not rd["label"].strip():
            return "INVALID"
        i = rc["input"]
        if not isinstance(i, dict) or set(i) != {"q", "x", "h", "kappa"} or not _int(i["q"], 0, 3):
            return "INVALID"
        x, h, k = dec(i["x"]), dec(i["h"], 0, F(1, 2)), dec(i["kappa"], 0, 1)
        if x is None or h is None or k is None:
            return "INVALID"
        r = H(i["q"], x, h, k)
        want = out_record(r)
        tr = {"x_mod": fs(r["x0"]), "d": fs(r["d"]), "w": fs(r["w"])}
        rec, rcp, d = rc["recorded"], rc["recomputed"], rc["delta"]
        if not (_out_ok(i["q"], rec) and _out_ok(i["q"], rcp)):
            return "INVALID"
        if not same(rcp, want) or not same(rc["trace"], tr) or not same(rc["checks"], CHECKS) or not isinstance(d, list):
            return "INVALID"
        if same(rec, rcp):
            return "OK" if d == [] else "INVALID"
        return "OK_WITH_DELTA" if same(d, [{"recorded": rec, "recomputed": rcp}]) else "INVALID"
    except (KeyError, TypeError, AttributeError):
        return "INVALID"


def main():
    import random
    rnd = random.Random(20261125)
    half = F(1, 2)
    # exact results, from the definition
    n = 0
    for _ in range(4000):
        q = rnd.randrange(4)
        x = F(rnd.randrange(-10**6, 10**6), rnd.choice([1, 2, 3, 7, 10, 100, 1000]))
        h = F(rnd.randrange(0, 501), 1000)
        kp = F(rnd.randrange(0, 1001), 1000)
        r = H(q, x, h, kp)
        assert 0 <= r["y"] < S and -half <= r["d"] < half and 0 <= r["w"] <= kp
        assert r["a"] % 4 == q and r["a"] % S == r["s"]
        if kp == 1 and abs(r["d"]) <= h:
            assert r["y"] == r["s"]
        if kp == 0:
            assert r["y"] == x % S
        n += 1
    print("random exact cases (q, x, h, kappa): ", n, "- y in [0,137), a mod 4 = q, a mod 137 = s: all")
    # hard-tune limit
    for _ in range(2000):
        x = F(rnd.randrange(0, 137 * 997), 997)
        r = H(0, x, half, F(1))
        assert r["y"] == r["s"]
    print("h = 1/2, kappa = 1: y = s for every x (staircase): 2000 cases")
    # monotone on the lifted coordinate, fine grid, several (h, kappa)
    for h, kp in [(F(0), F(1)), (F(1, 10), F(1)), (F(2, 5), F(3, 4)), (F(49, 100), F(1)), (F(1, 2), F(1, 2))]:
        prev = None
        for i in range(0, 137 * 40):
            x = F(i, 40)
            r = H(0, x, h, kp)
            lift = x - r["w"] * r["d"]   # unwrapped y
            if prev is not None:
                assert lift >= prev, (h, kp, x)
            prev = lift
    print("y nondecreasing on the unwrapped line, 5 (h, kappa) pairs x 5480 points")
    # receipts
    n_ok = n_delta = n_empty = n_wit = 0
    for _ in range(300):
        q = rnd.randrange(4)
        x = "%d.%d" % (rnd.randrange(-500, 500), rnd.randrange(0, 10**rnd.randrange(1, 6)))
        h = "0.%d" % rnd.randrange(0, 5)
        kp = rnd.choice(["0", "1", "0.5", "0.25", "0.9"])
        rc = make_receipt(q, x, h, kp, "check")
        assert check(rc) == "OK"
        n_ok += 1
        want = rc["recomputed"]
        for _ in range(20):
            s = rnd.randrange(S)
            y = fs(F(rnd.randrange(0, 137 * 50), 50))
            rec = {"s": s, "a": addr(q, s), "y": y}
            if rec == want:
                continue
            rc["recorded"] = rec
            rc["delta"] = [{"recorded": dict(rec), "recomputed": dict(want)}]
            assert check(rc) == "OK_WITH_DELTA"
            n_delta += 1
            rc["delta"] = []
            assert check(rc) == "INVALID"
            n_empty += 1
            rc["delta"] = [{"recorded": dict(rec), "recomputed": {"s": want["s"], "a": want["a"], "y": fs(F(1, 3))}}]
            assert check(rc) == "INVALID"
            n_wit += 1
        rc["recorded"] = dict(want)
        rc["delta"] = []
        assert check(rc) == "OK"
    print("honest receipts OK:", n_ok)
    print("wrong recorded output, true delta -> OK_WITH_DELTA:", n_delta)
    print("same, empty delta -> INVALID:", n_empty)
    print("same, wrong recomputed in delta -> INVALID:", n_wit)
    print("ALL PASS")


if __name__ == "__main__":
    main()
