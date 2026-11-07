# Higgs-sector and hydrogen-kernel provenance

## Electroweak Higgs carrier

The v0.5.2 carrier uses the conventional electroweak Higgs-sector normalization:

\[
\Phi\in\mathbb C^2,\quad Y=1,\quad
D_\mu=\partial_\mu-i\frac g2\tau^aW^a_\mu-i\frac{g'}2B_\mu,
\]

\[
V(\Phi)=\lambda\left(\Phi^\dagger\Phi-\frac{v^2}{2}\right)^2,
\qquad
\Phi_0=\frac1{\sqrt2}\begin{pmatrix}0\\v\end{pmatrix}.
\]

At that vacuum, the covariant-derivative quadratic form gives the classical tree-level spectrum

\[
m_W=\frac{gv}{2},\qquad
m_Z=\frac{v}{2}\sqrt{g^2+g'^2},\qquad
m_\gamma=0,
\qquad
\frac{m_W}{m_Z}=\cos\theta_W,
\quad \tan\theta_W=\frac{g'}{g}.
\]

The implementation is a finite \(2+1\)D lattice reader: its link variables carry a fixed declared \(SU(2)_L\times U(1)_Y\) background while the doublet evolves through the gauge-covariant lattice Laplacian. This supplies an inspectable finite realization of the Higgs field representation, potential, local gauge action, radial mode, and tree-level mass algebra.

## Present status

Hydrogen remains an OPEN visual study in v0.5.2. The displayed orbital slice is not promoted to an admitted dynamic carrier.

## Recovered radial basis

The retained source certificate specifies

\[
R_{nl}(x)=N_{nl}x^l e^{-x/n}L_{n-l-1}^{2l+1}(2x/n),\qquad
N_{nl}=\frac{2^{l+1}}{n^{l+2}}\sqrt{\frac{(n-l-1)!}{(n+l)!}},
\]

with \(x=r/a_H\) and radial measure \(x^2dx\). Its reported range is
\(1\leq n\leq6\), \(0\leq l<n\), \(-l\leq m\leq l\).

The supplied independent v0.3 audit re-evaluated this formula and found radial-normalization residuals at \(4.4\times10^{-16}\) across that range. That validates the written basis formula. It does not supply the original executable orbital carrier, its dynamics, or an end-to-end v0.5.1 receipt.

## Admission condition

Hydrogen can enter the admitted carrier group when an inspectable implementation couples this basis to a declared update law and a test suite that checks more than display normalization.
