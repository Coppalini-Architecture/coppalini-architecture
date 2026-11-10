# Suture Field Receipt v0.1

## Closed carrier

The rank-eight address carrier is

\[
\mathcal V_8=\mathbb R[\{\infty\}\sqcup\mathbb Z_7]
=\operatorname{span}(e_\infty,u_0)
\oplus\bigoplus_{j=1}^{3}\operatorname{span}(c_j,s_j).
\]

The vertex cycle has the real Fourier realization

\[
\widehat\varrho(\tau^r)=I_2\oplus R_{2\pi r/7}
\oplus R_{4\pi r/7}\oplus R_{6\pi r/7}.
\]

With the established root matrices, the internal forms are

\[
\widehat\eta=G\oplus I_2\oplus I_2\oplus I_2,
\qquad
\widehat C=C\oplus C\oplus C\oplus C,
\qquad
\widehat H=H\oplus D\oplus D\oplus D,
\quad D=\operatorname{diag}(1,-1).
\]

The executable receipt verifies exactly

\[
\widehat\varrho(\tau)^7=I_8,
\qquad
\widehat\varrho^{\mathsf T}\widehat\eta\widehat\varrho
=\widehat\eta,
\qquad
\widehat\varrho^{\mathsf T}\widehat C\widehat\varrho
=\widehat C,
\]

\[
\widehat H^{\mathsf T}\widehat\eta\widehat H=\widehat\eta,
\qquad
\widehat H^{\mathsf T}\widehat C\widehat H=-\widehat C,
\qquad
\widehat H\widehat\varrho(\tau^r)\widehat H
=\widehat\varrho(\tau^{-r}).
\]

## Field closure

The suture field is a rank-four internal coframe

\[
\Pi\in\Omega^1(M,E),
\qquad
\Pi:TM\xrightarrow{\cong}L\subset E,
\]

with the two exact contractions

\[
g=\Pi^*\widehat\eta,
\qquad
\mathcal F_{\rm sol}=\Pi^*\widehat C
=\frac12\widehat C_{AB}\Pi^A\wedge\Pi^B.
\]

The first carries Lorentzian interval and curvature. The second carries
oriented surface flux. The cyclic action preserves both; the mirror preserves
$g$ and reverses $\mathcal F_{\rm sol}$.

## Physical field conditions

The electromagnetic realization is typed by a constant calibration $\chi$ and
the Maxwell equations

\[
F_{\rm em}=\chi\mathcal F_{\rm sol},
\qquad
dF_{\rm em}=0,
\qquad
d\star_gF_{\rm em}=\mu_0\star_gJ.
\]

Its stress--energy enters the Einstein equation

\[
\operatorname{Ein}_{\mu\nu}+\Lambda g_{\mu\nu}
=\frac{8\pi G_N}{c^4}
\left(T^{\rm mat}_{\mu\nu}+T^{\rm em}_{\mu\nu}\right).
\]

The physical receipt for any realization is the calibrated occurrence tuple

\[
(\Theta,g,\mathcal F_{\rm sol},F_{\rm em},J,W^{(7)}_\gamma,O,
\kappa,\boldsymbol\varepsilon).
\]

## Boundary

The finite carrier and its invariance relations are certified by
`source/verify_suture_field_v0_1.py` using exact cyclotomic arithmetic.
The field equations specify the physical realization condition. A material
coupling, calibration value, and measured observable remain part of each
individual realization's occurrence record.
