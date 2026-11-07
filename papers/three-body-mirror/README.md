# The 3 Body Mirror

**Anthony Vito Coppa · 7 November 2026 · reviewed manuscript for author release**

*Exact Return, Fibonacci Conjugacy, and the Nonlinear Boundary.*

Read [the corrected PDF](The_3_Body_Mirror.pdf). The [LaTeX source](The_3_Body_Mirror.tex) and [Markdown transcription](The_3_Body_Mirror.md) carry the corrected Euler reflection axis and repaired references.

## Exact scope

The physical Euler orbit is the collision-free planar equal-mass Newtonian collinear relative equilibrium. The barycentric reconstruction requires the three known masses and the three simultaneous relative position vectors in one common oriented frame. The orthogonal involution is a reversing symmetry of the full nonlinear equations. A specified hyperbolic variational sector intertwines with the Fibonacci transport `Q²` at the *chosen* sample interval `2 log(phi)/nu`. The local analytic strong stable/unstable branches carry the compatible mirror-linearization cross.

The first resonant Hamiltonian coefficient is

```text
a = -(82891803 + 215881566 sqrt(51)) / 585841760
  = -2.773094488229637...
c1(sigma*) = -3.053118630452643...
```

This nonzero coefficient obstructs the specified *formal and smooth* linearization on an open neighborhood. It leaves topological conjugacy outside this obstruction. The astronomical and biological extensions remain open, and the sampling interval is chosen to realize the conjugacy rather than independently selected by a physical clock.

## Critical correction

The fixed +1 axis of `H = [-2,1;1,2]/sqrt(5)` is `e_H = (1,phi³)/sqrt(10+4sqrt(5))`; the Fibonacci eigenvectors `(phi,1)` and `(-1,phi)` are exchanged by `H`. This is corrected in both source editions and in the PDF. The remaining paper statements use `H` abstractly and survive the edit.

## Verification and provenance

Run `python verify_euler_birkhoff_c1.py` and `python audit_c1.py` (Python, SymPy and NumPy). Their actual successful outputs are stored separately in `verification-symbolic.txt` and `verification-independent.txt`.

The first verifier was prepared with ChatGPT (OpenAI) assistance. The second was prepared separately with Claude (Anthropic) assistance and independently constructs Taylor tensors and a generic Lie transform. Both start from the same reduced Hamiltonian; the second also checks that reduction against unreduced N-body dynamics. This describes their precise computational independence without claiming independent discovery of the starting Hamiltonian.

**Status:** revised paper for author review and Zenodo deposit. No DOI assigned in this source packet.
