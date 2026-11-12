"""Independent audit of the quartic saddle coefficient a for the equal-mass Euler orbit.
Route: (A) check the rotation-reduced Hamiltonian against raw 3-body dynamics;
       (B) Taylor tensors of the EXACT reduced H (no hand series);
       (C) generic numeric Lie-transform in the full 6-D eigenbasis (all cubic couplings kept)."""
import itertools, math
import numpy as np, sympy as sp

G = sp.Rational(4, 5); ELL = 2
r, x, y, p, u, v = sp.symbols('r x y p u v', real=True)
Z = [r, x, y, p, u, v]
s2, s3 = sp.sqrt(2), sp.sqrt(3)
Hs = ((p**2 + u**2 + v**2) / 2 + (ELL - x * v + y * u)**2 / (2 * r**2)
      - G * (1 / (s2 * r) + s2 / sp.sqrt((r - s3 * x)**2 + 3 * y**2) + s2 / sp.sqrt((r + s3 * x)**2 + 3 * y**2)))

# ---------- (A) reduced H vs raw N-body ----------
Gf = 0.8
def inertial(state):
    rr, xx, yy, pp, uu, vv = state
    rho1 = np.array([rr, 0.]); P1 = np.array([pp, (ELL - xx * vv + yy * uu) / rr])
    rho2 = np.array([xx, yy]); P2 = np.array([uu, vv])
    def lift(a1, a2):
        r2 = np.sqrt(2 / 3) * a2
        return np.array([(-r2 - np.sqrt(2) * a1) / 2, r2, (-r2 + np.sqrt(2) * a1) / 2])
    return lift(rho1, rho2), lift(P1, P2)           # positions, velocities (3x2)
def reduce(R, V):
    rho1 = (R[2] - R[0]) / np.sqrt(2); P1 = (V[2] - V[0]) / np.sqrt(2)
    rho2 = np.sqrt(2 / 3) * (R[1] - (R[0] + R[2]) / 2); P2 = np.sqrt(2 / 3) * (V[1] - (V[0] + V[2]) / 2)
    rr = np.linalg.norm(rho1); th = np.arctan2(rho1[1], rho1[0]); c, s = np.cos(th), np.sin(th)
    rot = lambda w: np.array([c * w[0] + s * w[1], -s * w[0] + c * w[1]])
    return np.array([rr, *rot(rho2), rho1 @ P1 / rr, *rot(P2)])
def acc(R):
    a = np.zeros((3, 2))
    for i in range(3):
        for j in range(3):
            if i != j:
                d = R[j] - R[i]; a[i] += Gf * d / np.linalg.norm(d)**3
    return a
def energy(R, V):
    e = 0.5 * (V**2).sum()
    for i in range(3):
        for j in range(i + 1, 3): e -= Gf / np.linalg.norm(R[i] - R[j])
    return e
rng = np.random.default_rng(1)
st = np.array([np.sqrt(2), 0, 0, 0, 0, 0]) + 0.05 * rng.standard_normal(6)
R, V = inertial(st)
Hf = sp.lambdify(Z, Hs, 'numpy'); grad = sp.lambdify(Z, [sp.diff(Hs, q) for q in Z], 'numpy')
L = sum(R[i][0]*V[i][1]-R[i][1]*V[i][0] for i in range(3))
print("(A) ang.mom =", L, "| H_red - E_nbody =", Hf(*st) - energy(R, V))
def rk4(R, V, dt):
    f = lambda R, V: (V, acc(R))
    k1 = f(R, V); k2 = f(R + dt / 2 * k1[0], V + dt / 2 * k1[1])
    k3 = f(R + dt / 2 * k2[0], V + dt / 2 * k2[1]); k4 = f(R + dt * k3[0], V + dt * k3[1])
    return (R + dt / 6 * (k1[0] + 2 * k2[0] + 2 * k3[0] + k4[0]), V + dt / 6 * (k1[1] + 2 * k2[1] + 2 * k3[1] + k4[1]))
dt = 1e-4
Rp, Vp = rk4(R, V, dt); Rm, Vm = rk4(R, V, -dt)
num = (reduce(Rp, Vp) - reduce(Rm, Vm)) / (2 * dt)
g = np.array(grad(*st)); ham = np.array([g[3], g[4], g[5], -g[0], -g[1], -g[2]])
print("(A) |d/dt reduced (N-body) - Hamilton eqs| =", np.abs(num - ham).max())

# ---------- (B) Taylor tensors of the exact H ----------
eq = {r: s2, x: 0, y: 0, p: 0, u: 0, v: 0}
d = {(): Hs}
tens = {}
for n in (1, 2, 3, 4):
    nd = {}
    for t, e in d.items():
        for j in range(t[-1] if t else 0, 6):
            nd[t + (j,)] = sp.diff(e, Z[j])
    d = nd
    tens[n] = {t: float(sp.N(e.subs(eq), 30)) for t, e in d.items()}
print("(B) grad at eq max|.| =", max(abs(c) for c in tens[1].values()))
def full(n):
    T = np.zeros((6,) * n)
    for t, c in tens[n].items():
        for perm in set(itertools.permutations(t)): T[perm] = c
    return T
T2, T3, T4 = full(2), full(3), full(4)
Jm = np.block([[np.zeros((3, 3)), np.eye(3)], [-np.eye(3), np.zeros((3, 3))]])
A = Jm @ T2
w, V = np.linalg.eig(A)
nu = np.sqrt((1 + 2 * np.sqrt(51)) / 5); ka = np.sqrt((2 * np.sqrt(51) - 1) / 5)
print("    spectrum:", np.round(sorted(w, key=lambda c: (c.imag, c.real)), 6), " nu,kappa =", nu, ka)
iu = int(np.argmin(abs(w - nu))); isn = int(np.argmin(abs(w + nu)))
order = [iu, isn] + [k for k in range(6) if k not in (iu, isn)]
w = w[order]; V = V[:, order]
Vi = np.linalg.inv(V)
Om = Vi @ Jm @ Vi.T                      # {zeta_a, zeta_b}
V[:, 1] = V[:, 1] * Om[0, 1]; Vi = np.linalg.inv(V); Om = Vi @ Jm @ Vi.T
print("    {xi,eta} =", Om[0, 1], " | check H2 -> nu*xi*eta:", np.allclose(np.diag(V.T @ T2 @ V)[:2], 0), V.T[0] @ T2 @ V[:, 1])

# ---------- (C) generic Lie transform ----------
def to_poly(T, n):
    Tz = T
    for _ in range(n): Tz = np.tensordot(Tz, V, axes=([0], [0]))   # rotates indices cyclically
    P = {}
    for m in itertools.combinations_with_replacement(range(6), n):
        e = [0] * 6
        for k in m: e[k] += 1
        coef = Tz[m] * (math.factorial(n) / np.prod([math.factorial(k) for k in e])) / math.factorial(n)
        P[tuple(e)] = coef
    return P
H3, H4 = to_poly(T3, 3), to_poly(T4, 4)
def dpoly(P, i):
    out = {}
    for e, c in P.items():
        if e[i] > 0:
            f = list(e); f[i] -= 1; out[tuple(f)] = out.get(tuple(f), 0) + c * e[i]
    return out
def mul(P, Q):
    out = {}
    for e1, c1 in P.items():
        for e2, c2 in Q.items():
            e = tuple(a + b for a, b in zip(e1, e2)); out[e] = out.get(e, 0) + c1 * c2
    return out
def bracket(P, Q):
    out = {}
    for i in range(6):
        dP = dpoly(P, i)
        if not dP: continue
        for j in range(6):
            if abs(Om[i, j]) < 1e-14: continue
            for e, c in mul(dP, dpoly(Q, j)).items(): out[e] = out.get(e, 0) + Om[i, j] * c
    return out
chi = {}
minres = 1e9
for e, c in H3.items():
    den = sum(k * l for k, l in zip(e, w)); minres = min(minres, abs(den))
    chi[e] = c / den
print("(C) smallest |m.lambda| over cubic monomials =", minres)
br = bracket(H3, chi)
tgt = (2, 2, 0, 0, 0, 0)
d_direct = H4.get(tgt, 0); corr = 0.5 * br.get(tgt, 0)
print("    quartic direct coeff of xi^2 eta^2 =", d_direct)
print("    Lie correction 1/2{H3,chi3}        =", corr)
a = d_direct + corr
print("    a =", a, "   [file: -2.7730944882]")
sig = 2 * np.log((1 + np.sqrt(5)) / 2) / nu
print("    sigma* =", sig, " c1 = 2 sigma* a =", 2 * sig * a, "   [file: -3.0531186305]")
# robustness: surface-independence -- show which other (xi eta)*center monomials exist at quartic order
for e in sorted(br):
    if e[0] == 1 and e[1] == 1 and sum(e[2:]) == 2 and abs(br[e]) > 1e-9 and False: print(e, br[e])
