import Init.Grind

set_option autoImplicit false

/-!
# Suture Rank: Q.17(b-prime), parameter-general dual kernel

Formal variables c,u,v range over any field of characteristic different from 2.
The 8 by 4 coefficient equations are the expansion of P*n = J*P*m:
  P = (e0, e7, e2, -c*e3 + u*e4 + v*e5)
  J = Chat*eta
with m symmetric (ten slots), n alternating (six slots).
The first column is normalized by the invertible right coframe action.
No c*c+u*u+v*v=1 hypothesis enters.

The following definitions carry sixteen independent unknowns,
and eight rows of four scalar equations. The kernel is equivalent
to one scalar t=m33 satisfying u*t=v*t=0. In particular the row rank
is 16 off w=(u,v)=0 and 15 on it, by the dual rank theorem.
-/

namespace SutureRankGeneral

variable {K : Type} [Lean.Grind.Field K]

structure Dual (K : Type) where
  m00 : K
  m01 : K
  m02 : K
  m03 : K
  m11 : K
  m12 : K
  m13 : K
  m22 : K
  m23 : K
  m33 : K
  n01 : K
  n02 : K
  n03 : K
  n12 : K
  n13 : K
  n23 : K

-- One row of P*n - J*P*m at a time.
def row0 (d : Dual K) : Prop :=
  d.m00 = 0 ∧ d.m01 + d.n01 = 0 ∧
  d.m02 + d.n02 = 0 ∧ d.m03 + d.n03 = 0

def row1 (d : Dual K) : Prop :=
  (2:K)*d.m00 = 0 ∧ (2:K)*d.m01 = 0 ∧
  (2:K)*d.m02 = 0 ∧ (2:K)*d.m03 = 0

def row2 (c : K) (d : Dual K) : Prop :=
  -c*d.m03 - d.n02 = 0 ∧
  -c*d.m13 - d.n12 = 0 ∧
  -c*d.m23 = 0 ∧
  -c*d.m33 + d.n23 = 0

def row3 (c : K) (d : Dual K) : Prop :=
  c*d.n03 - d.m02 = 0 ∧
  c*d.n13 - d.m12 = 0 ∧
  c*d.n23 - d.m22 = 0 ∧
  -d.m23 = 0

def row4 (u v : K) (d : Dual K) : Prop :=
  d.m03*v - d.n03*u = 0 ∧
  d.m13*v - d.n13*u = 0 ∧
  d.m23*v - d.n23*u = 0 ∧
  d.m33*v = 0

def row5 (u v : K) (d : Dual K) : Prop :=
  -d.m03*u - d.n03*v = 0 ∧
  -d.m13*u - d.n13*v = 0 ∧
  -d.m23*u - d.n23*v = 0 ∧
  -d.m33*u = 0

def row6 (d : Dual K) : Prop :=
  d.m01 = 0 ∧ d.m11 = 0 ∧ d.m12 = 0 ∧ d.m13 = 0

def row7 (d : Dual K) : Prop :=
  -d.n01 = 0 ∧ (0:K) = 0 ∧ d.n12 = 0 ∧ d.n13 = 0

def Kernel (c u v : K) (d : Dual K) : Prop :=
  row0 d ∧ row1 d ∧ row2 c d ∧ row3 c d ∧
  row4 u v d ∧ row5 u v d ∧ row6 d ∧ row7 d

-- The unique possible left-kernel direction.
def lift (c t : K) : Dual K :=
 { m00 := 0, m01 := 0, m02 := 0, m03 := 0,
   m11 := 0, m12 := 0, m13 := 0,
   m22 := c*c*t, m23 := 0, m33 := t,
   n01 := 0, n02 := 0, n03 := 0,
   n12 := 0, n13 := 0, n23 := c*t }

def Normal (c u v : K) (d : Dual K) : Prop :=
  d.m00 = 0 ∧ d.m01 = 0 ∧ d.m02 = 0 ∧ d.m03 = 0 ∧
  d.m11 = 0 ∧ d.m12 = 0 ∧ d.m13 = 0 ∧
  d.m22 = c*c*d.m33 ∧ d.m23 = 0 ∧
  d.n01 = 0 ∧ d.n02 = 0 ∧ d.n03 = 0 ∧
  d.n12 = 0 ∧ d.n13 = 0 ∧
  d.n23 = c*d.m33 ∧ u*d.m33 = 0 ∧ v*d.m33 = 0

theorem kernel_normal (c u v : K) (two_ne : (2:K) ≠ 0) (d : Dual K) :
    Kernel c u v d ↔ Normal c u v d := by
  constructor
  · intro h
    grind [Kernel, Normal, row0, row1, row2, row3, row4, row5, row6, row7]
  · intro h
    grind [Kernel, Normal, row0, row1, row2, row3, row4, row5, row6, row7]

theorem normal_lift (c u v : K) (d : Dual K) :
    Normal c u v d ↔
      d = lift c d.m33 ∧ u*d.m33 = 0 ∧ v*d.m33 = 0 := by
  constructor
  · intro h
    constructor
    · cases d with
      | mk m00 m01 m02 m03 m11 m12 m13 m22 m23 m33 n01 n02 n03 n12 n13 n23 =>
        grind [Normal, lift]
    · exact ⟨h.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1, h.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2⟩
  · intro h
    grind [Normal, lift]

theorem kernel_lift (c u v : K) (two_ne : (2:K) ≠ 0) (d : Dual K) :
    Kernel c u v d ↔
      d = lift c d.m33 ∧ u*d.m33 = 0 ∧ v*d.m33 = 0 := by
  rw [kernel_normal c u v two_ne d, normal_lift c u v d]

theorem regular_kernel (c u v : K) (two_ne : (2:K) ≠ 0)
    (h : u ≠ 0 ∨ v ≠ 0) (d : Dual K)
    (hd : Kernel c u v d) : d = lift c 0 := by
  obtain ⟨heq, hu, hv⟩ := (kernel_lift c u v two_ne d).mp hd
  have ht : d.m33 = 0 := by
    grind
  rw [ht] at heq
  exact heq

theorem wall_kernel (c : K) (two_ne : (2:K) ≠ 0)
    (d : Dual K) :
    Kernel c 0 0 d ↔ ∃ t : K, d = lift c t := by
  constructor
  · intro h
    exact ⟨d.m33, (kernel_lift c 0 0 two_ne d).mp h |>.1⟩
  · rintro ⟨t, rfl⟩
    apply (kernel_lift c 0 0 two_ne (lift c t)).mpr
    simp [lift]
    grind

theorem lift_injective (c : K) :
    Function.Injective (lift c) := by
  intro t s h
  have h' := congrArg Dual.m33 h
  simpa [lift] using h'

theorem nonzero_wall (c : K) (two_ne : (2:K) ≠ 0) :
    ∃ d : Dual K, Kernel c 0 0 d ∧ d ≠ lift c 0 := by
  refine ⟨lift c 1, ?_, ?_⟩
  · exact (wall_kernel c two_ne (lift c 1)).mpr ⟨1, rfl⟩
  · intro h
    have h' := (lift_injective c h)
    grind

theorem rank_criterion (c u v : K) (two_ne : (2:K) ≠ 0) :
    (∀ d : Dual K, Kernel c u v d → d = lift c 0) ↔
      (u ≠ 0 ∨ v ≠ 0) := by
  constructor
  · intro h
    by_cases hu : u = 0
    · by_cases hv : v = 0
      · subst u
        subst v
        obtain ⟨d, hk, hn⟩ := nonzero_wall c two_ne
        exact False.elim (hn (h d hk))
      · exact Or.inr hv
    · exact Or.inl hu
  · intro h d hd
    exact regular_kernel c u v two_ne h d hd

-- Euclidean positivity is a separate, explicit property of the scalar domain.
def PositiveTwoSquare (K : Type) [Lean.Grind.Field K] : Prop :=
  ∀ a b : K, a*a + b*b = 0 → a = 0 ∧ b = 0

theorem euclidean_nonzero (u v : K) (hp : PositiveTwoSquare K) :
    (u*u + v*v ≠ 0) ↔ (u ≠ 0 ∨ v ≠ 0) := by
  constructor
  · intro h
    by_cases hu : u = 0
    · by_cases hv : v = 0
      · subst u
        subst v
        have z : (0:K)*(0:K) + (0:K)*(0:K) = 0 := by grind
        exact False.elim (h z)
      · exact Or.inr hv
    · exact Or.inl hu
  · intro h hnorm
    obtain ⟨hu, hv⟩ := hp u v hnorm
    grind

-- The rotation-invariant rank criterion (over a positive Euclidean domain).
theorem euclidean_rank_criterion (c u v : K)
    (two_ne : (2:K) ≠ 0) (hp : PositiveTwoSquare K) :
    (∀ d : Dual K, Kernel c u v d → d = lift c 0) ↔
      u*u + v*v ≠ 0 := by
  rw [rank_criterion c u v two_ne]
  exact (euclidean_nonzero u v hp).symm



-- Raw dual pairing of the suture differential in the fixed root coordinates.
-- p is the normalized eight-by-four coframe; jp = Jp for J = Chat*eta.
def p (c u v : K) (i j : Nat) : K :=
 match i, j with
 | 0, 0 => 1
 | 7, 1 => 1
 | 2, 2 => 1
 | 3, 3 => -c
 | 4, 3 => u
 | 5, 3 => v
 | _, _ => 0

def jp (c u v : K) (i j : Nat) : K :=
 match i, j with
 | 0, 0 => -1
 | 1, 0 => -2
 | 6, 1 => -1
 | 3, 2 => 1
 | 2, 3 => c
 | 4, 3 => -v
 | 5, 3 => u
 | _, _ => 0

def mVal (d : Dual K) (i j : Nat) : K :=
 match i, j with
 | 0, 0 => d.m00
 | 0, 1 => d.m01
 | 0, 2 => d.m02
 | 0, 3 => d.m03
 | 1, 0 => d.m01
 | 1, 1 => d.m11
 | 1, 2 => d.m12
 | 1, 3 => d.m13
 | 2, 0 => d.m02
 | 2, 1 => d.m12
 | 2, 2 => d.m22
 | 2, 3 => d.m23
 | 3, 0 => d.m03
 | 3, 1 => d.m13
 | 3, 2 => d.m23
 | 3, 3 => d.m33
 | _, _ => 0

def nVal (d : Dual K) (i j : Nat) : K :=
 match i, j with
 | 0, 1 => d.n01
 | 1, 0 => -d.n01
 | 0, 2 => d.n02
 | 2, 0 => -d.n02
 | 0, 3 => d.n03
 | 3, 0 => -d.n03
 | 1, 2 => d.n12
 | 2, 1 => -d.n12
 | 1, 3 => d.n13
 | 3, 1 => -d.n13
 | 2, 3 => d.n23
 | 3, 2 => -d.n23
 | _, _ => 0

def pN (c u v : K) (d : Dual K) (i j : Nat) : K :=
 p c u v i 0 * nVal d 0 j +
 p c u v i 1 * nVal d 1 j +
 p c u v i 2 * nVal d 2 j +
 p c u v i 3 * nVal d 3 j

def jpM (c u v : K) (d : Dual K) (i j : Nat) : K :=
 jp c u v i 0 * mVal d 0 j +
 jp c u v i 1 * mVal d 1 j +
 jp c u v i 2 * mVal d 2 j +
 jp c u v i 3 * mVal d 3 j

def RawRow (c u v : K) (d : Dual K) (i : Nat) : Prop :=
 pN c u v d i 0 = jpM c u v d i 0 ∧
 pN c u v d i 1 = jpM c u v d i 1 ∧
 pN c u v d i 2 = jpM c u v d i 2 ∧
 pN c u v d i 3 = jpM c u v d i 3

-- Thirty-two concrete scalar equations, packaged in eight four-component rows.
def MatrixKernel (c u v : K) (d : Dual K) : Prop :=
 ∀ i : Nat, i < 8 → RawRow c u v d i

theorem row0_equiv (c u v : K) (d : Dual K) :
    RawRow c u v d 0 ↔ row0 d := by
  grind [RawRow, row0, pN, jpM, p, jp, mVal, nVal]

theorem row1_equiv (c u v : K) (d : Dual K) :
    RawRow c u v d 1 ↔ row1 d := by
  grind [RawRow, row1, pN, jpM, p, jp, mVal, nVal]

theorem row2_equiv (c u v : K) (d : Dual K) :
    RawRow c u v d 2 ↔ row2 c d := by
  grind [RawRow, row2, pN, jpM, p, jp, mVal, nVal]

theorem row3_equiv (c u v : K) (d : Dual K) :
    RawRow c u v d 3 ↔ row3 c d := by
  grind [RawRow, row3, pN, jpM, p, jp, mVal, nVal]

theorem row4_equiv (c u v : K) (d : Dual K) :
    RawRow c u v d 4 ↔ row4 u v d := by
  grind [RawRow, row4, pN, jpM, p, jp, mVal, nVal]

theorem row5_equiv (c u v : K) (d : Dual K) :
    RawRow c u v d 5 ↔ row5 u v d := by
  grind [RawRow, row5, pN, jpM, p, jp, mVal, nVal]

theorem row6_equiv (c u v : K) (d : Dual K) :
    RawRow c u v d 6 ↔ row6 d := by
  grind [RawRow, row6, pN, jpM, p, jp, mVal, nVal]

theorem row7_equiv (c u v : K) (d : Dual K) :
    RawRow c u v d 7 ↔ row7 d := by
  grind [RawRow, row7, pN, jpM, p, jp, mVal, nVal]

theorem matrix_kernel_iff (c u v : K) (d : Dual K) :
    MatrixKernel c u v d ↔ Kernel c u v d := by
  constructor
  · intro h
    have h0 : RawRow c u v d 0 := h 0 (by omega)
    have h1 : RawRow c u v d 1 := h 1 (by omega)
    have h2 : RawRow c u v d 2 := h 2 (by omega)
    have h3 : RawRow c u v d 3 := h 3 (by omega)
    have h4 : RawRow c u v d 4 := h 4 (by omega)
    have h5 : RawRow c u v d 5 := h 5 (by omega)
    have h6 : RawRow c u v d 6 := h 6 (by omega)
    have h7 : RawRow c u v d 7 := h 7 (by omega)
    exact ⟨(row0_equiv c u v d).mp h0,
      (row1_equiv c u v d).mp h1,
      (row2_equiv c u v d).mp h2,
      (row3_equiv c u v d).mp h3,
      (row4_equiv c u v d).mp h4,
      (row5_equiv c u v d).mp h5,
      (row6_equiv c u v d).mp h6,
      (row7_equiv c u v d).mp h7⟩
  · intro h i hi
    have hi8 : i = 0 ∨ i = 1 ∨ i = 2 ∨ i = 3 ∨ i = 4 ∨ i = 5 ∨ i = 6 ∨ i = 7 := by omega
    rcases hi8 with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
    · exact (row0_equiv c u v d).mpr (h.1)
    · exact (row1_equiv c u v d).mpr (h.2.1)
    · exact (row2_equiv c u v d).mpr (h.2.2.1)
    · exact (row3_equiv c u v d).mpr (h.2.2.2.1)
    · exact (row4_equiv c u v d).mpr (h.2.2.2.2.1)
    · exact (row5_equiv c u v d).mpr (h.2.2.2.2.2.1)
    · exact (row6_equiv c u v d).mpr (h.2.2.2.2.2.2.1)
    · exact (row7_equiv c u v d).mpr (h.2.2.2.2.2.2.2)

-- Now rank is stated against the actual P*n = J*P*m pairing, not a proxy.
theorem matrix_rank_criterion (c u v : K) (two_ne : (2:K) ≠ 0) :
    (∀ d : Dual K, MatrixKernel c u v d → d = lift c 0) ↔
       (u ≠ 0 ∨ v ≠ 0) := by
  simpa only [matrix_kernel_iff] using rank_criterion c u v two_ne

theorem euclidean_matrix_rank_criterion (c u v : K)
    (two_ne : (2:K) ≠ 0) (hp : PositiveTwoSquare K) :
    (∀ d : Dual K, MatrixKernel c u v d → d = lift c 0) ↔
       u*u + v*v ≠ 0 := by
  simpa only [matrix_kernel_iff] using euclidean_rank_criterion c u v two_ne hp

end SutureRankGeneral
#print axioms SutureRankGeneral.rank_criterion
#print axioms SutureRankGeneral.wall_kernel

#print axioms SutureRankGeneral.euclidean_rank_criterion
