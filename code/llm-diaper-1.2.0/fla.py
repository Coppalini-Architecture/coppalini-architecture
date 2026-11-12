"""FLA: exact arithmetic carrier, reversible text transport, and evidence checks.

This is an external validator; it does not alter a language model's weights or state.
All matrix and text-transport calculations use Python integers, not floats.

Fixed definitions: Q = [[1,1],[1,0]], OMEGA = [[0,1],[-1,0]], G = [Q, OMEGA] = Q*OMEGA - OMEGA*Q
= [[-2,1],[1,2]], B = Q**2. (The opposite-sign OMEGA yields -G; every identity checked here holds
for either sign, but this module fixes the one above.)
"""
from __future__ import annotations

__version__ = "1.2.0"

import argparse
import ast
from dataclasses import dataclass
from fractions import Fraction
import hashlib
import json
from pathlib import Path
import re
from typing import Any, Mapping

Matrix = tuple[tuple[int, int], tuple[int, int]]
Vector = tuple[int, int]
Q: Matrix = ((1, 1), (1, 0))
OMEGA: Matrix = ((0, 1), (-1, 0))
G: Matrix = ((-2, 1), (1, 2))
B: Matrix = ((2, 1), (1, 1))
B_INV: Matrix = ((1, -1), (-1, 2))
I: Matrix = ((1, 0), (0, 1))
ZERO_HASH = "0" * 64


def mm(a: Matrix, b: Matrix) -> Matrix:
    return tuple(tuple(sum(a[i][k] * b[k][j] for k in range(2)) for j in range(2)) for i in range(2))  # type: ignore[return-value]


def mv(a: Matrix, z: Vector) -> Vector:
    return (a[0][0] * z[0] + a[0][1] * z[1], a[1][0] * z[0] + a[1][1] * z[1])


def transpose(a: Matrix) -> Matrix:
    return ((a[0][0], a[1][0]), (a[0][1], a[1][1]))


def difference(a: Matrix, b: Matrix) -> Matrix:
    return tuple(tuple(a[i][j] - b[i][j] for j in range(2)) for i in range(2))  # type: ignore[return-value]


def scale(a: Matrix, scalar: int) -> Matrix:
    return tuple(tuple(a[i][j] * scalar for j in range(2)) for i in range(2))  # type: ignore[return-value]


def determinant(a: Matrix) -> int:
    return a[0][0] * a[1][1] - a[0][1] * a[1][0]


def matrix_power(a: Matrix, n: int) -> Matrix:
    if n < 0:
        raise ValueError("matrix_power requires nonnegative exponent")
    result = I
    while n:
        if n & 1:
            result = mm(result, a)
        a = mm(a, a)
        n >>= 1
    return result


def even_transport(n: int) -> Matrix:
    """B**n, with B=Q**2, for any integer n."""
    return matrix_power(B if n >= 0 else B_INV, abs(n))


def mirrored_inverse(n: int) -> Matrix:
    """H B**n H = G B**n G / 5 = B**(-n), exactly."""
    numerator = mm(mm(G, even_transport(n)), G)
    if any(entry % 5 for row in numerator for entry in row):
        raise ArithmeticError("mirror conjugation is not integral")
    return tuple(tuple(entry // 5 for entry in row) for row in numerator)  # type: ignore[return-value]


def quadratic(z: Vector) -> int:
    x, y = z
    return -2 * x * x + 2 * x * y + 2 * y * y


def encode_text(text: str) -> Vector:
    """Injective UTF-8 encoding into Z^2; preserves all bytes incl. NULs."""
    data = text.encode("utf-8", errors="strict")
    return (len(data), int.from_bytes(b"\x01" + data, "big"))


def decode_text(z: Vector) -> str:
    length, payload = z
    if length < 0 or payload < 0:
        raise ValueError("invalid encoded state")
    try:
        packed = payload.to_bytes(length + 1, "big")
    except OverflowError as exc:
        raise ValueError("encoded state has inconsistent length") from exc
    if packed[0] != 1:
        raise ValueError("invalid encoding sentinel")
    return packed[1:].decode("utf-8", errors="strict")


def verify_invariants() -> dict[str, bool]:
    commutator = difference(mm(Q, OMEGA), mm(OMEGA, Q))
    checks = {
        "G_equals_commutator": commutator == G,
        "det_G_minus_5": determinant(G) == -5,
        "G_squared_equals_5I": mm(G, G) == scale(I, 5),
        "G_signature_1_1": G == transpose(G) and determinant(G) < 0,
        "B_equals_Q_squared": mm(Q, Q) == B,
        "B_preserves_quadratic": mm(mm(transpose(B), G), B) == G,
        "B_inverse_exact": mm(B, B_INV) == I and mm(B_INV, B) == I,
        "mirror_inverts_even_transport": all(mirrored_inverse(s) == even_transport(-s) for s in (0, 1, 2, 3, 17)),
        "four_power_17_is_minus_one_mod_137": pow(4, 17, 137) == 136,
        "order_of_4_mod_137_is_34": pow(4, 34, 137) == 1 and all(pow(4, d, 137) != 1 for d in range(1, 34) if 34 % d == 0),
    }
    return checks


# A restricted equation checker. No eval(), names, calls, variables, or comparisons.
_SAFE_EXPRESSION = re.compile(r"[\d\s()+\-*/.]+\Z")


def exact_expr(expression: str) -> Fraction:
    if not expression or len(expression) > 160 or not _SAFE_EXPRESSION.fullmatch(expression):
        raise ValueError("unsupported arithmetic expression")
    tree = ast.parse(expression, mode="eval")

    def walk(node: ast.AST) -> Fraction:
        if isinstance(node, ast.Constant) and type(node.value) in (int, float):
            # Parse the literal spelling exactly: 0.1 means precisely 1/10.
            source = ast.get_source_segment(expression, node) or str(node.value)
            if len(source) > 80:
                raise ValueError("number too long")
            result = Fraction(source)
        elif isinstance(node, ast.UnaryOp) and isinstance(node.op, (ast.UAdd, ast.USub)):
            val = walk(node.operand)
            result = val if isinstance(node.op, ast.UAdd) else -val
        elif isinstance(node, ast.BinOp):
            left, right = walk(node.left), walk(node.right)
            if isinstance(node.op, ast.Add):
                result = left + right
            elif isinstance(node.op, ast.Sub):
                result = left - right
            elif isinstance(node.op, ast.Mult):
                result = left * right
            elif isinstance(node.op, ast.Div):
                if not right:
                    raise ValueError("division by zero")
                result = left / right
            elif isinstance(node.op, ast.Pow):
                if right.denominator != 1 or abs(right.numerator) > 32:
                    raise ValueError("unsupported power")
                if not left and right < 0:
                    raise ValueError("division by zero")
                result = left ** int(right)
            else:
                raise ValueError("unsupported operator")
        else:
            raise ValueError("unsupported arithmetic syntax")
        if result.numerator.bit_length() > 4096 or result.denominator.bit_length() > 4096:
            raise ValueError("arithmetic magnitude too large")
        return result

    return walk(tree.body)


def check_equation(equation: str, epsilon: Fraction | None = None) -> dict[str, Any]:
    """Exact by default. `epsilon` is an opt-in absolute tolerance and is reported in the result."""
    if equation.count("=") != 1:
        raise ValueError("provide one equation of the form 'expression = expression'")
    left, right = equation.split("=", 1)
    lvalue, rvalue = exact_expr(left.strip()), exact_expr(right.strip())
    exact = lvalue == rvalue
    result = {
        "equation": equation,
        "valid": exact or (epsilon is not None and abs(lvalue - rvalue) <= epsilon),
        "left_exact": str(lvalue),
        "right_exact": str(rvalue),
    }
    if epsilon is not None:
        result["epsilon"] = str(epsilon)
        result["exact_equal"] = exact
    return result


def check_referenced_claims(claims: Mapping[str, Any], references: Mapping[str, Any]) -> dict[str, Any]:
    """Exact, typed comparison against user-provided references; no inferred facts."""
    statuses = {}
    for key, value in claims.items():
        statuses[key] = ("unverified" if key not in references else
                         "verified" if type(value) is type(references[key]) and value == references[key] else
                         "contradicted")
    return {"all_verified": bool(statuses) and all(v == "verified" for v in statuses.values()), "claims": statuses}


@dataclass(frozen=True)
class Tolerance:
    """Opt-in loosening of the gate. The default (EXACT) compares exactly; active settings are recorded in every result."""
    fold_case: bool = False
    normalize_whitespace: bool = False
    strip_thousands: bool = False
    epsilon: Fraction | None = None

    @property
    def normalizes(self) -> bool:
        return self.fold_case or self.normalize_whitespace or self.strip_thousands

    def normalize(self, text: str) -> str:
        if self.normalize_whitespace:
            text = " ".join(text.split())
        if self.strip_thousands:
            text = re.sub(r"(?<=\d),(?=\d{3}(?!\d))", "", text)
        if self.fold_case:
            text = text.casefold()
        return text

    def active(self) -> dict[str, Any]:
        out: dict[str, Any] = {}
        for name in ("fold_case", "normalize_whitespace", "strip_thousands"):
            if getattr(self, name):
                out[name] = True
        if self.epsilon is not None:
            out["epsilon"] = str(self.epsilon)
        return out


EXACT = Tolerance()
_GATE_FROM_STATUS = {"verified": "can", "contradicted": "cannot", "unverified": "open"}


def _reference_match(value: str, reference: Any, tol: Tolerance) -> str | None:
    """None: no usable reference (open). "mismatch": usable reference, value differs (cannot)."""
    if isinstance(reference, str):
        accepted = [reference]
    elif isinstance(reference, (list, tuple)) and reference and all(isinstance(a, str) for a in reference):
        accepted = list(reference)
    else:
        return None
    if value in accepted:
        return "exact"
    if tol.normalizes and tol.normalize(value) in {tol.normalize(a) for a in accepted}:
        return "normalized"
    return "mismatch"


def gate_text(candidate: str, references: Mapping[str, Any] | None = None, tolerance: Tolerance = EXACT) -> dict[str, Any]:
    """Silence-on-unverified gate for a deliberately *restricted* text grammar.

    Accepted lines are either standalone arithmetic equations or `key: value`
    records whose entire value matches an externally supplied reference (a string,
    or a list of accepted strings). Every line gets a status (verified / contradicted /
    unverified) and the matching gate value (can / cannot / open).

    Silence is typed. `silence` is "neutral" when the candidate is blank (nothing owed,
    accepted), "withheld" when output was present but not fully proven (emitted_text is
    empty), and None when the candidate is delivered.
    """
    references = {} if references is None else references
    checks: list[dict[str, Any]] = []
    for raw in candidate.splitlines():
        if not raw.strip():
            continue
        line = raw.strip()
        if "=" in line:
            try:
                result = check_equation(line, tolerance.epsilon)
                status = "verified" if result["valid"] else "contradicted"
                entry: dict[str, Any] = {"line": line, "status": status, "kind": "arithmetic",
                                         "left_exact": result["left_exact"], "right_exact": result["right_exact"]}
                if status == "verified":
                    entry["match"] = "exact" if result.get("exact_equal", True) else "within_epsilon"
            except (ValueError, SyntaxError, ZeroDivisionError):
                entry = {"line": line, "status": "unverified", "kind": "unsupported_equation"}
        elif ":" in line:
            key, value = line.split(":", 1)
            key, value = key.strip(), value.strip()
            match = _reference_match(value, references[key], tolerance) if key in references else None
            status = "unverified" if match is None else "contradicted" if match == "mismatch" else "verified"
            entry = {"line": line, "status": status, "kind": "reference"}
            if status == "verified":
                entry["match"] = match
        else:
            entry = {"line": line, "status": "unverified", "kind": "unstructured_text"}
        entry["gate"] = _GATE_FROM_STATUS[entry["status"]]
        checks.append(entry)
    if not checks:
        accepted, silence = True, "neutral"
    elif all(c["status"] == "verified" for c in checks):
        accepted, silence = True, None
    else:
        accepted, silence = False, "withheld"
    return {"accepted": accepted, "emitted_text": candidate if accepted and checks else "", "silence": silence,
            "checks": checks, "tolerances": tolerance.active(),
            "policy": "silence if any line lacks explicit proof under supported grammar"}


def audit_text(text: str, steps: int = 1) -> dict[str, Any]:
    if abs(steps) > 256:
        raise ValueError("transport steps are limited to absolute value <= 256")
    original = encode_text(text)
    downstream = mv(even_transport(steps), original)
    upstream = mv(mirrored_inverse(steps), downstream)
    return {
        "protocol": "FLA-external/1.0",
        "utf8_bytes": len(text.encode("utf-8")),
        "input_sha256": hashlib.sha256(text.encode("utf-8")).hexdigest(),
        "transport_steps": steps,
        "qG_preserved": quadratic(original) == quadratic(downstream),
        "mirror_inverse_verified": mirrored_inverse(steps) == even_transport(-steps),
        "lossless_utf8_roundtrip": upstream == original and decode_text(upstream) == text,
        "scope": "exact byte transport; not a semantic truth guarantee",
    }


def _canonical(obj: Any) -> bytes:
    return json.dumps(obj, sort_keys=True, separators=(",", ":"), ensure_ascii=False, allow_nan=False).encode("utf-8")


def read_ledger(path: str | Path) -> list[dict[str, Any]]:
    path = Path(path)
    if not path.exists():
        return []
    entries: list[dict[str, Any]] = []
    prev = ZERO_HASH
    for line_num, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        if not line.strip():
            continue  # blank lines carry no entry; they do not affect the chain
        try:
            entry = json.loads(line)
            entry_hash = entry.pop("entry_hash")
            if entry["seq"] != len(entries) + 1 or entry["prev_hash"] != prev:
                raise ValueError("chain discontinuity")
            computed = hashlib.sha256(_canonical(entry)).hexdigest()
            if computed != entry_hash:
                raise ValueError("hash mismatch")
            entry["entry_hash"] = entry_hash
            entries.append(entry)
            prev = entry_hash
        except (ValueError, KeyError, TypeError) as exc:
            raise ValueError(f"ledger invalid at line {line_num}: {exc}") from exc
    return entries


def append_receipt(path: str | Path, receipt: dict[str, Any]) -> dict[str, Any]:
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    old = read_ledger(path)
    entry = {"seq": len(old) + 1, "prev_hash": old[-1]["entry_hash"] if old else ZERO_HASH, "receipt": receipt}
    entry["entry_hash"] = hashlib.sha256(_canonical(entry)).hexdigest()
    with path.open("a", encoding="utf-8") as f:
        f.write(_canonical(entry).decode("utf-8") + "\n")
    return entry


def _parse_epsilon(text: str | None, parser: argparse.ArgumentParser) -> Fraction | None:
    if text is None:
        return None
    try:
        eps = Fraction(text)
    except (ValueError, ZeroDivisionError):
        parser.error(f"invalid --epsilon: {text!r}")
    if eps < 0:
        parser.error("--epsilon must be nonnegative")
    return eps


def main() -> int:
    parser = argparse.ArgumentParser(description="Fixed-Ledger Architecture: exact validator and ledger")
    parser.add_argument("--version", action="version", version=f"fla {__version__}")
    sub = parser.add_subparsers(dest="command", required=True)
    sub.add_parser("verify", help="verify algebraic and modular invariants")
    aud = sub.add_parser("audit", help="reversibly encode, transport, and mirror text")
    aud.add_argument("text", help="literal text to test")
    aud.add_argument("--steps", type=int, default=1)
    aud.add_argument("--ledger", type=Path)
    chk = sub.add_parser("check", help="check one arithmetic equation exactly")
    chk.add_argument("equation")
    chk.add_argument("--epsilon", help="opt-in absolute tolerance, e.g. 1/1000 or 0.001 (recorded in the result)")
    chk.add_argument("--ledger", type=Path)
    refs = sub.add_parser("claims", help="compare claims to explicit JSON references")
    refs.add_argument("file", type=Path, help="JSON object with claims and references dictionaries")
    refs.add_argument("--ledger", type=Path)
    gate = sub.add_parser("gate", help="emit only fully verified arithmetic/reference lines")
    gate.add_argument("text")
    gate.add_argument("--references", type=Path, help="JSON dictionary of trusted key/value strings")
    gate.add_argument("--ledger", type=Path)
    gate.add_argument("--fold-case", action="store_true", help="opt-in: case-insensitive reference match")
    gate.add_argument("--normalize-whitespace", action="store_true", help="opt-in: collapse whitespace in reference match")
    gate.add_argument("--strip-thousands", action="store_true", help="opt-in: ignore thousands separators (1,000 = 1000)")
    gate.add_argument("--epsilon", help="opt-in absolute tolerance for equations")
    val = sub.add_parser("validate-ledger", help="check ledger hash chain")
    val.add_argument("ledger", type=Path)
    args = parser.parse_args()
    if args.command == "verify":
        result = verify_invariants()
        ok = all(result.values())
        output = {"all_pass": ok, "checks": result}
    elif args.command == "audit":
        output = audit_text(args.text, args.steps)
        ok = output["qG_preserved"] and output["mirror_inverse_verified"] and output["lossless_utf8_roundtrip"]
    elif args.command == "check":
        output = check_equation(args.equation, _parse_epsilon(args.epsilon, parser))
        ok = output["valid"]
    elif args.command == "claims":
        supplied = json.loads(args.file.read_text(encoding="utf-8"))
        output = check_referenced_claims(supplied["claims"], supplied["references"])
        ok = output["all_verified"]
    elif args.command == "gate":
        trusted = json.loads(args.references.read_text(encoding="utf-8")) if args.references else {}
        tolerance = Tolerance(fold_case=args.fold_case, normalize_whitespace=args.normalize_whitespace,
                              strip_thousands=args.strip_thousands, epsilon=_parse_epsilon(args.epsilon, parser))
        output = gate_text(args.text, trusted, tolerance)
        ok = output["accepted"]
    else:
        entries = read_ledger(args.ledger)
        output = {"valid": True, "entry_count": len(entries), "head_hash": entries[-1]["entry_hash"] if entries else ZERO_HASH}
        ok = True
    if getattr(args, "ledger", None) and args.command != "validate-ledger":
        entry = append_receipt(args.ledger, output)
        output = {**output, "receipt_seq": entry["seq"], "receipt_hash": entry["entry_hash"]}
    print(json.dumps(output, ensure_ascii=False, indent=2))
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
