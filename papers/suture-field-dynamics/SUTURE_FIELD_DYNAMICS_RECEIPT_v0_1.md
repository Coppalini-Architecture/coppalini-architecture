# Suture Field Dynamics — Receipt v0.1

**Jurisdiction:** the constrained action in `05a_suture_field_dynamics.tex`.

## Closed relation

Let

\[
\mathscr S(\Pi)=\bigl(h(\Pi),f(\Pi)\bigr):
\operatorname{Hom}(\mathbb R^4,\mathbb R^8)_{\operatorname{rank}4}
\longrightarrow
\operatorname{Sym}^2(\mathbb R^4)^*\oplus\Lambda^2(\mathbb R^4)^*.
\]

On the branch where \(\operatorname{rank}D\mathscr S_\Pi=16\), the
multiplier sector has sixteen normal coordinates and sixteen vertical
coordinates.  Its local Dirac reduction is Einstein--Maxwell theory:

\[
S_{\rm red}=\int\sqrt{-g}\left[
\frac{c^3}{16\pi G_N}(R-2\Lambda)-\frac1{4\mu_0}F_{\mu\nu}F^{\mu\nu}
\right]d^4x.
\]

The regular direct-action count is

\[
\frac12\bigl(124-2(10+16)-64\bigr)=4.
\]

The four physical modes are two gravitational and two electromagnetic
transverse polarizations.

## Exact repairs carried into this edition

- \(B^{\mu\nu}\) and \(\lambda^{\mu\nu}\) remain canonical multiplier
  sectors until Dirac reduction.  Their momenta cannot be dropped from the
  direct phase space.
- The raw coframe cross-bracket coefficient
  \[
  \Delta=2\sqrt{-g}\left(\lambda\otimes\widehat\eta+
  \frac\chi2B\otimes\widehat C\right)
  \]
  vanishes at \(\lambda=B=0\).  The coframe constraints therefore do not
  form a globally invertible \(64\times64\) second-class block.
- In regular coordinates \(\Pi\leftrightarrow(q^I,\xi^a)\), the actual
  second-class block is the Darboux matrix of
  \((P_q,q-X;P_m,m)\), with rank \(64\).  The sixteen \(P_{\xi a}\)
  constraints are first class.

## Computed receipts

`verify_suture_field_dynamics_v0_1.py` uses exact rational row reduction and
certifies:

\[
\operatorname{rank}D\mathscr S_{\Pi_\star}=16,
\qquad \operatorname{signature}h(\Pi_\star)=(3,1),
\qquad \dim\mathfrak k=10.
\]

It also verifies the Lorentzian suture vacuum
\(h(\Pi_{\rm vac})=\operatorname{diag}(-2,1,1,1)\),
\(f(\Pi_{\rm vac})=0\), and hence \(\operatorname{rank}\Delta=0\) at
the multiplier vacuum.

## Boundary

The \(\mathbb Z_7\) carrier is an algebraic fiber symmetry of this action.
A local connection, a holonomy measurement, or an experimental prediction
requires an added dynamical coupling, a calibration, and an observable.
