# 010t — Classical Smooth Field Completion on \(\mathbb T^3\)

**Date:** 20 November 2026
**Status:** source-documented classical mathematics
**Scope:** the real \(C^\infty\) Einstein–Maxwell secondary-constraint algebra on a compact, oriented, boundaryless three-torus with a trivialized \(U(1)\) bundle.
**Lean boundary:** the pinned `FunctionalClosure010o.SmoothCompletion` interface remains an `Int`-valued conditional interface; this record does not supply a real \(C^\infty\) Lean constructor.

## Result

**Closed at the stated classical field level.** On
\(\Sigma_{\rm EM}=\mathbb T^3\), with \(\partial\Sigma_{\rm EM}=\varnothing\), the real
\(C^\infty\) Einstein–Maxwell phase space supplies the geometric and analytic
counterparts of all seven `SmoothCompletion` premise roles and yields the six
secondary bracket relations.

The result is a source-documented classical construction. It does not change
the type of `FunctionalClosure010o.six_secondary_brackets`: that Lean theorem
remains universally quantified over a supplied `SmoothCompletion C`.

## Carrier

Let

\[
\mathcal P_\infty=
\operatorname{Met}_+^\infty(\Sigma_{\rm EM})
\times\Gamma^\infty(S^2T\Sigma_{\rm EM}\otimes\operatorname{Dens})
\times\Omega^1_{\rm dR}(\Sigma_{\rm EM})
\times\Gamma^\infty(T\Sigma_{\rm EM}\otimes\operatorname{Dens}),
\qquad \Sigma_{\rm EM}:=\mathbb T^3.
\]

A field state is \((\gamma_{ij},\pi^{ij};A_i,E^i)\). Its real weak canonical
symplectic form is

\[
\Omega_{\mathcal P}(X,Y)=\int_\Sigma
\bigl[X\gamma_{ij}Y\pi^{ij}-Y\gamma_{ij}X\pi^{ij}
+XA_iYE^i-YA_iXE^i\bigr].
\]

For sufficiently regular functionals with smooth variational derivatives,

\[
\{F,K\}=\int_\Sigma
\left(F_\gamma^{ij}K_{\pi,ij}-F_{\pi,ij}K_\gamma^{ij}
+F_A^iK_{E,i}-F_{E,i}K_A^i\right).
\]

The Hamiltonian density is the stated Einstein–Maxwell ADM density

\[
\mathcal H_\perp=
{a\over\sqrt\gamma}(\pi^{ij}\pi_{ij}-{1\over2}\pi^2)
-b\sqrt\gamma(R[\gamma]-2\Lambda)
 +{\mu_0\over2\sqrt\gamma}\gamma_{ij}E^iE^j
 +{\sqrt\gamma\over4\mu_0}F_{ij}F^{ij},
\qquad ab=1,
\]

with \(F=dA\) and \(H[N]=\int_\Sigma N\mathcal H_\perp\).

## Seven premise roles in the smooth carrier

| Lean premise name | Classical \(C^\infty\) counterpart on \(\mathbb T^3\) | Condition / source receipt |
| --- | --- | --- |
| `hDensityCovariance` | The tensor- and density-valued variables carry the genuine Lie-derivative cotangent lift used by spatial transport. | Tensor-density Lie calculus and compact Stokes transfer. |
| `gaugeHamiltonianVariationZero` | The Hamiltonian depends on the potential through \(F=dA\); \(\delta_\alpha A=d\alpha\) gives \(\delta_\alpha F=d^2\alpha=0\). | Gauge invariance of the stated Hamiltonian. |
| `gaussSmearingCovariance` | Spatial transport carries a gauge smearing by \(\mathcal L_vd\alpha=d(\mathcal L_v\alpha)\). | \(\{D[v],G_{\rm EM}[\alpha]\}=G_{\rm EM}[\mathcal L_v\alpha]\). |
| `boundaryH` | Hamiltonian integrations by parts have no boundary flux. | \(\partial\mathbb T^3=\varnothing\). |
| `sourceNormalGradient` | The displayed real functional derivatives of \(H[N]\) give the canonical normal-normal bracket integrand. | Palatini variation, smooth metric calculus, and the canonical bracket above. |
| `sourceMomentumAddress` | With \(w^i=\gamma^{ij}(N\partial_jM-M\partial_jN)\), integration by parts returns \(D[w]-G_{\rm EM}[w^iA_i]\). | The explicit normal-bracket computation below. |
| `boundaryNormal` | The curvature-current boundary contribution vanishes in the normal bracket. | \(\partial\mathbb T^3=\varnothing\) and Stokes. |

For the normal relation, the relevant real derivatives include

\[
\frac{\delta H[N]}{\delta\pi^{ij}}
=\frac{aN}{\sqrt\gamma}(2\pi_{ij}-\pi\gamma_{ij}),\qquad
\frac{\delta H[N]}{\delta\gamma_{ij}}
=NU^{ij}+b\sqrt\gamma(\gamma^{ij}\nabla^2N-\nabla^i\nabla^jN),
\]

\[
\frac{\delta H[N]}{\delta E^i}
=\frac{\mu_0N}{\sqrt\gamma}\gamma_{ij}E^j,\qquad
\frac{\delta H[N]}{\delta A_i}
=-\partial_j\!\left(\frac{N\sqrt\gamma}{\mu_0}F^{ji}\right).
\]

Their antisymmetrized canonical bracket gives

\[
\boxed{
\{H[N],H[M]\}=\int_\Sigma w^i\mathcal C_i
=D[w]-G_{\rm EM}[w^iA_i].
}
\]

Together with the Lie-derivative and gauge identities, the six relations are

\[
\begin{gathered}
\{G_{\rm EM}[\alpha],G_{\rm EM}[\beta]\}=0,\qquad
\{G_{\rm EM}[\alpha],H[N]\}=0,\\
\{D[v],G_{\rm EM}[\alpha]\}=G_{\rm EM}[\mathcal L_v\alpha],\qquad
\{D[u],D[v]\}=D[[u,v]],\\
\{D[v],H[N]\}=H[\mathcal L_vN],\qquad
\{H[N],H[M]\}=D[w]-G[w^iA_i].
\end{gathered}
\]

## Reader sequence

The public reader layer carries the ordered handle sequence

\[
\Phi\;\;\Psi\;\;i\;\;g\;\;e\;\;\theta\;\;\Lambda.
\]

It organizes the reader layer alongside the field receipt. The seven formal
premises above keep their own exact names, carriers, hypotheses, and sources.

## Boundaries retained

1. **Open.** A concrete real \(C^\infty\) constructor for the original
   `Int`-valued `SmoothCompletion` interface; separately, P14, the
   finite-root-to-variational/Hamiltonian adapter. The Lean theorem remains
   conditional over a supplied `SmoothCompletion C`.
2. **Evidence type.** The construction above is ordinary classical smooth
   mathematics under its stated hypotheses. It is not recast as a newly
   compiled Lean theorem or as an empirical calibration.

## Source authority

- `010t_Prime_Accounted_Smooth_Field_Completion.md`, 16 November 2026,
  sections 3–4 and 6: real weak-symplectic \(C^\infty\) carrier, functional
  derivatives, normal bracket, six-bracket algebra, and explicit Lean
  boundary.
- `010p_mathematical_derivation.md`: detailed first-variation and
  gauge-improved momentum-address calculations.
- Pinned conditional theorem:
  [`FunctionalClosure010o.lean`](https://github.com/Coppalini-Architecture/coppalini-architecture/blob/b9e939d514a63fb021592f79a316f70cbc70ed8a/proofs/FunctionalClosure010o.lean).
