import Init.Data.Rat.Basic
import proofs.FunctionalClosure010o
import proofs.ADMGradient010p
import proofs.GaugeEnergy010o

/-!
# Minimum Mechanics 010s — retained local normal-current and gauge attachment

Imports are deliberate. The 010p nonlinear DeWitt-gradient proof and
010o gauge-energy proof are placed in a shared source ancestry.

This module closes the precise finite-address joint statement:
  * the actual 010p local canonical PB equals its computed current;
  * the 010p lapse-derived metric shift lowers back to the original
    covariant lapse wedge;
  * the same shift contracts gravitational and Maxwell momenta;
  * the 010o quadratic Maxwell energy is gauge-invariant for
    commuting mixed second derivatives.

The data here are Int-valued local jets, not C-infinity real fields.
The existing FunctionalClosure010o.SmoothCompletion still requires
a full smooth weak symplectic pairing and Hamiltonian first variations.
No C-infinity instance is constructed or claimed by this module.
-/

set_option autoImplicit false
namespace FieldAttachment010s

abbrev Axis := Fin 3
abbrev M := MetricInverse010i.Mat3
abbrev Vec := Axis → Int

structure LocalPacket where
  source : ADMGradient010p.Address
  symmetric : ∀ i j : Axis, source.g i j = source.g j i
  dN : Vec
  dM : Vec
  divPi : Vec
  electric : Vec
  curvature : M

def covLapseWedge (x : LocalPacket) : Vec :=
  MetricShift010p.covCurrent x.source.n x.source.m x.dN x.dM

def contravariantShift (x : LocalPacket) : Vec :=
  MetricShift010p.raisedShift x.source.B
    x.source.n x.source.m x.dN x.dM

theorem shift_lowers_exactly (x : LocalPacket) (k : Axis) :
    MetricShift010p.loweredRaised x.source.g x.source.B
      (covLapseWedge x) k = covLapseWedge x k := by
  exact MetricShift010p.lower_after_raise
    x.source.g x.source.B (covLapseWedge x) k
    x.symmetric x.source.hRight

theorem source_current_uses_same_metric_shift (x : LocalPacket) :
    MetricShift010p.combinedShiftSmeared
      x.source.g x.source.B x.curvature
      (covLapseWedge x) x.divPi x.electric =
    MetricShift010p.lowerGravityCurrent
      (covLapseWedge x) x.divPi +
    MetricShift010p.emShiftSmeared
      x.source.B x.curvature (covLapseWedge x) x.electric := by
  exact MetricShift010p.same_metric_shift_sources
    x.source.g x.source.B x.curvature
    (covLapseWedge x) x.divPi x.electric
    x.symmetric x.source.hRight

theorem local_normal_bracket_is_current (x : LocalPacket) :
    ADMGradient010p.addressPB x.source =
      ADMGradient010p.addressCurrent x.source :=
  ADMGradient010p.address_local_pb_matches_current x.source

theorem packet_three_offices (x : LocalPacket) :
    (ADMGradient010p.addressPB x.source =
      ADMGradient010p.addressCurrent x.source) ∧
    (∀ k : Axis, MetricShift010p.loweredRaised
      x.source.g x.source.B (covLapseWedge x) k =
      covLapseWedge x k) ∧
    (MetricShift010p.combinedShiftSmeared
      x.source.g x.source.B x.curvature
      (covLapseWedge x) x.divPi x.electric =
    MetricShift010p.lowerGravityCurrent
      (covLapseWedge x) x.divPi +
    MetricShift010p.emShiftSmeared
      x.source.B x.curvature (covLapseWedge x) x.electric) := by
  exact ⟨local_normal_bracket_is_current x,
    shift_lowers_exactly x,
    source_current_uses_same_metric_shift x⟩

theorem finite_normal_bracket_is_current
    (xs : List ADMGradient010p.Address) :
    (xs.map ADMGradient010p.addressPB).sum =
    (xs.map ADMGradient010p.addressCurrent).sum :=
  ADMGradient010p.finite_address_sum_current xs

theorem fixed_metric_maxwell_gauge_variation_zero
    (e : Axis → Int)
    (electricWeights : Axis → Axis → Int)
    (magneticWeights : Axis → Axis → Axis → Axis → Int)
    (dA ddAlpha : GaugeEnergy010o.Matrix)
    (hcomm : ∀ i j, ddAlpha i j = ddAlpha j i) :
    GaugeEnergy010o.energy e electricWeights magneticWeights
      (GaugeEnergy010o.gaugeJet dA ddAlpha 1) -
    GaugeEnergy010o.energy e electricWeights magneticWeights dA = 0 :=
  GaugeEnergy010o.Maxwell_first_gauge_variation_zero
    e electricWeights magneticWeights dA ddAlpha hcomm

-- The following does not construct a smooth completion: it records
-- the original conditional theorem's exact interface unchanged.
theorem conditional_six_brackets_preserved
    {FG FE V F : Type} {comm : V → V → V}
    (C : FunctionalClosure010o.SmoothCompletion FG FE V F comm) :
    (∀ a b : F, FunctionalClosure010o.bracketGG C a b = 0) ∧
    (∀ a N : F, FunctionalClosure010o.bracketGH C a N = 0) ∧
    (∀ v : V, ∀ a : F,
      FunctionalClosure010o.bracketDG C v a =
        FunctionalClosure010o.Gc C
          (SmoothTransport010o.lieScalar C.smooth (C.descriptor v) a)) ∧
    (∀ u v : V, FunctionalClosure010o.bracketDD C u v =
      FunctionalClosure010o.D C (comm u v)) ∧
    (∀ v : V, ∀ N : F,
      FunctionalClosure010o.bracketDH C v N =
        FunctionalClosure010o.H C
          (SmoothTransport010o.lieScalar C.smooth (C.descriptor v) N)) ∧
    (∀ N M, FunctionalClosure010o.bracketHH C N M =
      FunctionalClosure010o.D C (C.metricShift N M) -
      CotangentLift010o.G C.canon.electromagnetic
        (C.gaugeCorrection N M) C.E) :=
  FunctionalClosure010o.six_secondary_brackets C

#print axioms shift_lowers_exactly
#print axioms source_current_uses_same_metric_shift
#print axioms local_normal_bracket_is_current
#print axioms packet_three_offices
#print axioms finite_normal_bracket_is_current
#print axioms fixed_metric_maxwell_gauge_variation_zero
#print axioms conditional_six_brackets_preserved

end FieldAttachment010s
