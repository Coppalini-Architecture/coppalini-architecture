import Init.Data.Rat.Basic
import proofs.LeviCivitaCurrent010k

/-!
# Minimum Mechanics 010l — full 3D algebraic Fourier diffeomorphism modes

Fixed predecessor 010a–010k. No source hashes are changed.

An arbitrary Fourier vector-field character is encoded by (k,u), where
k ∈ ℤ³ is the spatial wave address and u ∈ ℤ³ is its vector amplitude.
The Euler derivative on e^(ik·x) is k_i e^(ik·x); the physical torus
derivative supplies an additional i after complexification.

The vector-field commutator is constructed, rather than assumed:
  [D_(k,u),D_(l,v)] =
    D_(k+l, (u·l)v - (v·k)u).

The scalar/gauge mode is (m,a). Its Lie transport is
  D_(k,u) ⋅ (m,a) = (k+m, a(u·m)).
This module proves the 3-dimensional nonabelian vector-field Jacobi
identity and the semidirect compatibility of the action, with exact
integer arithmetic on all nine wave/amplitude coordinates.

These are algebraic Fourier modes (finite polynomials in the next
module), not a C∞ spatial diffeomorphism group or a representation of
the full dynamical Einstein–Maxwell functional constraints.
No sorry, no new axiom, no Mathlib dependency.
-/

set_option autoImplicit false

namespace FourierDiffeo010l

structure V3 where
  x : Int
  y : Int
  z : Int
  deriving DecidableEq, Repr

def zero : V3 := ⟨0,0,0⟩
def ex : V3 := ⟨1,0,0⟩
def ey : V3 := ⟨0,1,0⟩
def ez : V3 := ⟨0,0,1⟩
def add (a b : V3) : V3 := ⟨a.x+b.x,a.y+b.y,a.z+b.z⟩
def neg (a : V3) : V3 := ⟨-a.x,-a.y,-a.z⟩
def sub (a b : V3) : V3 := ⟨a.x-b.x,a.y-b.y,a.z-b.z⟩
def scale (c : Int) (a : V3) : V3 := ⟨c*a.x,c*a.y,c*a.z⟩
def dot (a b : V3) : Int := a.x*b.x+a.y*b.y+a.z*b.z

theorem add_comm (a b : V3) : add a b = add b a := by
  cases a with
  | mk ax ay az =>
    cases b with
    | mk bx by bz =>
      simp [add, V3.mk.injEq]
      omega

theorem add_assoc (a b c : V3) : add (add a b) c = add a (add b c) := by
  cases a with
  | mk ax ay az =>
    cases b with
    | mk bx by bz =>
      cases c with
      | mk cx cy cz =>
        simp [add, V3.mk.injEq]
        omega

theorem add_zero (a : V3) : add a zero = a := by
  cases a <;> simp [add, zero]

theorem dot_add_left (a b c : V3) :
    dot (add a b) c = dot a c + dot b c := by
  simp only [dot, add, Int.add_mul]
  omega

theorem dot_add_right (a b c : V3) :
    dot a (add b c) = dot a b + dot a c := by
  simp only [dot, add, Int.mul_add]
  omega

theorem dot_scale_left (t : Int) (a b : V3) :
    dot (scale t a) b = t*(dot a b) := by
  simp only [dot, scale, Int.mul_assoc, Int.mul_add]

theorem dot_scale_right (t : Int) (a b : V3) :
    dot a (scale t b) = t*(dot a b) := by
  simp only [dot, scale, Int.mul_assoc, Int.mul_add]
  simp only [Int.mul_comm, Int.mul_left_comm, Int.mul_assoc]

theorem dot_sub_left (a b c : V3) :
    dot (sub a b) c = dot a c - dot b c := by
  simp only [dot, sub, Int.sub_mul]
  omega

theorem dot_sub_right (a b c : V3) :
    dot a (sub b c) = dot a b - dot a c := by
  simp only [dot, sub, Int.mul_sub]
  omega

structure VectorMode where
  k : V3
  u : V3
  deriving DecidableEq, Repr

structure ScalarMode where
  k : V3
  a : Int
  deriving DecidableEq, Repr

def vectorBracket (A B : VectorMode) : VectorMode :=
  ⟨add A.k B.k,
   sub (scale (dot A.u B.k) B.u)
       (scale (dot B.u A.k) A.u)⟩

def scalarAction (A : VectorMode) (f : ScalarMode) : ScalarMode :=
  ⟨add A.k f.k, f.a * (dot A.u f.k)⟩

def zeroScalarBracket (_ _ : ScalarMode) : Int := 0

theorem vector_frequency_comm (A B : VectorMode) :
    (vectorBracket A B).k = (vectorBracket B A).k := by
  exact add_comm A.k B.k

theorem vector_amplitude_antisym (A B : VectorMode) :
    add (vectorBracket A B).u (vectorBracket B A).u = zero := by
  rcases A with ⟨k,u⟩
  rcases B with ⟨l,v⟩
  cases u with
  | mk ux uy uz =>
    cases v with
    | mk vx vy vz =>
      simp only [vectorBracket, add, sub, scale, dot, zero, V3.mk.injEq]
      omega

theorem scalar_frequency_compat (A B : VectorMode) (f : ScalarMode) :
    (scalarAction A (scalarAction B f)).k =
      (scalarAction B (scalarAction A f)).k := by
  simp only [scalarAction]
  rw [add_assoc A.k B.k f.k, add_assoc B.k A.k f.k]
  rw [add_comm A.k B.k]

-- The representation law is checked on an *arbitrary scalar character*.
-- It proves the D–D–G commutator without imposing a field-functional PB.
theorem scalar_semidirect_law (A B : VectorMode) (f : ScalarMode) :
    (scalarAction A (scalarAction B f)).a -
      (scalarAction B (scalarAction A f)).a =
      (scalarAction (vectorBracket A B) f).a := by
  rcases A with ⟨ak,au⟩
  rcases B with ⟨bk,bu⟩
  rcases f with ⟨fk,fa⟩
  simp only [scalarAction, vectorBracket, dot_add_right,
    dot_sub_left, dot_scale_left]
  simp only [Int.mul_add, Int.mul_sub, Int.add_mul, Int.sub_mul,
    Int.mul_assoc]
  simp only [Int.mul_comm, Int.mul_left_comm, Int.mul_assoc]
  omega

theorem scalar_gauge_commutes (f g : ScalarMode) :
    zeroScalarBracket f g = 0 := rfl

-- Every vector amplitude Jacobi address is included, for arbitrary
-- frequencies (k,l,m) and amplitudes (u,v,w) in ℤ³.
theorem vector_jacobi (A B C : VectorMode) :
    add (add (vectorBracket (vectorBracket A B) C).u
             (vectorBracket (vectorBracket B C) A).u)
             (vectorBracket (vectorBracket C A) B).u = zero := by
  rcases A with ⟨⟨kx,ky,kz⟩,⟨ux,uy,uz⟩⟩
  rcases B with ⟨⟨lx,ly,lz⟩,⟨vx,vy,vz⟩⟩
  rcases C with ⟨⟨mx,my,mz⟩,⟨wx,wy,wz⟩⟩
  simp only [vectorBracket, dot, add, sub, scale, zero,
    V3.mk.injEq, Int.mul_add, Int.mul_sub, Int.add_mul,
    Int.sub_mul, Int.mul_assoc, Int.neg_mul, Int.mul_neg]
  simp only [Int.mul_comm, Int.mul_left_comm, Int.mul_assoc]
  simp only [← Int.mul_assoc]
  omega

-- Crossed coordinate-and-frequency modes give nontrivial Lie brackets.
def testA : VectorMode := ⟨ex,ey⟩
def testB : VectorMode := ⟨ey,ex⟩

theorem noncommuting_diffeomorphisms :
    (vectorBracket testA testB).u = sub ex ey := by decide

theorem gauge_shift_nonzero :
    (scalarAction testA ⟨ey,2⟩).a = 2 := by decide

#print axioms vector_frequency_comm
#print axioms vector_amplitude_antisym
#print axioms scalar_semidirect_law
#print axioms scalar_gauge_commutes
#print axioms vector_jacobi
#print axioms noncommuting_diffeomorphisms
#print axioms gauge_shift_nonzero

end FourierDiffeo010l
