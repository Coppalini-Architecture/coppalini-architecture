import Init.Data.Rat.Basic
import proofs.CovariantStokes010k

/-!
# Minimum Mechanics 010l — two Stokes transfers with both boundary receipts

Reference: PalatiniBoundary010i.BoundarySlice, inherited unchanged.
One application of its Stokes and Leibniz laws already proves first IBP.

This file proves the SECOND IBP from those declared laws:
  I(f D_i D_j h)
     = I((D_j D_i f)h)
       + B_i(f D_j h) - B_j((D_i f)h).
Both boundary terms are retained. The order of scalar derivatives is
preserved; swapping them requires its own commuting-partials hypothesis.

It also proves the nine-address 3D divergence-divergence / Laplacian-trace
curvature variation identity with an exact boundary ledger:
  I(N (D_iD_j h_ij - D_iD_i h_jj))
    = I(h_ij D_jD_iN - h_jj D_iD_iN)
      + boundary_first - boundary_second.

This is a verified consequence of an explicitly supplied BoundarySlice
interface, and a concrete Jet3 instance. It is NOT a global curved
smooth-manifold Stokes theorem, nor an unconditional Einstein-Hilbert
functional-derivative claim. No new axioms or sorry.
-/
set_option autoImplicit false

namespace DoubleStokes010l

open PalatiniBoundary010i
abbrev Axis := Fin 3

theorem second_integration_by_parts
    {F : Type} (s : BoundarySlice F)
    (i j : Axis) (f h : F) :
    s.integral (s.mulField f (s.deriv i (s.deriv j h))) =
      s.integral (s.mulField (s.deriv j (s.deriv i f)) h) +
        s.boundary i (s.mulField f (s.deriv j h)) -
        s.boundary j (s.mulField (s.deriv i f) h) := by
  have h1 := weighted_boundary_integration_by_parts s i f (s.deriv j h)
  have h2 := weighted_boundary_integration_by_parts s j (s.deriv i f) h
  omega

theorem second_ibp_commuting_scalar
    {F : Type} (s : BoundarySlice F)
    (i j : Axis) (f h : F)
    (hcomm : s.deriv j (s.deriv i f) = s.deriv i (s.deriv j f)) :
    s.integral (s.mulField f (s.deriv i (s.deriv j h))) =
      s.integral (s.mulField (s.deriv i (s.deriv j f)) h) +
        s.boundary i (s.mulField f (s.deriv j h)) -
        s.boundary j (s.mulField (s.deriv i f) h) := by
  rw [second_integration_by_parts s i j f h, hcomm]

def sum3 (f : Axis → Int) : Int := f 0 + f 1 + f 2

abbrev Tensor (F : Type) := Axis → Axis → F

def divDivVariation {F : Type} (s : BoundarySlice F)
    (N : F) (h : Tensor F) : Int :=
  sum3 (fun i => sum3 (fun j =>
    s.integral (s.mulField N (s.deriv i (s.deriv j (h i j))))))

def lapTraceVariation {F : Type} (s : BoundarySlice F)
    (N : F) (h : Tensor F) : Int :=
  sum3 (fun i => sum3 (fun j =>
    s.integral (s.mulField N (s.deriv i (s.deriv i (h j j))))))

def curvatureVariation {F : Type} (s : BoundarySlice F)
    (N : F) (h : Tensor F) : Int :=
  divDivVariation s N h - lapTraceVariation s N h

def divDivAdjoint {F : Type} (s : BoundarySlice F)
    (N : F) (h : Tensor F) : Int :=
  sum3 (fun i => sum3 (fun j =>
    s.integral (s.mulField (s.deriv j (s.deriv i N)) (h i j))))

def lapTraceAdjoint {F : Type} (s : BoundarySlice F)
    (N : F) (h : Tensor F) : Int :=
  sum3 (fun i => sum3 (fun j =>
    s.integral (s.mulField (s.deriv i (s.deriv i N)) (h j j))))

def curvatureAdjoint {F : Type} (s : BoundarySlice F)
    (N : F) (h : Tensor F) : Int :=
  divDivAdjoint s N h - lapTraceAdjoint s N h

def firstBoundary {F : Type} (s : BoundarySlice F)
    (N : F) (h : Tensor F) : Int :=
  sum3 (fun i => sum3 (fun j =>
    s.boundary i (s.mulField N (s.deriv j (h i j))))) -
  sum3 (fun i => sum3 (fun j =>
    s.boundary i (s.mulField N (s.deriv i (h j j)))))

def secondBoundary {F : Type} (s : BoundarySlice F)
    (N : F) (h : Tensor F) : Int :=
  sum3 (fun i => sum3 (fun j =>
    s.boundary j (s.mulField (s.deriv i N) (h i j)))) -
  sum3 (fun i => sum3 (fun j =>
    s.boundary i (s.mulField (s.deriv i N) (h j j))))

theorem three_dimensional_curvature_boundary_ledger
    {F : Type} (s : BoundarySlice F)
    (N : F) (h : Tensor F) :
    curvatureVariation s N h =
      curvatureAdjoint s N h +
      firstBoundary s N h - secondBoundary s N h := by
  have h00 := second_integration_by_parts s 0 0 N (h 0 0)
  have h01 := second_integration_by_parts s 0 1 N (h 0 1)
  have h02 := second_integration_by_parts s 0 2 N (h 0 2)
  have h10 := second_integration_by_parts s 1 0 N (h 1 0)
  have h11 := second_integration_by_parts s 1 1 N (h 1 1)
  have h12 := second_integration_by_parts s 1 2 N (h 1 2)
  have h20 := second_integration_by_parts s 2 0 N (h 2 0)
  have h21 := second_integration_by_parts s 2 1 N (h 2 1)
  have h22 := second_integration_by_parts s 2 2 N (h 2 2)
  have hl01 := second_integration_by_parts s 0 0 N (h 1 1)
  have hl02 := second_integration_by_parts s 0 0 N (h 2 2)
  have hl10 := second_integration_by_parts s 1 1 N (h 0 0)
  have hl12 := second_integration_by_parts s 1 1 N (h 2 2)
  have hl20 := second_integration_by_parts s 2 2 N (h 0 0)
  have hl21 := second_integration_by_parts s 2 2 N (h 1 1)
  simp only [curvatureVariation, divDivVariation, lapTraceVariation,
    curvatureAdjoint, divDivAdjoint, lapTraceAdjoint,
    firstBoundary, secondBoundary, sum3]
  omega

theorem zero_boundary_curvature_adjoint
    {F : Type} (s : BoundarySlice F)
    (N : F) (h : Tensor F)
    (hFirst : firstBoundary s N h = 0)
    (hSecond : secondBoundary s N h = 0) :
    curvatureVariation s N h = curvatureAdjoint s N h := by
  rw [three_dimensional_curvature_boundary_ledger,
      hFirst, hSecond]
  omega

-- A nonzero boundary survives even in the certified concrete Jet3.
open JetStokes010e

theorem boundary_witness_second_derivative :
    (PalatiniBoundary010i.jetBoundarySlice.integral
      (JetStokes010e.mul one (JetStokes010e.D 0 (JetStokes010e.D 0 epsX)))) = 1 ∧
    (PalatiniBoundary010i.jetBoundarySlice.boundary 0
      (JetStokes010e.mul one (JetStokes010e.D 0 epsX))) = 1 := by
  decide

#print axioms second_integration_by_parts
#print axioms second_ibp_commuting_scalar
#print axioms three_dimensional_curvature_boundary_ledger
#print axioms zero_boundary_curvature_adjoint
#print axioms boundary_witness_second_derivative

end DoubleStokes010l
