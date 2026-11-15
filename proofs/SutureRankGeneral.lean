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


end SutureRankGeneral
#print axioms SutureRankGeneral.rank_criterion
#print axioms SutureRankGeneral.wall_kernel

#print axioms SutureRankGeneral.euclidean_rank_criterion
