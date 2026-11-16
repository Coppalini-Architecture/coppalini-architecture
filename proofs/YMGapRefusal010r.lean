import YMDiracGapAudit010q

/-!
Minimum Mechanics 010r — spectral refusal and dependency closure.

This addendum imports the pinned 010q non-Abelian Gauss commutators and
rational spectral counterexample. It proves the two-sided independence
of a positive rational gap from those commutators using two exact
excitation-denominator profiles, with the same fixed Gauss algebra.

The analytic realization is C|Ω> ⊕ l²(N) ⊕ C³, with Gauss generators
zero on the first two summands and spin-1 on C³. The two diagonal,
nonnegative, bounded self-adjoint gauge-invariant Hamiltonians give
energies 1 and 1/(n+1) respectively on the physical excited singlets,
with a common strictly positive energy (e.g. 2) on the charged triplet.
Their unique zero-energy physical vector is |Ω>.

Lean certifies the exact rational-gap and finite matrix algebra parts.
This module does not assert an operator-theoretic Lean construction,
any physical sector separation, a 4D Yang–Mills field realization,
or a continuum reconstruction.
-/

set_option autoImplicit false

namespace YMGapRefusal010r

open YMDiracGapAudit010q

abbrev DenominatorProfile := Nat → Nat

-- Each excited energy is 1/d(n); d(n) > 0 in our two models.
-- A positive rational p/q <= 1/d(n) is equivalently p*d(n) <= q.
def GapAtRational (d : DenominatorProfile) (p q : Nat) : Prop :=
  0 < p ∧ 0 < q ∧ ∀ n : Nat, p * d n ≤ q

def HasPositiveRationalGap (d : DenominatorProfile) : Prop :=
  ∃ p q : Nat, GapAtRational d p q

def constantExcitations : DenominatorProfile := fun _ => 1

def accumulatingExcitations : DenominatorProfile := fun n => n + 1

theorem both_denominator_profiles_positive (n : Nat) :
    0 < constantExcitations n ∧ 0 < accumulatingExcitations n := by
  simp [constantExcitations, accumulatingExcitations]

theorem constant_excitation_gap :
    HasPositiveRationalGap constantExcitations := by
  refine ⟨1, 1, ?_, ?_, ?_⟩
  · decide
  · decide
  · intro n
    simp [constantExcitations]

theorem accumulating_excitation_no_gap :
    ¬HasPositiveRationalGap accumulatingExcitations := by
  rintro ⟨p, q, hp, hq, hb⟩
  exact no_positive_uniform_gap_from_gauss_algebra p q hp hq hb

theorem same_gauss_commutators_admit_both_profiles :
    bracket Jx Jy = Jz ∧
    bracket Jy Jz = Jx ∧
    bracket Jz Jx = Jy ∧
    HasPositiveRationalGap constantExcitations ∧
    ¬HasPositiveRationalGap accumulatingExcitations := by
  exact ⟨nonabelian_xy, nonabelian_yz, nonabelian_zx,
         constant_excitation_gap, accumulating_excitation_no_gap⟩

-- Exhaust both attempted directions: noncommutative Gauss algebra
-- neither forces a gap nor forces a gapless physical spectrum.
def FixedNonabelianGauss : Prop :=
  bracket Jx Jy = Jz ∧
  bracket Jy Jz = Jx ∧
  bracket Jz Jx = Jy

theorem fixed_nonabelian_gauss : FixedNonabelianGauss :=
  ⟨nonabelian_xy, nonabelian_yz, nonabelian_zx⟩

theorem commutators_do_not_force_positive_gap :
    ¬(FixedNonabelianGauss → HasPositiveRationalGap accumulatingExcitations) := by
  intro h
  exact accumulating_excitation_no_gap (h fixed_nonabelian_gauss)

theorem commutators_do_not_force_gaplessness :
    ¬(FixedNonabelianGauss → ¬HasPositiveRationalGap constantExcitations) := by
  intro h
  exact (h fixed_nonabelian_gauss) constant_excitation_gap

theorem vacuum_and_excited_addresses_remain_distinct :
    spectralDenominator PhysicalAddress.vacuum = 0 ∧
    (∀ n : Nat, 0 < spectralDenominator (.excited n)) := by
  exact ⟨vacuum_has_separate_address, every_excited_address_positive⟩

#print axioms both_denominator_profiles_positive
#print axioms constant_excitation_gap
#print axioms accumulating_excitation_no_gap
#print axioms same_gauss_commutators_admit_both_profiles
#print axioms fixed_nonabelian_gauss
#print axioms commutators_do_not_force_positive_gap
#print axioms commutators_do_not_force_gaplessness
#print axioms vacuum_and_excited_addresses_remain_distinct

end YMGapRefusal010r
