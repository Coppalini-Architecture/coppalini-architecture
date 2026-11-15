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

def Variation (K : Type) := Nat → Nat → K

-- First-order variation of the metric and two-form at P(c,u,v).
def dg (c u v : K) (V : Variation K) (i j : Nat) : K :=
  sum8 (fun k => V k i * etaP c u v k j + V k j * etaP c u v k i)

def df (c u v : K) (V : Variation K) (i j : Nat) : K :=
  sum8 (fun k => V k i * cP c u v k j - V k j * cP c u v k i)

-- Trace pairing with a sign-adjusted antisymmetric dual n.
def pairing (c u v : K) (d : Dual K) (V : Variation K) : K :=
  sum4 (fun i => sum4 (fun j =>
    mVal d i j * dg c u v V i j -
    nVal d i j * df c u v V i j))

def adjoint (c u v : K) (d : Dual K) (k j : Nat) : K :=
  sum4 (fun i =>
    etaP c u v k i * mVal d i j +
    cP c u v k i * nVal d i j)

def adjointPair (c u v : K) (d : Dual K) (V : Variation K) : K :=
  (2 : K) * sum8 (fun k => sum4 (fun j => V k j * adjoint c u v d k j))

-- The full finite-index variational identity (not a definition of pairing).
theorem pairing_adjoint (c u v : K) (d : Dual K) (V : Variation K) :
    pairing c u v d V = adjointPair c u v d V := by
  grind [pairing, adjointPair, dg, df, adjoint,
    sum4, sum8, etaP, cP, mVal, nVal]

-- Multiplying the adjoint equation by C sends its row 0 to 1.
theorem flip_0 (c u v : K) (d : Dual K) (j : Nat) (hj : j < 4) :
    (jpM c u v d 0 j - pN c u v d 0 j = -adjoint c u v d 1 j) ∧
    (jpM c u v d 1 j - pN c u v d 1 j = adjoint c u v d 0 j) := by
  have jcases : j = 0 ∨ j = 1 ∨ j = 2 ∨ j = 3 := by omega
  rcases jcases with rfl | rfl | rfl | rfl
  all_goals grind [jpM, pN, adjoint, sum4, etaP, cP, p, jp, mVal, nVal]

-- Multiplying the adjoint equation by C sends its row 2 to 3.
theorem flip_2 (c u v : K) (d : Dual K) (j : Nat) (hj : j < 4) :
    (jpM c u v d 2 j - pN c u v d 2 j = -adjoint c u v d 3 j) ∧
    (jpM c u v d 3 j - pN c u v d 3 j = adjoint c u v d 2 j) := by
  have jcases : j = 0 ∨ j = 1 ∨ j = 2 ∨ j = 3 := by omega
  rcases jcases with rfl | rfl | rfl | rfl
  all_goals grind [jpM, pN, adjoint, sum4, etaP, cP, p, jp, mVal, nVal]

-- Multiplying the adjoint equation by C sends its row 4 to 5.
theorem flip_4 (c u v : K) (d : Dual K) (j : Nat) (hj : j < 4) :
    (jpM c u v d 4 j - pN c u v d 4 j = -adjoint c u v d 5 j) ∧
    (jpM c u v d 5 j - pN c u v d 5 j = adjoint c u v d 4 j) := by
  have jcases : j = 0 ∨ j = 1 ∨ j = 2 ∨ j = 3 := by omega
  rcases jcases with rfl | rfl | rfl | rfl
  all_goals grind [jpM, pN, adjoint, sum4, etaP, cP, p, jp, mVal, nVal]

-- Multiplying the adjoint equation by C sends its row 6 to 7.
theorem flip_6 (c u v : K) (d : Dual K) (j : Nat) (hj : j < 4) :
    (jpM c u v d 6 j - pN c u v d 6 j = -adjoint c u v d 7 j) ∧
    (jpM c u v d 7 j - pN c u v d 7 j = adjoint c u v d 6 j) := by
  have jcases : j = 0 ∨ j = 1 ∨ j = 2 ∨ j = 3 := by omega
  rcases jcases with rfl | rfl | rfl | rfl
  all_goals grind [jpM, pN, adjoint, sum4, etaP, cP, p, jp, mVal, nVal]


-- A variation probes one coframe coordinate with its exact dual index.
def basis (i j : Nat) : Variation K :=
  fun k l => (if k = i then (1:K) else 0) *
             (if l = j then (1:K) else 0)

theorem basis_pair (c u v : K) (d : Dual K) (i j : Nat)
    (hi : i < 8) (hj : j < 4) :
    adjointPair c u v d (basis i j) = 2 * adjoint c u v d i j := by
  have icases : i = 0 ∨ i = 1 ∨ i = 2 ∨ i = 3 ∨
    i = 4 ∨ i = 5 ∨ i = 6 ∨ i = 7 := by omega
  have jcases : j = 0 ∨ j = 1 ∨ j = 2 ∨ j = 3 := by omega
  rcases icases with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
  all_goals rcases jcases with rfl | rfl | rfl | rfl
  all_goals simp [adjointPair, basis, sum8, sum4]
  all_goals grind

def PairKernel (c u v : K) (d : Dual K) : Prop :=
  ∀ V : Variation K, pairing c u v d V = 0

def AdjointKernel (c u v : K) (d : Dual K) : Prop :=
  ∀ i j : Nat, i < 8 → j < 4 → adjoint c u v d i j = 0

theorem pairing_zero_iff_adjoint (c u v : K) (d : Dual K)
    (two_ne : (2:K) ≠ 0) :
    PairKernel c u v d ↔ AdjointKernel c u v d := by
  constructor
  · intro h i j hi hj
    have hb := h (basis i j)
    rw [pairing_adjoint, basis_pair c u v d i j hi hj] at hb
    grind
  · intro h V
    have hz00 : adjoint c u v d 0 0 = 0 :=
      h 0 0 (by omega) (by omega)
    have hz01 : adjoint c u v d 0 1 = 0 :=
      h 0 1 (by omega) (by omega)
    have hz02 : adjoint c u v d 0 2 = 0 :=
      h 0 2 (by omega) (by omega)
    have hz03 : adjoint c u v d 0 3 = 0 :=
      h 0 3 (by omega) (by omega)
    have hz10 : adjoint c u v d 1 0 = 0 :=
      h 1 0 (by omega) (by omega)
    have hz11 : adjoint c u v d 1 1 = 0 :=
      h 1 1 (by omega) (by omega)
    have hz12 : adjoint c u v d 1 2 = 0 :=
      h 1 2 (by omega) (by omega)
    have hz13 : adjoint c u v d 1 3 = 0 :=
      h 1 3 (by omega) (by omega)
    have hz20 : adjoint c u v d 2 0 = 0 :=
      h 2 0 (by omega) (by omega)
    have hz21 : adjoint c u v d 2 1 = 0 :=
      h 2 1 (by omega) (by omega)
    have hz22 : adjoint c u v d 2 2 = 0 :=
      h 2 2 (by omega) (by omega)
    have hz23 : adjoint c u v d 2 3 = 0 :=
      h 2 3 (by omega) (by omega)
    have hz30 : adjoint c u v d 3 0 = 0 :=
      h 3 0 (by omega) (by omega)
    have hz31 : adjoint c u v d 3 1 = 0 :=
      h 3 1 (by omega) (by omega)
    have hz32 : adjoint c u v d 3 2 = 0 :=
      h 3 2 (by omega) (by omega)
    have hz33 : adjoint c u v d 3 3 = 0 :=
      h 3 3 (by omega) (by omega)
    have hz40 : adjoint c u v d 4 0 = 0 :=
      h 4 0 (by omega) (by omega)
    have hz41 : adjoint c u v d 4 1 = 0 :=
      h 4 1 (by omega) (by omega)
    have hz42 : adjoint c u v d 4 2 = 0 :=
      h 4 2 (by omega) (by omega)
    have hz43 : adjoint c u v d 4 3 = 0 :=
      h 4 3 (by omega) (by omega)
    have hz50 : adjoint c u v d 5 0 = 0 :=
      h 5 0 (by omega) (by omega)
    have hz51 : adjoint c u v d 5 1 = 0 :=
      h 5 1 (by omega) (by omega)
    have hz52 : adjoint c u v d 5 2 = 0 :=
      h 5 2 (by omega) (by omega)
    have hz53 : adjoint c u v d 5 3 = 0 :=
      h 5 3 (by omega) (by omega)
    have hz60 : adjoint c u v d 6 0 = 0 :=
      h 6 0 (by omega) (by omega)
    have hz61 : adjoint c u v d 6 1 = 0 :=
      h 6 1 (by omega) (by omega)
    have hz62 : adjoint c u v d 6 2 = 0 :=
      h 6 2 (by omega) (by omega)
    have hz63 : adjoint c u v d 6 3 = 0 :=
      h 6 3 (by omega) (by omega)
    have hz70 : adjoint c u v d 7 0 = 0 :=
      h 7 0 (by omega) (by omega)
    have hz71 : adjoint c u v d 7 1 = 0 :=
      h 7 1 (by omega) (by omega)
    have hz72 : adjoint c u v d 7 2 = 0 :=
      h 7 2 (by omega) (by omega)
    have hz73 : adjoint c u v d 7 3 = 0 :=
      h 7 3 (by omega) (by omega)
    rw [pairing_adjoint]
    simp [adjointPair, sum8, sum4, hz00, hz01, hz02, hz03, hz10, hz11, hz12, hz13, hz20, hz21, hz22, hz23, hz30, hz31, hz32, hz33, hz40, hz41, hz42, hz43, hz50, hz51, hz52, hz53, hz60, hz61, hz62, hz63, hz70, hz71, hz72, hz73]
    grind


end SutureDifferentialBridge

#print axioms SutureDifferentialBridge.pairing_adjoint
#print axioms SutureDifferentialBridge.flip_0
#print axioms SutureDifferentialBridge.flip_2
#print axioms SutureDifferentialBridge.flip_4
#print axioms SutureDifferentialBridge.flip_6
#print axioms SutureDifferentialBridge.pairing_zero_iff_adjoint
