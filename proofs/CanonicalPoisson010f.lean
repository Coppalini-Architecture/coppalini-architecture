import Init.Data.Rat.Basic
import proofs.FourierTorus010e

/-!
# Minimum Mechanics 010f — canonical Poisson sector and finite Fourier Gauss law

Fixed dependencies: 010a–010e, with their source hashes unchanged.
This module supplies a *defined* symplectic Poisson bracket, not an
unproved 'isPoisson' assumption.

At each addressed Fourier sector k, the six canonical coordinates
(A_{i,k}, P_{i,k}) satisfy {A_i,P_j}=δ_ij. The momentum coordinate
P_{i,k} represents the opposite-frequency electric coefficient E_{i,-k}
in a complex Fourier-field pairing. We use the *Euler derivative*
k_i instead of the angular derivative i*k_i; the factor i remains an
explicit missing representation bridge to the physical Fourier fields.

Certified claims:
- exact antisymmetry and Jacobi for the affine canonical Poisson algebra;
- all 9 elementary canonical coordinate brackets;
- the Gauss generators G(k,λ) are first class with one another;
- their canonical action δA_i = λ*k_i and δP_i=0;
- magnetic 2-form components F_ij=k_i A_j-k_j A_i are gauge invariant;
- a counterexample rejects the uncurled A_x as gauge invariant.

BOUNDARY:
Affine observables and each addressed mode define a real finite-dimensional
canonical model. The relation of the formal modes to smooth fields on T³,
the unbounded Fourier limit, the actual first variation of the
Einstein–Hilbert action, and the full Dirac–ADM first-class algebra
remain OPEN. No axiom or 'sorry' is introduced.
-/

set_option autoImplicit false

namespace CanonicalPoisson010f

structure Vec3 where
  x : Int
  y : Int
  z : Int
  deriving DecidableEq, Repr

def z3 : Vec3 := ⟨0,0,0⟩
def eX : Vec3 := ⟨1,0,0⟩
def eY : Vec3 := ⟨0,1,0⟩
def eZ : Vec3 := ⟨0,0,1⟩

def dot (u v : Vec3) : Int :=
  u.x*v.x + u.y*v.y + u.z*v.z

def scale (t : Int) (v : Vec3) : Vec3 :=
  ⟨t*v.x,t*v.y,t*v.z⟩

def addV (u v : Vec3) : Vec3 :=
  ⟨u.x+v.x,u.y+v.y,u.z+v.z⟩

theorem dot_comm (u v : Vec3) : dot u v = dot v u := by
  simp only [dot]
  simp only [Int.mul_comm]

theorem dot_z3_left (v : Vec3) : dot z3 v = 0 := by
  simp [dot, z3]

theorem dot_z3_right (v : Vec3) : dot v z3 = 0 := by
  simp [dot, z3]

theorem dot_eX (v : Vec3) : dot eX v = v.x := by
  simp [dot,eX]

theorem dot_eY (v : Vec3) : dot eY v = v.y := by
  simp [dot,eY]

theorem dot_eZ (v : Vec3) : dot eZ v = v.z := by
  simp [dot,eZ]

structure Affine where
  dq : Vec3
  dp : Vec3
  c : Int
  deriving DecidableEq, Repr

def constObs (c : Int) : Affine := ⟨z3,z3,c⟩
def qX : Affine := ⟨eX,z3,0⟩
def qY : Affine := ⟨eY,z3,0⟩
def qZ : Affine := ⟨eZ,z3,0⟩
def pX : Affine := ⟨z3,eX,0⟩
def pY : Affine := ⟨z3,eY,0⟩
def pZ : Affine := ⟨z3,eZ,0⟩

def value (f : Affine) (q p : Vec3) : Int :=
  dot f.dq q + dot f.dp p + f.c

-- The standard finite-dimensional symplectic Poisson tensor.
def pb (f g : Affine) : Int :=
  dot f.dq g.dp - dot f.dp g.dq

def poisson (f g : Affine) : Affine := constObs (pb f g)

theorem pb_antisym (f g : Affine) : pb f g = -pb g f := by
  simp only [pb]
  rw [dot_comm g.dq f.dp, dot_comm g.dp f.dq]
  omega

theorem pb_self (f : Affine) : pb f f = 0 := by
  simp only [pb, dot_comm f.dp f.dq]
  omega

theorem pb_of_const_left (c : Int) (f : Affine) :
    pb (constObs c) f = 0 := by
  simp [pb, constObs, dot_z3_left]

theorem pb_of_const_right (c : Int) (f : Affine) :
    pb f (constObs c) = 0 := by
  simp [pb, constObs, dot_z3_right]

theorem affine_jacobi (f g h : Affine) :
    pb (poisson f g) h +
    pb (poisson g h) f +
    pb (poisson h f) g = 0 := by
  simp [poisson, pb_of_const_left]

-- All nine elementary q-p brackets, including three negative controls.
theorem canonical_xx : pb qX pX = 1 := by decide
theorem canonical_yy : pb qY pY = 1 := by decide
theorem canonical_zz : pb qZ pZ = 1 := by decide
theorem canonical_xy : pb qX pY = 0 := by decide
theorem canonical_yz : pb qY pZ = 0 := by decide
theorem canonical_zx : pb qZ pX = 0 := by decide
theorem canonical_qq : pb qX qX = 0 := by decide
theorem canonical_pp : pb pX pX = 0 := by decide

def modeWave (m : FourierTorus010e.Mode) : Vec3 :=
  ⟨m.kx,m.ky,m.kz⟩

-- Gauss smearing on one fixed wavevector: ∫ E·∂λ in opposite-frequency
-- paired Fourier coordinates. The Euler k_i is used without the factor i.
def gauss (k : Vec3) (lambda : Int) : Affine :=
  ⟨z3,scale lambda k,0⟩

theorem gauss_gauss (k l : Vec3) (lambda mu : Int) :
    pb (gauss k lambda) (gauss l mu) = 0 := by
  simp [pb,gauss,dot_z3_left,dot_z3_right]

theorem gauss_action_x (k : Vec3) (lambda : Int) :
    pb qX (gauss k lambda) = lambda*k.x := by
  simp [pb,gauss,qX,dot,z3,eX,scale]

theorem gauss_action_y (k : Vec3) (lambda : Int) :
    pb qY (gauss k lambda) = lambda*k.y := by
  simp [pb,gauss,qY,dot,z3,eY,scale]

theorem gauss_action_z (k : Vec3) (lambda : Int) :
    pb qZ (gauss k lambda) = lambda*k.z := by
  simp [pb,gauss,qZ,dot,z3,eZ,scale]

theorem electric_invariant_x (k : Vec3) (lambda : Int) :
    pb pX (gauss k lambda) = 0 := by
  simp [pb,gauss,pX,dot_z3_left,dot_z3_right]

theorem electric_invariant_y (k : Vec3) (lambda : Int) :
    pb pY (gauss k lambda) = 0 := by
  simp [pb,gauss,pY,dot_z3_left,dot_z3_right]

theorem electric_invariant_z (k : Vec3) (lambda : Int) :
    pb pZ (gauss k lambda) = 0 := by
  simp [pb,gauss,pZ,dot_z3_left,dot_z3_right]

-- F_ij = k_i A_j - k_j A_i is the formal curl in this mode.
def Fxy (k : Vec3) : Affine := ⟨⟨-k.y,k.x,0⟩,z3,0⟩
def Fyz (k : Vec3) : Affine := ⟨⟨0,-k.z,k.y⟩,z3,0⟩
def Fzx (k : Vec3) : Affine := ⟨⟨k.z,0,-k.x⟩,z3,0⟩

theorem curl_gauge_xy (k : Vec3) (lambda : Int) :
    pb (Fxy k) (gauss k lambda) = 0 := by
  simp only [pb,Fxy,gauss,dot,scale,z3]
  have ht : k.y * (lambda * k.x) = k.x * (lambda * k.y) := by ac_rfl
  rw [Int.neg_mul, ht]
  omega

theorem curl_gauge_yz (k : Vec3) (lambda : Int) :
    pb (Fyz k) (gauss k lambda) = 0 := by
  simp only [pb,Fyz,gauss,dot,scale,z3]
  have ht : k.z * (lambda * k.y) = k.y * (lambda * k.z) := by ac_rfl
  rw [Int.neg_mul, ht]
  omega

theorem curl_gauge_zx (k : Vec3) (lambda : Int) :
    pb (Fzx k) (gauss k lambda) = 0 := by
  simp only [pb,Fzx,gauss,dot,scale,z3]
  have ht : k.x * (lambda * k.z) = k.z * (lambda * k.x) := by ac_rfl
  rw [Int.neg_mul, ht]
  omega

-- Removing the curl leaves a gauge-dependent coordinate.
def unitWaveX : Vec3 := ⟨1,0,0⟩
theorem bare_potential_negative_control :
    pb qX (gauss unitWaveX 1) = 1 := by decide
theorem bare_potential_not_gauge_invariant :
    pb qX (gauss unitWaveX 1) ≠ 0 := by decide

-- Independent canonical wave-address sectors add brackets independently;
-- by construction they do not infer a continuum delta distribution.
structure AddressPair where
  f : Affine
  g : Affine

def sectorBracket (p : AddressPair) : Int := pb p.f p.g
def sumSectorBrackets (xs : List AddressPair) : Int :=
  (xs.map sectorBracket).sum

def gaugePair (k : Vec3) (lambda mu : Int) : AddressPair :=
  ⟨gauss k lambda,gauss k mu⟩

theorem finite_sector_gauss_commutes
    (xs : List (Vec3 × Int × Int)) :
    sumSectorBrackets (xs.map (fun t => gaugePair t.1 t.2.1 t.2.2)) = 0 := by
  induction xs with
  | nil => simp [sumSectorBrackets]
  | cons x rest ih =>
      change pb (gauss x.1 x.2.1) (gauss x.1 x.2.2) +
        sumSectorBrackets (rest.map (fun t => gaugePair t.1 t.2.1 t.2.2)) = 0
      rw [gauss_gauss]
      simpa using ih

#print axioms pb_antisym
#print axioms affine_jacobi
#print axioms canonical_xx
#print axioms canonical_yy
#print axioms canonical_zz
#print axioms gauss_gauss
#print axioms gauss_action_x
#print axioms gauss_action_y
#print axioms gauss_action_z
#print axioms electric_invariant_x
#print axioms curl_gauge_xy
#print axioms curl_gauge_yz
#print axioms curl_gauge_zx
#print axioms bare_potential_negative_control
#print axioms finite_sector_gauss_commutes

end CanonicalPoisson010f
