import Init.Data.Rat.Basic
import proofs.CanonicalPoisson010f

/-!
# Minimum Mechanics 010f — canonical linear transport / Gauss semidirect bracket

A two-component canonical subchart (q0,q1,p0,p1) with {qi,pj}=δij.
For arbitrary integer 2×2 matrices T,U and a two-component vector s,
  D_T = pᵀ T q,    G_s = pᵀ s.
The gradients below are computed from these explicit polynomials.
The standard canonical Poisson tensor then gives
  {D_T,D_U} = D_(T U - U T),
  {D_T,G_s} = G_(T s),
  {G_s,G_t} = 0.
This is a finite-dimensional cotangent-lift representation of
gl(2) ⋉ Z²; it is a faithfully typed *algebraic* gauge/transport
adapter, not the complete spatial diffeomorphism Lie algebra of T³.
It introduces no new physical fields or empirical assumptions.
The geometric Dirac–ADM functional-constraint closure remains OPEN.
-/

set_option autoImplicit false

namespace LinearTransport010f

structure V2 where
  x : Int
  y : Int
  deriving DecidableEq, Repr

structure M2 where
  a : Int
  b : Int
  c : Int
  d : Int
  deriving DecidableEq, Repr

def vzero : V2 := ⟨0,0⟩
def ex : V2 := ⟨1,0⟩
def ey : V2 := ⟨0,1⟩

def dot (u v : V2) : Int := u.x*v.x + u.y*v.y
def addV (u v : V2) : V2 := ⟨u.x+v.x,u.y+v.y⟩

def apply (T : M2) (v : V2) : V2 :=
  ⟨T.a*v.x+T.b*v.y,T.c*v.x+T.d*v.y⟩

def transApply (T : M2) (v : V2) : V2 :=
  ⟨T.a*v.x+T.c*v.y,T.b*v.x+T.d*v.y⟩

def matMul (T U : M2) : M2 :=
  ⟨T.a*U.a+T.b*U.c,T.a*U.b+T.b*U.d,
   T.c*U.a+T.d*U.c,T.c*U.b+T.d*U.d⟩

def matNeg (T : M2) : M2 := ⟨-T.a,-T.b,-T.c,-T.d⟩
def matAdd (T U : M2) : M2 :=
  ⟨T.a+U.a,T.b+U.b,T.c+U.c,T.d+U.d⟩

def commutator (T U : M2) : M2 :=
  matAdd (matMul T U) (matNeg (matMul U T))

-- D_T is explicitly quadratic in the canonical q and p coordinates.
def D (T : M2) (q p : V2) : Int := dot p (apply T q)
def G (s : V2) (p : V2) : Int := dot p s

def gradDq (T : M2) (p : V2) : V2 := transApply T p
def gradDp (T : M2) (q : V2) : V2 := apply T q

def gradGq (_ : V2) : V2 := vzero
def gradGp (s : V2) : V2 := s

-- Canonical PB for the explicitly differentiated polynomials.
def canonicalPB (fq fp gq gp : V2) : Int :=
  dot fq gp - dot fp gq

def PB_DD (T U : M2) (q p : V2) : Int :=
  canonicalPB (gradDq T p) (gradDp T q)
    (gradDq U p) (gradDp U q)

def PB_DG (T : M2) (s p : V2) : Int :=
  canonicalPB (gradDq T p) vzero (gradGq s) (gradGp s)

def PB_GG (s t : V2) : Int :=
  canonicalPB (gradGq s) (gradGp s) (gradGq t) (gradGp t)

-- Derivative witnesses, before the Poisson claims.
theorem derivative_in_q (T : M2) (q dq p : V2) :
    D T (addV q dq) p = D T q p + dot (gradDq T p) dq := by
  simp only [D,addV,apply,transApply,gradDq,dot,
    Int.mul_add,Int.add_mul,Int.mul_assoc]
  simp only [Int.mul_comm, Int.mul_left_comm, Int.mul_assoc]
  omega

theorem derivative_in_p (T : M2) (q p dp : V2) :
    D T q (addV p dp) = D T q p + dot (gradDp T q) dp := by
  simp only [D,addV,apply,gradDp,dot,
    Int.mul_add,Int.add_mul,Int.mul_assoc]
  simp only [Int.mul_comm, Int.mul_left_comm, Int.mul_assoc]
  omega

theorem PB_Gauss_commutes (s t : V2) : PB_GG s t = 0 := by
  simp [PB_GG,canonicalPB,gradGq,gradGp,vzero,dot]

theorem PB_transport_Gauss (T : M2) (s p : V2) :
    PB_DG T s p = G (apply T s) p := by
  simp only [PB_DG,canonicalPB,gradDq,gradGp,gradGq,
     dot,transApply,apply,G,vzero]
  simp only [Int.mul_add,Int.add_mul,Int.mul_assoc]
  simp only [Int.mul_comm,Int.mul_left_comm,Int.mul_assoc]
  omega

theorem PB_transport_transport (T U : M2) (q p : V2) :
    PB_DD T U q p = D (commutator T U) q p := by
  simp only [PB_DD,canonicalPB,gradDq,gradDp,
     dot,transApply,apply, D,commutator,matAdd,matNeg,matMul,
     Int.mul_add,Int.add_mul,Int.mul_sub,Int.sub_mul,
     Int.neg_mul,Int.mul_neg,Int.mul_assoc]
  simp only [Int.mul_comm,Int.mul_left_comm,Int.mul_assoc]
  omega

-- The actual coordinate action of the canonical transport generator.
def PB_qD (T : M2) (q p : V2) : V2 := gradDp T q
def PB_pD (T : M2) (q p : V2) : V2 :=
  ⟨-(gradDq T p).x,-(gradDq T p).y⟩

theorem transport_coordinates (T : M2) (q p : V2) :
    PB_qD T q p = apply T q := rfl

theorem transport_momenta (T : M2) (q p : V2) :
    PB_pD T q p =
      ⟨-(T.a*p.x+T.c*p.y), -(T.b*p.x+T.d*p.y)⟩ := rfl

-- Witness that omitting the noncommutative matrix bracket would fail.
def shearX : M2 := ⟨0,1,0,0⟩
def shearY : M2 := ⟨0,0,1,0⟩
def qWitness : V2 := ⟨1,0⟩
def pWitness : V2 := ⟨1,0⟩

theorem noncommuting_transport_control :
    PB_DD shearX shearY qWitness pWitness = 1 := by decide

theorem semidirect_action_control :
    PB_DG shearX ey ex = 1 := by decide

#print axioms derivative_in_q
#print axioms derivative_in_p
#print axioms PB_Gauss_commutes
#print axioms PB_transport_Gauss
#print axioms PB_transport_transport
#print axioms transport_coordinates
#print axioms noncommuting_transport_control
#print axioms semidirect_action_control

end LinearTransport010f
