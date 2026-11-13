import Init.Data.Rat.Basic
import proofs.ProjectiveReturn

/-!
# Root / projective adapters

This file bridges the published 2 x 2 root algebra to the already-certified
projective-return witness in `ProjectiveReturn.lean`.

Real bridge:
  P * H * P^{-1} = M
where H = G / sqrt(5), G = [[-2,1],[1,2]], and
P = [[1, 2 + sqrt(5)], [0, sqrt(5)]].

The real arithmetic is represented exactly in Q(sqrt(5)) as pairs a + b*sqrt(5)
with a,b : Rat.  This is necessary because H and P^{-1} are not elements of
Z[sqrt(5)], even though G and P are.

Complex bridge:
  Z * C * Z^{-1} = iM
where C = [[0,-1],[1,0]] and Z = [[1,i],[0,i]].

All displayed adapter identities below are closed finite equalities proved by
`decide`.  No Mathlib dependency is introduced.
Tested target for the parent certificate: Lean 4.33.0.
-/

set_option autoImplicit false

namespace RootProjectiveAdapters

open ProjectiveReturn

/-! ## Integer-only Z[sqrt(5)] carrier (no Rat)

Primary denominator-free statements.  Every entry of G, M and P lies in
Z[sqrt(5)], so `P G = sqrt(5) M P` and `G^2 = 5 I` are decided over Int alone,
in the same style as the already-certified `ProjectiveReturn.lean`. -/

structure Z5 where
  rat : Int
  irr : Int
  deriving DecidableEq, Repr

def z5OfInt (n : Int) : Z5 := ⟨n, 0⟩
def z5Add (u v : Z5) : Z5 := ⟨u.rat + v.rat, u.irr + v.irr⟩
def z5Mul (u v : Z5) : Z5 :=
  ⟨u.rat * v.rat + 5 * u.irr * v.irr, u.rat * v.irr + u.irr * v.rat⟩

structure Z5Mat2 where
  a : Z5
  b : Z5
  c : Z5
  d : Z5
  deriving DecidableEq, Repr

def z5MatMul (u v : Z5Mat2) : Z5Mat2 :=
  ⟨z5Add (z5Mul u.a v.a) (z5Mul u.b v.c),
   z5Add (z5Mul u.a v.b) (z5Mul u.b v.d),
   z5Add (z5Mul u.c v.a) (z5Mul u.d v.c),
   z5Add (z5Mul u.c v.b) (z5Mul u.d v.d)⟩

def z5MatScale (k : Z5) (u : Z5Mat2) : Z5Mat2 :=
  ⟨z5Mul k u.a, z5Mul k u.b, z5Mul k u.c, z5Mul k u.d⟩

def z5Lift (u : Mat2) : Z5Mat2 :=
  ⟨z5OfInt u.a, z5OfInt u.b, z5OfInt u.c, z5OfInt u.d⟩

def zI : Z5Mat2 := z5Lift ProjectiveReturn.I
def zM : Z5Mat2 := z5Lift ProjectiveReturn.M
def zG : Z5Mat2 := z5Lift ⟨-2, 1, 1, 2⟩
def zSqrt5 : Z5 := ⟨0, 1⟩
-- P = [[1, 2 + sqrt(5)], [0, sqrt(5)]]
def zP : Z5Mat2 := ⟨⟨1, 0⟩, ⟨2, 1⟩, ⟨0, 0⟩, ⟨0, 1⟩⟩

theorem z_G_square : z5MatMul zG zG = z5MatScale (z5OfInt 5) zI := by decide

-- Integral form of the real bridge: P G = sqrt(5) M P.
theorem z_real_adapter_intertwiner :
    z5MatMul zP zG = z5MatScale zSqrt5 (z5MatMul zM zP) := by decide


/-! ## Exact Q(sqrt(5)) carrier -/

structure Qsqrt5 where
  rat : Rat
  irr : Rat
  deriving DecidableEq, Repr

def qZero : Qsqrt5 := ⟨0, 0⟩
def qOne : Qsqrt5 := ⟨1, 0⟩
def qSqrt5 : Qsqrt5 := ⟨0, 1⟩
def qInvSqrt5 : Qsqrt5 := ⟨0, Rat.divInt 1 5⟩

def qOfInt (n : Int) : Qsqrt5 := ⟨Rat.ofInt n, 0⟩

def qAdd (u v : Qsqrt5) : Qsqrt5 :=
  ⟨u.rat + v.rat, u.irr + v.irr⟩

def qNeg (u : Qsqrt5) : Qsqrt5 :=
  ⟨-u.rat, -u.irr⟩

def qSub (u v : Qsqrt5) : Qsqrt5 :=
  qAdd u (qNeg v)

def qMul (u v : Qsqrt5) : Qsqrt5 :=
  ⟨u.rat * v.rat + 5 * u.irr * v.irr,
   u.rat * v.irr + u.irr * v.rat⟩

theorem sqrt5_square : qMul qSqrt5 qSqrt5 = qOfInt 5 := by decide +kernel

theorem sqrt5_inverse : qMul qSqrt5 qInvSqrt5 = qOne := by decide +kernel

structure QMat2 where
  a : Qsqrt5
  b : Qsqrt5
  c : Qsqrt5
  d : Qsqrt5
  deriving DecidableEq, Repr

def qMatMul (u v : QMat2) : QMat2 :=
  ⟨qAdd (qMul u.a v.a) (qMul u.b v.c),
   qAdd (qMul u.a v.b) (qMul u.b v.d),
   qAdd (qMul u.c v.a) (qMul u.d v.c),
   qAdd (qMul u.c v.b) (qMul u.d v.d)⟩

def qMatTranspose (u : QMat2) : QMat2 :=
  ⟨u.a, u.c, u.b, u.d⟩

def qMatScale (k : Qsqrt5) (u : QMat2) : QMat2 :=
  ⟨qMul k u.a, qMul k u.b, qMul k u.c, qMul k u.d⟩

def qDeterminant (u : QMat2) : Qsqrt5 :=
  qSub (qMul u.a u.d) (qMul u.b u.c)

def qLiftIntMat (u : Mat2) : QMat2 :=
  ⟨qOfInt u.a, qOfInt u.b, qOfInt u.c, qOfInt u.d⟩

def qI : QMat2 := qLiftIntMat ProjectiveReturn.I

def qM : QMat2 := qLiftIntMat ProjectiveReturn.M

-- Published root matrices.
def GInt : Mat2 := ⟨-2, 1, 1, 2⟩
def qG : QMat2 := qLiftIntMat GInt

def qH : QMat2 := qMatScale qInvSqrt5 qG

-- P = [[1, 2 + sqrt(5)], [0, sqrt(5)]].
def P : QMat2 :=
  ⟨qOne, ⟨2, 1⟩,
   qZero, qSqrt5⟩

-- P^{-1} = [[1, -1 - (2/5)sqrt(5)], [0, (1/5)sqrt(5)]].
def PInv : QMat2 :=
  ⟨qOne, ⟨-1, Rat.divInt (-2) 5⟩,
   qZero, qInvSqrt5⟩

-- The root form transported to the projective-return carrier.
def qProjectiveForm : QMat2 :=
  qMatMul (qMatTranspose PInv) (qMatMul qG PInv)

theorem G_square :
    qMatMul qG qG = qMatScale (qOfInt 5) qI := by decide +kernel

theorem H_square : qMatMul qH qH = qI := by decide +kernel

theorem P_determinant : qDeterminant P = qSqrt5 := by decide +kernel

theorem P_determinant_nonzero : qDeterminant P ≠ qZero := by decide +kernel

theorem P_inverse_right : qMatMul P PInv = qI := by decide +kernel

theorem P_inverse_left : qMatMul PInv P = qI := by decide +kernel

-- Integral form of the same bridge, before adjoining 1/sqrt(5):
--     P G = sqrt(5) M P.
theorem real_adapter_intertwiner :
    qMatMul P qG = qMatScale qSqrt5 (qMatMul qM P) := by decide +kernel

-- Direct published-root -> projective-return conjugacy.
theorem real_adapter_conjugacy :
    qMatMul (qMatMul P qH) PInv = qM := by decide +kernel

-- The projective return preserves the transported root form:
-- Mᵀ (P⁻ᵀ G P⁻¹) M = P⁻ᵀ G P⁻¹.
theorem projective_return_form_invariant :
    qMatMul (qMatTranspose qM) (qMatMul qProjectiveForm qM) =
      qProjectiveForm := by decide +kernel

/-! ## Exact Gaussian-integer carrier -/

-- C = -Omega = [[0,-1],[1,0]].
def C : Mat2 := ⟨0, -1, 1, 0⟩

def gC : GaussianMat2 := ⟨C, zeroMatrix⟩

-- Z = [[1,i],[0,i]].
def Z : GaussianMat2 :=
  ⟨⟨1, 0, 0, 0⟩,
   ⟨0, 1, 0, 1⟩⟩

-- Z^{-1} = [[1,-1],[0,-i]].
def ZInv : GaussianMat2 :=
  ⟨⟨1, -1, 0, 0⟩,
   ⟨0, 0, 0, -1⟩⟩

theorem C_square : mul C C = matNeg ProjectiveReturn.I := by decide

theorem Z_inverse_right : gMul Z ZInv = gI := by decide

theorem Z_inverse_left : gMul ZInv Z = gI := by decide

-- Inverse-free form: Z C = (iM) Z.
theorem complex_adapter_intertwiner :
    gMul Z gC = gMul ProjectiveReturn.iM Z := by decide

-- Direct root-quarter-turn -> projective central-lift conjugacy.
theorem complex_adapter_conjugacy :
    gMul (gMul Z gC) ZInv = ProjectiveReturn.iM := by decide

end RootProjectiveAdapters
