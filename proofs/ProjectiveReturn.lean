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

end ProjectiveReturn
