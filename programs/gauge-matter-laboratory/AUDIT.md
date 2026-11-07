# v0.5.2 Audit Ledger

## Admitted v0.5 change

| Difference | Carrier / repair | Fail-capable receipt |
|---|---|---|
| Real 1D \(\phi^4\) scalar labelled Higgs-like | electroweak Higgs doublet \(\Phi\in\mathbb C^2\), \(Y=1\), with \(SU(2)_L\times U(1)_Y\) links | local gauge covariance, invariant \(\Phi^\dagger\Phi\), radial lattice frequency, and a \(4\times4\) gauge-boson mass matrix built from \(D_\mu\Phi\) and independently diagonalized |
| Ambiguous scalar naming | real 1D \(\phi^4\) domain study | retained under its real-scalar name and `OPEN`; it keeps its own state space and update law |

The Higgs carrier uses

\[
\mathcal L_H=(D_\mu\Phi)^\dagger(D^\mu\Phi)-\lambda\left(\Phi^\dagger\Phi-\frac{v^2}{2}\right)^2,
\qquad \Phi\mapsto e^{i\alpha/2}G\Phi,
\]

and a gauge link \(L_{x,\mu}\mapsto e^{i(\alpha_x-\alpha_{x+\hat\mu})/2}G_xL_{x,\mu}G^\dagger_{x+\hat\mu}\). The mass check first constructs the quadratic form of \(D_\mu\Phi\) at \(\Phi_0=(0,v/\sqrt2)^T\); only then does it diagonalize the resulting matrix and compare with \(m_W=gv/2\), \(m_Z=v\sqrt{g^2+g'^2}/2\), and \(m_\gamma=0\).

The test suite contains two failure witnesses: a corrupted gauge-mass coefficient and a non-unitary link. Both produce receipt failure.

## Admitted v0.4.2 changes

| Difference | Carrier / repair | Fail-capable receipt |
|---|---|---|
| Tautological U(1) holonomy check | U(1) closed link ring | norm, local-gauge covariance, \(\Phi\sim\Phi+2\pi\) covariance after the required \(e^{-i2\pi j/N}\) seed twist, and a nonzero half-flux response |
| Cartan-only SU(3) test | triplet packet under general non-diagonal local SU(3) transforms | norm, general covariance, plaquette trace, 2×1 Wilson-loop trace, and an evolved three-carrier \(\epsilon_{abc}\) determinant |
| Fixed-loop vortex snapshot | complex \(\phi^4\) vortex–antivortex preparation | seed winding is named as a seed fact; the time-local plaquette count verifies the pair at the declared early time, without a persistence claim |
| Cosmetic neutral-spinor current label | integrated Weyl current \(j=(\langle\sigma_x\rangle,\langle\sigma_y\rangle)\) | code calculation and a current/spin equality test on the declared seed |
| Torus centroid branch | circular first moment | a uniform field now reports `UNRESOLVED`; a packet that has a nonzero circular resultant returns its torus coordinate |
| Noether–Klein torus centroid branch | circular first moment in the retained field reader | a uniform field reports `UNRESOLVED`; resolved packet centroids retain their torus coordinate |
| Noether–Klein admitted pulse | post-pulse state baseline | baseline resets after the declared pulse; (3000)-step charge-proxy drift is held below (10^{-10}) |
| Dirac pulse added norm | local unitary two-component pulse | post-pulse norm residual |
| Oscillation after flavour pulse | measured \(P_\beta\) read | pure-state formula gated on pure-\(\alpha\), unpulsed preparation |
| Candidate-code dependency | all active carrier code under `src/carriers/` | clean self-contained build and source manifest |
| Generic compass labels | named axes per carrier | reader text inspection and browser rendering |

## Retained open work

| Scope | Present state |
|---|---|
| Full QCD confinement | Open. Confinement requires a specified ensemble calculation and statistical Wilson-loop evidence. This build supplies finite SU(3) kinematics only. |
| Hydrogen / lithium / helium | Open. Their visible studies emit no PASS. |
| Water | Open. Its v0.2 energy/centre-of-mass model, including the clock-driven z read, remains a visual study. |
| Real 1D \(\phi^4\) domain pair | Open. Pair annihilation is not represented as a persistent-domain result. |
| Long-time complex \(\phi^4\) vortex number | No persistence or conservation claim is made. The admitted receipt is explicitly seed- and time-local. |
| Legacy visual-study repairs | The older hydrogen, lithium, helium, and water defects remain held under `OPEN`; relabelling has not been counted as a repair. |

## Retired receipt

`tests/check-particle-atlas.cjs` belongs to v0.2 and contained normalization checks constructed to pass. `tests/check-v04.cjs` predates the strengthened gauge and readout receipts. Both remain explicit retired guards in the working tree and are excluded from the v0.4.2 source manifest and source package.
