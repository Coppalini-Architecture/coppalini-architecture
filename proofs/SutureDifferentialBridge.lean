import proofs.SutureRankGeneral

set_option autoImplicit false
set_option maxHeartbeats 3000000

/-!
009: Suture differential / dual-pairing bridge
All indices below are zero-based. The coframe is normalized to
p0=e0, p1=e7, p2=e2, p3=-c e3+u e4+v e5.
The original p0=a e0 (a nonzero) is related by an invertible
right-frame change; the resulting rank criterion is unchanged.

The metric/flux derivatives are the linear terms of
 (P+tV)^T eta (P+tV) and (P+tV)^T C (P+tV).
The minus sign in the antisymmetric dual pairing makes
the adjoint equal to eta Pm + C Pn.
-/

namespace SutureDifferentialBridge

open SutureRankGeneral

variable {K : Type} [Lean.Grind.Field K]

def sum4 (f : Nat → K) : K :=
  f 0 + f 1 + f 2 + f 3

def sum8 (f : Nat → K) : K :=
  f 0 + f 1 + f 2 + f 3 + f 4 + f 5 + f 6 + f 7

-- eta * P and C * P, evaluated from eta=G (+) I6, C=C1 (+) C1 (+) C1 (+) C1.
def etaP (c u v : K) (i j : Nat) : K :=
  match i, j with
  | 0, 0 => -2
  | 1, 0 => 1
  | 7, 1 => 1
  | 2, 2 => 1
  | 3, 3 => -c
  | 4, 3 => u
  | 5, 3 => v
  | _, _ => 0

def cP (c u v : K) (i j : Nat) : K :=
  match i, j with
  | 1, 0 => 1
  | 6, 1 => -1
  | 3, 2 => 1
  | 2, 3 => c
  | 4, 3 => -v
  | 5, 3 => u
  | _, _ => 0

def Variation := Nat → Nat → K

-- First-order variation of the metric and two-form at P(c,u,v).
def dg (c u v : K) (V : Variation) (i j : Nat) : K :=
  sum8 (fun k => V k i * etaP c u v k j + V k j * etaP c u v k i)

def df (c u v : K) (V : Variation) (i j : Nat) : K :=
  sum8 (fun k => V k i * cP c u v k j - V k j * cP c u v k i)

-- Trace pairing with a sign-adjusted antisymmetric dual n.
def pairing (c u v : K) (d : Dual K) (V : Variation) : K :=
  sum4 (fun i => sum4 (fun j =>
    mVal d i j * dg c u v V i j -
    nVal d i j * df c u v V i j))

def adjoint (c u v : K) (d : Dual K) (k j : Nat) : K :=
  sum4 (fun i =>
    etaP c u v k i * mVal d i j +
    cP c u v k i * nVal d i j)

def adjointPair (c u v : K) (d : Dual K) (V : Variation) : K :=
  (2 : K) * sum8 (fun k => sum4 (fun j => V k j * adjoint c u v d k j))

-- The full finite-index variational identity (not a definition of pairing).
theorem pairing_adjoint (c u v : K) (d : Dual K) (V : Variation) :
    pairing c u v d V = adjointPair c u v d V := by
  grind [pairing, adjointPair, dg, df, adjoint,
    sum4, sum8, etaP, cP, mVal, nVal]

end SutureDifferentialBridge

#print axioms SutureDifferentialBridge.pairing_adjoint
