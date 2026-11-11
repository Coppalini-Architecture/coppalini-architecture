/-!
# Projective return: one exact finite witness

This file formalizes the integer matrix that exchanges the chosen
homogeneous addresses infinity=[1:0] and one=[1:1], fixes the
projective address zero=[0:1], and fixes two=[2:1].

It proves identities in integer linear algebra. It makes no physical
claim about light, time, optics, consciousness, or an empirical system.
Tested target: Lean 4.33.0, with no Mathlib dependency.
-/
set_option autoImplicit false

namespace ProjectiveReturn

structure Mat2 where
  a : Int
  b : Int
  c : Int
  d : Int
  deriving DecidableEq, Repr

structure Vec2 where
  x : Int
  y : Int
  deriving DecidableEq, Repr

def mul (u v : Mat2) : Mat2 :=
  ⟨u.a * v.a + u.b * v.c, u.a * v.b + u.b * v.d,
   u.c * v.a + u.d * v.c, u.c * v.b + u.d * v.d⟩

def act (u : Mat2) (v : Vec2) : Vec2 :=
  ⟨u.a * v.x + u.b * v.y, u.c * v.x + u.d * v.y⟩

def scale (k : Int) (v : Vec2) : Vec2 :=
  ⟨k * v.x, k * v.y⟩

-- Homogeneous coordinates, read as points of the projective line.
def infinity : Vec2 := ⟨1, 0⟩
def zero : Vec2 := ⟨0, 1⟩
def one : Vec2 := ⟨1, 1⟩
def two : Vec2 := ⟨2, 1⟩

-- The involution induced by x -> x/(x-1).
def M : Mat2 := ⟨1, 0, 1, -1⟩
def I : Mat2 := ⟨1, 0, 0, 1⟩

-- Projective equality witnessed by a nonzero integer rescaling.
def SameProjective (u v : Vec2) : Prop :=
  ∃ k : Int, k ≠ 0 ∧ u = scale k v

theorem involution : mul M M = I := by decide

theorem infinity_to_one : act M infinity = one := by decide

theorem one_to_infinity : act M one = infinity := by decide

theorem zero_fixed_projectively : SameProjective (act M zero) zero := by
  refine ⟨-1, by decide, ?_⟩
  decide

theorem two_fixed : act M two = two := by decide

theorem infinity_return : act M (act M infinity) = infinity := by decide

theorem one_return : act M (act M one) = one := by decide

theorem zero_return : act M (act M zero) = zero := by decide


-- The opening source is an ordered pair of projective triples:
-- Light = (infinity, zero, one), Time = (one, zero, infinity).
-- Zero returns with a scalar sign: homogeneous/projective equality
-- is the correct type for this component.

def ProjectiveTriple (a b c d e f : Vec2) : Prop :=
  SameProjective a d ∧ SameProjective b e ∧ SameProjective c f

theorem light_to_time :
    ProjectiveTriple (act M infinity) (act M zero) (act M one)
      one zero infinity := by
  constructor
  · refine ⟨1, by decide, ?_⟩
    decide
  constructor
  · exact zero_fixed_projectively
  · refine ⟨1, by decide, ?_⟩
    decide

theorem time_to_light :
    ProjectiveTriple (act M one) (act M zero) (act M infinity)
      infinity zero one := by
  constructor
  · refine ⟨1, by decide, ?_⟩
    decide
  constructor
  · exact zero_fixed_projectively
  · refine ⟨1, by decide, ?_⟩
    decide

def determinant (m : Mat2) : Int := m.a * m.d - m.b * m.c

theorem determinant_is_minus_one : determinant M = -1 := by decide

-- An exact Gaussian-integer matrix realization of the central lift iM.
def zeroMatrix : Mat2 := ⟨0, 0, 0, 0⟩

def matAdd (u v : Mat2) : Mat2 :=
  ⟨u.a + v.a, u.b + v.b, u.c + v.c, u.d + v.d⟩

def matNeg (u : Mat2) : Mat2 :=
  ⟨-u.a, -u.b, -u.c, -u.d⟩

structure GaussianMat2 where
  re : Mat2
  im : Mat2
  deriving DecidableEq, Repr

def gMul (u v : GaussianMat2) : GaussianMat2 :=
  ⟨matAdd (mul u.re v.re) (matNeg (mul u.im v.im)),
   matAdd (mul u.re v.im) (mul u.im v.re)⟩

def gI : GaussianMat2 := ⟨I, zeroMatrix⟩
def gNegI : GaussianMat2 := ⟨matNeg I, zeroMatrix⟩
def iM : GaussianMat2 := ⟨zeroMatrix, M⟩

theorem lift_two_steps : gMul iM iM = gNegI := by decide
theorem lift_four_steps : gMul (gMul iM iM) (gMul iM iM) = gI := by decide

-- Zeno's exact finite identity in homogeneous integer coordinates.
-- q=2^n yields the n-th dichotomy stage: (q-1)/q = 1-2^(-n).
-- The map acts on the source [1-q:1], producing [- (q-1):-q].
theorem zeno_each_stage (q : Int) :
    act M ⟨1 - q, 1⟩ = scale (-1) ⟨q - 1, q⟩ := by
  simp [act, M, scale]
  omega

-- Indexing the occurrence preserves the difference between address
-- returning and the number of executed steps advancing.
def occurrenceStep (p : Vec2 × Nat) : Vec2 × Nat :=
  (act M p.1, p.2 + 1)

theorem infinity_occurrence_return (t : Nat) :
    (occurrenceStep (occurrenceStep (infinity, t))).1 = infinity := by
  simp [occurrenceStep, act, M, infinity]

theorem infinity_occurrence_advances (t : Nat) :
    (occurrenceStep (occurrenceStep (infinity, t))).2 = t + 2 := by
  simp [occurrenceStep]

end ProjectiveReturn
