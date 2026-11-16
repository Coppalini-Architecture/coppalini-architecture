import Init.Data.Rat.Basic
import proofs.FieldAttachment010s

/-!
# Minimum Mechanics 010t — prime-accounted rational symplectic floor

The source history is Contact Arithmetic: ordered prime words retain order
while ordinary multiplicative evaluation loses it. To obtain a field we
pass to signed rational values with their usual addition and multiplication,
then (ANALYTICALLY, outside this source) to real Cauchy completion.
The logarithmic completion of positive rational magnitudes alone is only
an additive topological group and does not define the field operations.

The new Lean office is a NONZERO Rat-valued canonical cotangent pairing,
with six independent symmetric-metric coordinates and three Maxwell
one-form coordinates. This repairs the *scalar type* of the former
Int-valued abstract interface at the finite-address level, while
preserving its earlier theorem strengths and existing source files.

This does not construct the C∞ real Fréchet tangent/cotangent bundles,
weak symplectic form, functional derivatives, or an instance of
FunctionalClosure010o.SmoothCompletion. It is a positive scalar-typing
witness and audit of what information a projected reader can forget.
-/

set_option autoImplicit false

namespace PrimeRationalSymplectic010t

-- Exact prime-word evaluation. The two words are different receipts.
def primeWordValue : List Nat → Nat
  | [] => 1
  | x :: xs => x * primeWordValue xs

theorem prime_word_two_three : primeWordValue [2, 3] = 6 := by decide

theorem prime_word_three_two : primeWordValue [3, 2] = 6 := by decide

theorem distinct_words_same_value :
    ([2,3] : List Nat) ≠ [3,2] ∧
    primeWordValue [2,3] = primeWordValue [3,2] := by
  constructor
  · decide
  · decide

-- Six independent symmetric-metric addresses: 00,11,22,01,02,12.
-- A canonical off-diagonal momentum coordinate is twice the physical
-- corresponding symmetric tensor-density component.
abbrev Sym6 := Fin 6 → Rat
abbrev EM3 := Fin 3 → Rat

def zeroSym : Sym6 := fun _ => 0
def zeroEM : EM3 := fun _ => 0

def unitSym0 : Sym6 := fun i => if i = 0 then 1 else 0

def unitSym3 : Sym6 := fun i => if i = 3 then 1 else 0

def offdiagMomentum (p : Sym6) : Sym6 :=
  fun i => if i.val < 3 then p i else 2 * p i

def pair6 (x y : Sym6) : Rat :=
  x 0*y 0 + x 1*y 1 + x 2*y 2 +
  x 3*y 3 + x 4*y 4 + x 5*y 5

def pair3 (x y : EM3) : Rat :=
  x 0*y 0 + x 1*y 1 + x 2*y 2

theorem pair6_symmetric (x y : Sym6) : pair6 x y = pair6 y x := by
  simp only [pair6]
  simp [mul_comm]

theorem pair3_symmetric (x y : EM3) : pair3 x y = pair3 y x := by
  simp only [pair3]
  simp [mul_comm]

-- Nonzero exact canonical source pairings over Rat.
theorem diagonal_pair_nonzero : pair6 unitSym0 unitSym0 = 1 := by decide

theorem offdiagonal_momentum_normalization :
    pair6 unitSym3 (offdiagMomentum unitSym3) = 2 := by decide

structure Gradient where
  dGamma : Sym6
  dPi : Sym6
  dA : EM3
  dE : EM3

def canonicalPB (f h : Gradient) : Rat :=
  pair6 f.dGamma h.dPi - pair6 f.dPi h.dGamma +
  pair3 f.dA h.dE - pair3 f.dE h.dA

def metricGradient0 : Gradient :=
  ⟨unitSym0, zeroSym, zeroEM, zeroEM⟩

def momentumGradient0 : Gradient :=
  ⟨zeroSym, unitSym0, zeroEM, zeroEM⟩

theorem rational_canonical_bracket_nonzero :
    canonicalPB metricGradient0 momentumGradient0 = 1 := by decide

theorem rational_canonical_bracket_not_zero :
    canonicalPB metricGradient0 momentumGradient0 ≠ 0 := by decide

-- The gauge variation acts only in the E-gradient slot.
def gaugeGradient (s : EM3) : Gradient :=
  ⟨zeroSym, zeroSym, zeroEM, s⟩

theorem abelian_gauss_bracket (s t : EM3) :
    canonicalPB (gaugeGradient s) (gaugeGradient t) = 0 := by
  simp [canonicalPB, gaugeGradient, pair6, pair3, zeroSym, zeroEM]

-- A coarse nonlinear read of a scalar (here x ↦ x²) is an example
-- of compression; it is NOT an assertion about physical color.
def projectedDifference (x : Rat) : Rat := x*x

theorem projected_read_is_not_injective :
    projectedDifference (1:Rat) = projectedDifference (-1:Rat) ∧
    (1:Rat) ≠ (-1:Rat) := by decide

#print axioms prime_word_two_three
#print axioms prime_word_three_two
#print axioms distinct_words_same_value
#print axioms pair6_symmetric
#print axioms pair3_symmetric
#print axioms diagonal_pair_nonzero
#print axioms offdiagonal_momentum_normalization
#print axioms rational_canonical_bracket_nonzero
#print axioms rational_canonical_bracket_not_zero
#print axioms abelian_gauss_bracket
#print axioms projected_read_is_not_injective

end PrimeRationalSymplectic010t
