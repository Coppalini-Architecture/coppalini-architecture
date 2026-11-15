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


theorem raw_0_iff (c u v : K) (d : Dual K) (j : Nat) (hj : j < 4) :
    (pN c u v d 0 j = jpM c u v d 0 j) ↔
    adjoint c u v d 1 j = 0 := by
  have hf := (flip_0 c u v d j hj).1
  grind

theorem raw_1_iff (c u v : K) (d : Dual K) (j : Nat) (hj : j < 4) :
    (pN c u v d 1 j = jpM c u v d 1 j) ↔
    adjoint c u v d 0 j = 0 := by
  have hf := (flip_0 c u v d j hj).2
  grind

theorem raw_2_iff (c u v : K) (d : Dual K) (j : Nat) (hj : j < 4) :
    (pN c u v d 2 j = jpM c u v d 2 j) ↔
    adjoint c u v d 3 j = 0 := by
  have hf := (flip_2 c u v d j hj).1
  grind

theorem raw_3_iff (c u v : K) (d : Dual K) (j : Nat) (hj : j < 4) :
    (pN c u v d 3 j = jpM c u v d 3 j) ↔
    adjoint c u v d 2 j = 0 := by
  have hf := (flip_2 c u v d j hj).2
  grind

theorem raw_4_iff (c u v : K) (d : Dual K) (j : Nat) (hj : j < 4) :
    (pN c u v d 4 j = jpM c u v d 4 j) ↔
    adjoint c u v d 5 j = 0 := by
  have hf := (flip_4 c u v d j hj).1
  grind

theorem raw_5_iff (c u v : K) (d : Dual K) (j : Nat) (hj : j < 4) :
    (pN c u v d 5 j = jpM c u v d 5 j) ↔
    adjoint c u v d 4 j = 0 := by
  have hf := (flip_4 c u v d j hj).2
  grind

theorem raw_6_iff (c u v : K) (d : Dual K) (j : Nat) (hj : j < 4) :
    (pN c u v d 6 j = jpM c u v d 6 j) ↔
    adjoint c u v d 7 j = 0 := by
  have hf := (flip_6 c u v d j hj).1
  grind

theorem raw_7_iff (c u v : K) (d : Dual K) (j : Nat) (hj : j < 4) :
    (pN c u v d 7 j = jpM c u v d 7 j) ↔
    adjoint c u v d 6 j = 0 := by
  have hf := (flip_6 c u v d j hj).2
  grind

def RawKernel (c u v : K) (d : Dual K) : Prop :=
  ∀ i j : Nat, i < 8 → j < 4 →
    pN c u v d i j = jpM c u v d i j

theorem raw_matrix_iff (c u v : K) (d : Dual K) :
    RawKernel c u v d ↔ MatrixKernel c u v d := by
  constructor
  · intro h i hi
    exact ⟨h i 0 hi (by omega), h i 1 hi (by omega),
      h i 2 hi (by omega), h i 3 hi (by omega)⟩
  · intro h i j hi hj
    have hr := h i hi
    have jcases : j = 0 ∨ j = 1 ∨ j = 2 ∨ j = 3 := by omega
    rcases jcases with rfl | rfl | rfl | rfl
    · exact hr.1
    · exact hr.2.1
    · exact hr.2.2.1
    · exact hr.2.2.2

theorem raw_adjoint_iff (c u v : K) (d : Dual K) :
    RawKernel c u v d ↔ AdjointKernel c u v d := by
  constructor
  · intro h i j hi hj
    have icases : i = 0 ∨ i = 1 ∨ i = 2 ∨ i = 3 ∨
      i = 4 ∨ i = 5 ∨ i = 6 ∨ i = 7 := by omega
    rcases icases with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
    · exact (raw_1_iff c u v d j hj).mp (h 1 j (by omega) hj)
    · exact (raw_0_iff c u v d j hj).mp (h 0 j (by omega) hj)
    · exact (raw_3_iff c u v d j hj).mp (h 3 j (by omega) hj)
    · exact (raw_2_iff c u v d j hj).mp (h 2 j (by omega) hj)
    · exact (raw_5_iff c u v d j hj).mp (h 5 j (by omega) hj)
    · exact (raw_4_iff c u v d j hj).mp (h 4 j (by omega) hj)
    · exact (raw_7_iff c u v d j hj).mp (h 7 j (by omega) hj)
    · exact (raw_6_iff c u v d j hj).mp (h 6 j (by omega) hj)
  · intro h i j hi hj
    have icases : i = 0 ∨ i = 1 ∨ i = 2 ∨ i = 3 ∨
      i = 4 ∨ i = 5 ∨ i = 6 ∨ i = 7 := by omega
    rcases icases with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
    · exact (raw_0_iff c u v d j hj).mpr (h 1 j (by omega) hj)
    · exact (raw_1_iff c u v d j hj).mpr (h 0 j (by omega) hj)
    · exact (raw_2_iff c u v d j hj).mpr (h 3 j (by omega) hj)
    · exact (raw_3_iff c u v d j hj).mpr (h 2 j (by omega) hj)
    · exact (raw_4_iff c u v d j hj).mpr (h 5 j (by omega) hj)
    · exact (raw_5_iff c u v d j hj).mpr (h 4 j (by omega) hj)
    · exact (raw_6_iff c u v d j hj).mpr (h 7 j (by omega) hj)
    · exact (raw_7_iff c u v d j hj).mpr (h 6 j (by omega) hj)

theorem adjoint_matrix_iff (c u v : K) (d : Dual K) :
    AdjointKernel c u v d ↔ MatrixKernel c u v d :=
  (raw_adjoint_iff c u v d).symm.trans (raw_matrix_iff c u v d)

theorem pairing_zero_iff_matrix (c u v : K) (d : Dual K)
    (two_ne : (2:K) ≠ 0) :
    PairKernel c u v d ↔ MatrixKernel c u v d :=
  (pairing_zero_iff_adjoint c u v d two_ne).trans
    (adjoint_matrix_iff c u v d)

-- This is a theorem about the actual suture variation pairing.
theorem variational_full_rank_iff (c u v : K) (two_ne : (2:K) ≠ 0) :
    (∀ d : Dual K, PairKernel c u v d → d = lift c 0) ↔
       (u ≠ 0 ∨ v ≠ 0) := by
  constructor
  · intro h
    apply (matrix_rank_criterion c u v two_ne).mp
    intro d hm
    exact h d ((pairing_zero_iff_matrix c u v d two_ne).mpr hm)
  · intro h d hv
    apply (matrix_rank_criterion c u v two_ne).mpr h
    exact (pairing_zero_iff_matrix c u v d two_ne).mp hv

theorem euclidean_variational_full_rank_iff (c u v : K)
    (two_ne : (2:K) ≠ 0) (hp : PositiveTwoSquare K) :
    (∀ d : Dual K, PairKernel c u v d → d = lift c 0) ↔
       u*u + v*v ≠ 0 := by
  rw [variational_full_rank_iff c u v two_ne]
  exact (euclidean_nonzero u v hp).symm



-- The declared eight-dimensional carrier, in fixed zero-based coordinates.
def etaHat (i j : Nat) : K :=
  match i, j with
  | 0, 0 => -2
  | 0, 1 => 1
  | 1, 0 => 1
  | 1, 1 => 2
  | 2, 2 => 1
  | 3, 3 => 1
  | 4, 4 => 1
  | 5, 5 => 1
  | 6, 6 => 1
  | 7, 7 => 1
  | _, _ => 0

def cHat (i j : Nat) : K :=
  match i, j with
  | 0, 1 => -1
  | 1, 0 => 1
  | 2, 3 => -1
  | 3, 2 => 1
  | 4, 5 => -1
  | 5, 4 => 1
  | 6, 7 => -1
  | 7, 6 => 1
  | _, _ => 0

def product8 (A : Nat → Nat → K) (P : Variation K)
    (i j : Nat) : K :=
  sum8 (fun k => A i k * P k j)

-- Those are exactly eta*P, C*P, and C*eta*P.
theorem etaP_exact (c u v : K) (i j : Nat)
    (hi : i < 8) (hj : j < 4) :
    product8 etaHat (p c u v) i j = etaP c u v i j := by
  have icases : i = 0 ∨ i = 1 ∨ i = 2 ∨ i = 3 ∨
      i = 4 ∨ i = 5 ∨ i = 6 ∨ i = 7 := by omega
  have jcases : j = 0 ∨ j = 1 ∨ j = 2 ∨ j = 3 := by omega
  rcases icases with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
  all_goals rcases jcases with rfl | rfl | rfl | rfl
  all_goals grind [product8, sum8, etaHat, etaP, p]

theorem cP_exact (c u v : K) (i j : Nat)
    (hi : i < 8) (hj : j < 4) :
    product8 cHat (p c u v) i j = cP c u v i j := by
  have icases : i = 0 ∨ i = 1 ∨ i = 2 ∨ i = 3 ∨
      i = 4 ∨ i = 5 ∨ i = 6 ∨ i = 7 := by omega
  have jcases : j = 0 ∨ j = 1 ∨ j = 2 ∨ j = 3 := by omega
  rcases icases with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
  all_goals rcases jcases with rfl | rfl | rfl | rfl
  all_goals grind [product8, sum8, cHat, cP, p]

theorem jp_exact (c u v : K) (i j : Nat)
    (hi : i < 8) (hj : j < 4) :
    product8 cHat (fun a b => product8 etaHat (p c u v) a b)
       i j = jp c u v i j := by
  have h0 := etaP_exact c u v 0 j (by omega) hj
  have h1 := etaP_exact c u v 1 j (by omega) hj
  have h2 := etaP_exact c u v 2 j (by omega) hj
  have h3 := etaP_exact c u v 3 j (by omega) hj
  have h4 := etaP_exact c u v 4 j (by omega) hj
  have h5 := etaP_exact c u v 5 j (by omega) hj
  have h6 := etaP_exact c u v 6 j (by omega) hj
  have h7 := etaP_exact c u v 7 j (by omega) hj
  have hEval :
      product8 cHat (fun a b => product8 etaHat (p c u v) a b)
        i j = sum8 (fun k => cHat i k * etaP c u v k j) := by
    change sum8 (fun k => cHat i k * product8 etaHat (p c u v) k j)
      = sum8 (fun k => cHat i k * etaP c u v k j)
    simp only [sum8, h0, h1, h2, h3, h4, h5, h6, h7]
  rw [hEval]
  have icases : i = 0 ∨ i = 1 ∨ i = 2 ∨ i = 3 ∨
      i = 4 ∨ i = 5 ∨ i = 6 ∨ i = 7 := by omega
  have jcases : j = 0 ∨ j = 1 ∨ j = 2 ∨ j = 3 := by omega
  rcases icases with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
  all_goals rcases jcases with rfl | rfl | rfl | rfl
  all_goals grind [sum8, cHat, etaP, jp]

-- At the wall there is exactly one free row relation.
theorem variational_wall_relation (c : K) (two_ne : (2:K) ≠ 0)
    (d : Dual K) :
    PairKernel c 0 0 d ↔ ∃ t : K, d = lift c t := by
  rw [pairing_zero_iff_matrix c 0 0 d two_ne, matrix_kernel_iff c 0 0 d]
  exact wall_kernel c two_ne d

-- Removing the m33 output coordinate leaves fifteen independent dual rows.
theorem variational_wall_fifteen_independent (c : K)
    (two_ne : (2:K) ≠ 0) (d : Dual K)
    (h : PairKernel c 0 0 d) (h33 : d.m33 = 0) :
    d = lift c 0 := by
  obtain ⟨t, ht⟩ := (variational_wall_relation c two_ne d).mp h
  have hterm : t = 0 := by
    rw [ht] at h33
    simpa [lift] using h33
  rw [ht, hterm]

theorem variational_wall_has_relation (c : K)
    (two_ne : (2:K) ≠ 0) :
    ∃ d : Dual K, PairKernel c 0 0 d ∧ d ≠ lift c 0 := by
  obtain ⟨d, hd, hn⟩ := nonzero_wall c two_ne
  have hm : MatrixKernel c 0 0 d := (matrix_kernel_iff c 0 0 d).mpr hd
  exact ⟨d, (pairing_zero_iff_matrix c 0 0 d two_ne).mpr hm, hn⟩



-- Quadratic suture map as an exact finite bilinear contraction.
def bilinear (A : Nat → Nat → K)
    (X Y : Variation K) (i j : Nat) : K :=
  sum8 (fun k => X k i * product8 A Y k j)

def shifted (t : K) (X V : Variation K) : Variation K :=
  fun k j => X k j + t * V k j

theorem product8_shift (A : Nat → Nat → K)
    (X V : Variation K) (t : K) (i j : Nat) :
    product8 A (shifted t X V) i j =
       product8 A X i j + t * product8 A V i j := by
  grind [product8, shifted, sum8]

theorem bilinear_shift_left (A : Nat → Nat → K)
    (X V Y : Variation K) (t : K) (i j : Nat) :
    bilinear A (shifted t X V) Y i j =
      bilinear A X Y i j + t * bilinear A V Y i j := by
  grind [bilinear, shifted, sum8]

theorem bilinear_shift_right (A : Nat → Nat → K)
    (X Y V : Variation K) (t : K) (i j : Nat) :
    bilinear A X (shifted t Y V) i j =
      bilinear A X Y i j + t * bilinear A X V i j := by
  have h0 := product8_shift A Y V t 0 j
  have h1 := product8_shift A Y V t 1 j
  have h2 := product8_shift A Y V t 2 j
  have h3 := product8_shift A Y V t 3 j
  have h4 := product8_shift A Y V t 4 j
  have h5 := product8_shift A Y V t 5 j
  have h6 := product8_shift A Y V t 6 j
  have h7 := product8_shift A Y V t 7 j
  grind [bilinear, sum8]

-- Algebraic derivative: the coefficient of t in S(X+tV).
theorem quadratic_taylor (A : Nat → Nat → K)
    (X V : Variation K) (t : K) (i j : Nat) :
    bilinear A (shifted t X V) (shifted t X V) i j =
      bilinear A X X i j +
      t * (bilinear A V X i j + bilinear A X V i j) +
      (t*t) * bilinear A V V i j := by
  calc
    bilinear A (shifted t X V) (shifted t X V) i j
        = bilinear A X (shifted t X V) i j +
          t * bilinear A V (shifted t X V) i j :=
          bilinear_shift_left A X V (shifted t X V) t i j
    _ = (bilinear A X X i j + t * bilinear A X V i j) +
          t * (bilinear A V X i j + t * bilinear A V V i j) := by
          rw [bilinear_shift_right A X X V t i j,
              bilinear_shift_right A V X V t i j]
    _ = bilinear A X X i j +
          t * (bilinear A V X i j + bilinear A X V i j) +
          (t*t) * bilinear A V V i j := by grind




theorem bilinear_eta_Vp (c u v : K) (V : Variation K)
    (i j : Nat) (hj : j < 4) :
    bilinear etaHat V (p c u v) i j =
       sum8 (fun k => V k i * etaP c u v k j) := by
  have h0 := etaP_exact c u v 0 j (by omega) hj
  have h1 := etaP_exact c u v 1 j (by omega) hj
  have h2 := etaP_exact c u v 2 j (by omega) hj
  have h3 := etaP_exact c u v 3 j (by omega) hj
  have h4 := etaP_exact c u v 4 j (by omega) hj
  have h5 := etaP_exact c u v 5 j (by omega) hj
  have h6 := etaP_exact c u v 6 j (by omega) hj
  have h7 := etaP_exact c u v 7 j (by omega) hj
  change sum8 (fun k => V k i * product8 etaHat (p c u v) k j)
    = sum8 (fun k => V k i * etaP c u v k j)
  simp only [sum8, h0, h1, h2, h3, h4, h5, h6, h7]

theorem bilinear_c_Vp (c u v : K) (V : Variation K)
    (i j : Nat) (hj : j < 4) :
    bilinear cHat V (p c u v) i j =
       sum8 (fun k => V k i * cP c u v k j) := by
  have h0 := cP_exact c u v 0 j (by omega) hj
  have h1 := cP_exact c u v 1 j (by omega) hj
  have h2 := cP_exact c u v 2 j (by omega) hj
  have h3 := cP_exact c u v 3 j (by omega) hj
  have h4 := cP_exact c u v 4 j (by omega) hj
  have h5 := cP_exact c u v 5 j (by omega) hj
  have h6 := cP_exact c u v 6 j (by omega) hj
  have h7 := cP_exact c u v 7 j (by omega) hj
  change sum8 (fun k => V k i * product8 cHat (p c u v) k j)
    = sum8 (fun k => V k i * cP c u v k j)
  simp only [sum8, h0, h1, h2, h3, h4, h5, h6, h7]

-- Symmetry and antisymmetry supply the transpose terms.
theorem bilinear_eta_pV (c u v : K) (V : Variation K)
    (i j : Nat) (hi : i < 4) :
    bilinear etaHat (p c u v) V i j =
       sum8 (fun k => V k j * etaP c u v k i) := by
  have icases : i = 0 ∨ i = 1 ∨ i = 2 ∨ i = 3 := by omega
  rcases icases with rfl | rfl | rfl | rfl
  all_goals simp [bilinear, product8, sum8, etaHat, etaP, p]
  all_goals grind

theorem bilinear_c_pV (c u v : K) (V : Variation K)
    (i j : Nat) (hi : i < 4) :
    bilinear cHat (p c u v) V i j =
       -sum8 (fun k => V k j * cP c u v k i) := by
  have icases : i = 0 ∨ i = 1 ∨ i = 2 ∨ i = 3 := by omega
  rcases icases with rfl | rfl | rfl | rfl
  all_goals simp [bilinear, product8, sum8, cHat, cP, p]
  all_goals grind

theorem metric_variation_exact (c u v : K) (V : Variation K)
    (i j : Nat) (hi : i < 4) (hj : j < 4) :
    bilinear etaHat V (p c u v) i j +
    bilinear etaHat (p c u v) V i j = dg c u v V i j := by
  rw [bilinear_eta_Vp c u v V i j hj,
      bilinear_eta_pV c u v V i j hi]
  grind [dg, sum8]

theorem flux_variation_exact (c u v : K) (V : Variation K)
    (i j : Nat) (hi : i < 4) (hj : j < 4) :
    bilinear cHat V (p c u v) i j +
    bilinear cHat (p c u v) V i j = df c u v V i j := by
  rw [bilinear_c_Vp c u v V i j hj,
      bilinear_c_pV c u v V i j hi]
  grind [df, sum8]

-- S(P+tV)=S(P)+t*DS_P(V)+t²*S(V), metric and flux.
theorem metric_taylor_exact (c u v : K) (V : Variation K) (t : K)
    (i j : Nat) (hi : i < 4) (hj : j < 4) :
    bilinear etaHat (shifted t (p c u v) V)
      (shifted t (p c u v) V) i j =
    bilinear etaHat (p c u v) (p c u v) i j +
      t * dg c u v V i j + (t*t) * bilinear etaHat V V i j := by
  have h := quadratic_taylor etaHat (p c u v) V t i j
  rw [metric_variation_exact c u v V i j hi hj] at h
  exact h

theorem flux_taylor_exact (c u v : K) (V : Variation K) (t : K)
    (i j : Nat) (hi : i < 4) (hj : j < 4) :
    bilinear cHat (shifted t (p c u v) V)
      (shifted t (p c u v) V) i j =
    bilinear cHat (p c u v) (p c u v) i j +
      t * df c u v V i j + (t*t) * bilinear cHat V V i j := by
  have h := quadratic_taylor cHat (p c u v) V t i j
  rw [flux_variation_exact c u v V i j hi hj] at h
  exact h

end SutureDifferentialBridge

#print axioms SutureDifferentialBridge.pairing_adjoint
#print axioms SutureDifferentialBridge.flip_0
#print axioms SutureDifferentialBridge.flip_2
#print axioms SutureDifferentialBridge.flip_4
#print axioms SutureDifferentialBridge.flip_6
#print axioms SutureDifferentialBridge.pairing_zero_iff_adjoint
#print axioms SutureDifferentialBridge.adjoint_matrix_iff
#print axioms SutureDifferentialBridge.variational_full_rank_iff
#print axioms SutureDifferentialBridge.euclidean_variational_full_rank_iff
#print axioms SutureDifferentialBridge.etaP_exact
#print axioms SutureDifferentialBridge.cP_exact
#print axioms SutureDifferentialBridge.jp_exact
#print axioms SutureDifferentialBridge.variational_wall_fifteen_independent
#print axioms SutureDifferentialBridge.variational_wall_has_relation
#print axioms SutureDifferentialBridge.quadratic_taylor
#print axioms SutureDifferentialBridge.metric_taylor_exact
#print axioms SutureDifferentialBridge.flux_taylor_exact
