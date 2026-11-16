import Init.Data.Rat.Basic
import proofs.SmoothTransport010o

/-!
# Minimum Mechanics 010o — improved Maxwell spatial transport, 3×3 jets

This is the full componentwise Maxwell identity for a general pointwise
three-dimensional first jet of A_i, E^i and shift v^i:
 C_EM[v] := v^i F_ij E^j,
 G[v·A] := E^j ∂_j (v^i A_i), after Stokes,
 D_EM[v] := C_EM[v]+G[v·A] = E^j (L_v A)_j.

Every finite index contraction is explicit; the derivative of v^i A_i
is DERIVED with the Leibniz rule encoded in the jet, and no gauge term
is discarded. The negative control demonstrates that the unimproved
magnetic momentum generator generally fails to equal E·L_v A.

An independent smooth-boundary condition is needed to identify
G[v·A]=-∫ (v·A)∂_j E^j with its integrated by-parts presentation;
that condition is exactly the 010i/010o Stokes boundary office.

This is the geometric Maxwell 3D local identity, not yet the action on
the full gravitational metric and momentum under the functional
Poisson bracket. No new axioms, no Mathlib, no sorry.
-/

set_option autoImplicit false

namespace ImprovedMaxwell010o

abbrev Axis := Fin 3
def sum3 (f : Axis → Int) : Int := f 0 + f 1 + f 2

structure Jet where
  v : Axis → Int
  A : Axis → Int
  E : Axis → Int
  dA : Axis → Axis → Int
  dv : Axis → Axis → Int

def F (x : Jet) (i j : Axis) : Int := x.dA i j-x.dA j i

-- ∂_j(Σ_i v^i A_i) from the exact componentwise product rule.
def d_vA (x : Jet) (j : Axis) : Int :=
  sum3 (fun i => x.dv j i*x.A i+x.v i*x.dA j i)

def lieA (x : Jet) (j : Axis) : Int :=
  sum3 (fun i => x.v i*x.dA i j+x.dv j i*x.A i)

def momentumEM (x : Jet) : Int :=
  sum3 (fun j =>
    sum3 (fun i => x.v i*F x i j)*x.E j)

def gaussImprovement (x : Jet) : Int :=
  sum3 (fun j => d_vA x j*x.E j)

def improvedMomentum (x : Jet) : Int :=
  momentumEM x+gaussImprovement x

def canonicalCotangentLift (x : Jet) : Int :=
  sum3 (fun j => lieA x j*x.E j)

theorem magnetic_is_antisymmetric (x : Jet) (i j : Axis) :
    F x i j = -F x j i := by
  simp only [F]
  omega

theorem improved_momentum_equals_cotangent_transport (x : Jet) :
    improvedMomentum x = canonicalCotangentLift x := by
  simp only [improvedMomentum, momentumEM, gaussImprovement,
    canonicalCotangentLift, lieA, d_vA, F, sum3]
  simp only [Int.mul_add, Int.mul_sub, Int.add_mul, Int.sub_mul,
    Int.neg_mul, Int.mul_neg, Int.mul_assoc]
  simp only [Int.mul_comm, Int.mul_left_comm, Int.mul_assoc]
  simp only [← Int.mul_assoc]
  omega

-- Local witness that the gauge improvement is load-bearing.
def testJet : Jet :=
  { v := fun _ => 0
    A := fun i => if i=0 then 1 else 0
    E := fun i => if i=0 then 1 else 0
    dA := fun _ _ => 0
    dv := fun j i => if j=0 ∧ i=0 then 1 else 0 }

theorem unimproved_generator_negative_control :
    momentumEM testJet = 0 ∧
      gaussImprovement testJet = 1 ∧
      canonicalCotangentLift testJet = 1 := by decide

-- The full generator's 3D curl and exact gauge correction are now
-- available for later integration against a smooth volume form.
theorem improvement_restores_transport :
    improvedMomentum testJet = canonicalCotangentLift testJet := by
  exact improved_momentum_equals_cotangent_transport testJet

#print axioms magnetic_is_antisymmetric
#print axioms improved_momentum_equals_cotangent_transport
#print axioms unimproved_generator_negative_control
#print axioms improvement_restores_transport

end ImprovedMaxwell010o
