# Suture Field v0.1

`05_suture_field.pdf` is the fifth physical field card.

It types one rank-four $E$-valued coframe $\Pi$ inside the eight-address
carrier and derives from it:

\[
g=\Pi^*\widehat\eta,
\qquad
\mathcal F_{\rm sol}=\Pi^*\widehat C.
\]

The accompanying verifier checks the exact eight-dimensional Fourier
realization of the $\mathbb Z_7$ address action, its metric, phase, and mirror
relations, and the presence of the required field equations in the source.

Run:

```bash
cd source
python3 verify_suture_field_v0_1.py
pdflatex -interaction=nonstopmode -halt-on-error -output-directory=../pdf 05_suture_field.tex
```

The electromagnetic realization is explicitly conditioned by Maxwell closure
and a declared calibration $\chi$; the gravitational coupling is the standard
Einstein equation with electromagnetic stress--energy.
