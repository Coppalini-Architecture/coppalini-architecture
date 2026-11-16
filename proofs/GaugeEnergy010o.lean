import Init.Data.Rat.Basic
import proofs.Maxwell010b
import proofs.ImprovedMaxwell010o

/-!
# Minimum Mechanics 010o — full three-dimensional Maxwell gauge invariance

This module strengthens the source variation for G-H. The Maxwell
energy density depends on the electric field E and the alternating
curvature F_ij=d_i A_j-d_j A_i, with arbitrary fixed coefficients for
the E_i E_j and F_ij F_kl bilinear contractions. This includes the
off-diagonal metric and anisotropic constitutive coefficients, at
a fixed metric; gauge transformations act only on A.

For every symmetric second derivative field ddα, including a
variation t·ddα, F(A+t dα)=F(A) in all nine slots. The complete
quadratic EM energy is therefore gauge invariant for every integer t.
This is an actual finite first-variation result: the corresponding
gauge-direction coefficient is exactly zero.

No claim that a general metric is dynamically fixed under the
Hamiltonian flow. The smooth functional differentiability and
integration-by-parts bridge to {G,H}=0 remains an explicitly OPEN
realization, tracked by FunctionalClosure010o.

No new axioms, no sorry, no Mathlib. Lean 4.33.0.
-/
set_option autoImplicit false

namespace GaugeEnergy010o

abbrev Axis := Fin 3
abbrev Matrix := Maxwell010b.FirstJet

def sum3 (f : Axis → Int) : Int := f 0+f 1+f 2

def flux (dA : Matrix) (i j : Axis) : Int :=
  Maxwell010b.fieldStrength dA i j

def gaugeJet (dA ddAlpha : Matrix) (t : Int) : Matrix :=
  fun i j => dA i j + t * ddAlpha i j

def electricTerm (e : Axis → Int) (weights : Axis → Axis → Int) : Int :=
  sum3 (fun i => sum3 (fun j => weights i j * e i * e j))

def magneticTerm (f : Matrix) (weights : Axis → Axis → Axis → Axis → Int) : Int :=
  sum3 (fun i => sum3 (fun j =>
    sum3 (fun k => sum3 (fun l =>
      weights i j k l * f i j * f k l))))

def energy (e : Axis → Int)
    (electricWeights : Axis → Axis → Int)
    (magneticWeights : Axis → Axis → Axis → Axis → Int)
    (dA : Matrix) : Int :=
  electricTerm e electricWeights +
    magneticTerm (flux dA) magneticWeights

theorem symmetric_hessian_remains_symmetric
    (ddAlpha : Matrix) (t : Int)
    (hcomm : ∀ i j, ddAlpha i j = ddAlpha j i) :
    ∀ i j, t*ddAlpha i j = t*ddAlpha j i := by
  intro i j
  rw [hcomm i j]

theorem gauge_curl_pointwise
    (dA ddAlpha : Matrix) (t : Int)
    (hcomm : ∀ i j, ddAlpha i j = ddAlpha j i)
    (i j : Axis) :
    flux (gaugeJet dA ddAlpha t) i j = flux dA i j := by
  exact Maxwell010b.gauss_gauge_invariance
    dA (fun i j => t*ddAlpha i j)
    (symmetric_hessian_remains_symmetric ddAlpha t hcomm) i j

theorem gauge_curl_extensional
    (dA ddAlpha : Matrix) (t : Int)
    (hcomm : ∀ i j, ddAlpha i j = ddAlpha j i) :
    flux (gaugeJet dA ddAlpha t) = flux dA := by
  funext i j
  exact gauge_curl_pointwise dA ddAlpha t hcomm i j

theorem full_Maxwell_energy_gauge_invariant
    (e : Axis → Int)
    (electricWeights : Axis → Axis → Int)
    (magneticWeights : Axis → Axis → Axis → Axis → Int)
    (dA ddAlpha : Matrix) (t : Int)
    (hcomm : ∀ i j, ddAlpha i j = ddAlpha j i) :
    energy e electricWeights magneticWeights
      (gaugeJet dA ddAlpha t) =
    energy e electricWeights magneticWeights dA := by
  simp only [energy]
  rw [gauge_curl_extensional dA ddAlpha t hcomm]

-- This exhibits gauge-direction flatness of the *entire quadratic
-- energy polynomial* for all t, so all Taylor coefficients vanish.
theorem Maxwell_first_gauge_variation_zero
    (e : Axis → Int)
    (electricWeights : Axis → Axis → Int)
    (magneticWeights : Axis → Axis → Axis → Axis → Int)
    (dA ddAlpha : Matrix)
    (hcomm : ∀ i j, ddAlpha i j = ddAlpha j i) :
    energy e electricWeights magneticWeights
      (gaugeJet dA ddAlpha 1) -
    energy e electricWeights magneticWeights dA = 0 := by
  rw [full_Maxwell_energy_gauge_invariant
    e electricWeights magneticWeights dA ddAlpha 1 hcomm]
  omega

#print axioms symmetric_hessian_remains_symmetric
#print axioms gauge_curl_pointwise
#print axioms gauge_curl_extensional
#print axioms full_Maxwell_energy_gauge_invariant
#print axioms Maxwell_first_gauge_variation_zero

end GaugeEnergy010o
