# Clear Onyx source comparison and implementation record

## Reference fixed

1. `lotuslift/clear_onyx`, default branch verified at
   `5d7630957027d2d424164351f9b59de9cdc9efd4`; latest commit is 5 August 2026.
   Its published tree has Hydrogen, Helium, Water and Atomic Music. Higgs is a
   separately recovered Library artifact.
2. Archived `higgsmirrorscopev0.1.html`, Library identity
   `libfile_53f96378bb648191a015957ff57a174b`, uploaded 30 August 2026. It contains
   Water v0.2 and the pure Higgs Mirror v0.1 module.
3. `Higgs_Reader_Connection.md`, 5 September 2026, Library identity
   `libfile_ccec96b5dbdc8191a695a184ed09c058`. The complete calculation record is
   included under `references/`. Its equations own the raw-frame/seam connection,
   seven matchings, radial incidence and central-reader distinctions used here.
4. `Source_Proof_v66.md`, from the retained Structure of Survival Lean package.
   The file is included under `references/`. The v59 canonical Library reference
   was also read for its reference/reader/carrier/record definitions. The v66
   root and axial-return equations govern the new root instrument.
5. `Clear_onyx Big Box.txt`, Library identity
   `libfile_9d9149dd74048191929bcd7ca3262721`, supplies the single-file program
   orientation and separate state/transition/audit/projection offices.

These are owning references. A previous summary or visual resemblance does not
replace a source equation. The user requested a code-level successor; this
package changes no published site or remote repository.

## Findings and admitted updates

### 1. Water's old render path builds full seam packets at every pixel

The v0.1 density renderer calls `field.sample` once per pixel. Each call evaluates
eight spatial orbitals, all 28 complex pair correlations, recurrence tags and
reconstruction diagnostics. The density view only needs the summed amplitudes.

The successor evaluates the unchanged native orbital functions once for its
chosen grid, retaining eight spatial basis values per pixel. Each frame applies
the current phase factors and computes the selected scalar field. Full seam and
audit packets are read at the explicit probe. Numerical centered-difference
current is available as its own mode.

Regression: cached fields are compared against native `sample` at every point
of a 20x20 grid for four scalar reads, three beats and two fractional phases.
The maximum absolute density discrepancy was 2.013e-16 in this run. Arbitrary
pixel display colors remain declared peak-normalized projections.

Benchmark: `receipts/kernel-tests.json` records five passes at the same 48x48
grid, with cache preparation measured separately. The old path computes a full
packet; the cached path computes density. This comparison quantifies avoided
work and does not measure end-to-end button latency, browser painting or phone
performance. It does not claim a universal speedup factor.

### 2. The archived v0.2 shortest-path interpolation drops full phase turns

At exact integer beats, v0.2's 108-register matches the older field. Between
beats, it interpolates the shortest path between residue endpoints. For n=2,
the endpoints are both residue zero, so it renders no turn. The native relative
energy phase has ratio 1 and completes a full turn in that same interval.

Concrete counterexample: beat 0, fraction 1/2. The native n=2 phase is -1;
the archived endpoint interpolation yields +1. The new adapter uses the exact
integer residue plus the full native fractional phase, including its whole
turns. Tests compare all eight channels at six beats, four fractions and three
probe locations. Maximum amplitude discrepancy was 1.345e-14.

For huge integer beat addresses, BigInt reduces the integer phase register
before conversion to a floating angle. The source's selected relative-energy
ratios and physical preparation are retained.

### 3. The archived plane-coherence routine averages amplitudes first

The v0.2 `integrateField` comment describes Gamma_ab = mean(u_a conjugate(u_b)).
Its body instead averages u first and then decomposes that mean. These are
different readers. The successor's separate `integrateCoherences` averages the
products and returns a Hermitian 8x8 numerical quadrature read. A two-point
regression gives a nonzero difference of about 1.8963e-5 in Gamma_00.

The visible seam and Higgs instruments use a point probe, explicitly labeled.
The plane quadrature helper is supplied and tested; a plane-average UI is not
silently substituted for a coherent point doublet.

### 4. Preserve correlation conventions explicitly

The native Water packet stores u_a conjugate(u_b). The later canonical row
two-form uses Delta_ab = Im(conjugate(u_a)u_b) = m_a r_b - m_b r_a.
Their imaginary parts have opposite signs. The adapter tests and retains that
sign relation rather than renaming one as the other.

Seven perfect matchings partition the 28 addressed pairs. Each band is the sum
of four squared seams. At a point, Lagrange's identity gives

    (m dot r)^2 + sum B_a = ||m||^2 ||r||^2.

Also sum rho_ab^2 = 7 sum |u_j|^2. Signed individual seams remain in the table
and receipt source; band sums retain a coarser read.

For a real row operation A, Delta(AX)=det(A) Delta(X). Q and H reverse oriented
seams; Lax preserves them. Positive norm and the split form G retain their
distinct laws. The frame selector acts on the probe rows and leaves the native
field generator intact. No normalization factor is discarded.

### 5. Doublet zero and numerical cutoff are separate

The archived code marks radius below 1e-12 unavailable; some source paths report
zero radius. The new polar adapter uses a scaled `Math.hypot` norm. An actual
zero doublet has no unique orientation. A finite tiny positive doublet keeps its
orientation; underflow of its squared radius is reported separately.

The finite test exercises all 625 doublets with real components in {-2,-1,0,1,2},
checks U-dagger-U and det U independently, checks central radius/projective
return and SU(2) sign, and includes 1e-13 and 1e-300 probes. The largest tested
unitarity residual is 2.221e-16.

The scalar doublet, SU(2) factor, projective direction and central occurrence
are separate fields. Common phase leaves the projective reader invariant;
two i steps change U to -U; four return U when the source is fixed. The declared
radial potential adds no Standard Model mass or coupling prediction.

### 6. Descriptor return, lift and occurrence are separate

The Atomic Music descriptor remains N in {0,...,6}, with F(N)=N+4 mod 7 and
R(N)=6-N. The declared integer cover uses F(k)=k+1, R(k)=5-k and N=4k mod 7.
Seven F steps return N while k advances by seven. Negative registers use floor
division. This is an exact lifted descriptor action, separately declared from
musical pitch or physical atomic transitions.

Return to origin is a recorded action; it retains the earlier receipt prefix.
The full finite permutation closure is recomputed and has order 14. Each
instrument ledger is frozen, including nested data. A globally ordered journal
retains commands, view updates and scheduled Water steps across instruments.

### 7. The v66 root is executable without floating identity tests

The root module stores (p+q sqrt(5))/d with reduced BigInt integer coefficients.
It evaluates Q^2=Q+I, G^2=5I, H^2=S^2=I, the generator condition, axial G-fit,
mirror inverse and Lax^2=Q^2 exactly. Lax=(2I+Q)/sqrt(5).

For seed z0=(1,2), four quarter steps return the phase and carry the state by
Lax. Its signed quadratic read is 10. The occurrence and axial lift continue.
The UI plots numerically; the displayed state arithmetic remains exact.
The included formal proof is a reference. This task did not perform a fresh
Lean elaboration or extend the theorem package.

## Verification and retained scope

Eight test groups pass; `receipts/kernel-tests.json` records their individual
assertions, numerical discrepancies, runtime and benchmark. Browser checks
exercise all four readers, the 108-beat return, origin-history retention,
central return, exact root lift, zero/tiny inputs, frame covariance and JSON
receipt inspection. Four readers at both 390px and 640px frame widths have no
horizontal page overflow.

The managed browser reported failure for both an automatic Blob download and the final explicit Download JSON link.
The final UI supplies a readable JSON inspector and an explicit Download JSON
link. The inspector's source hashes, exact states, ledger counts and ordered
cross-instrument journal were verified. Completion of the local file download
in that preview remains OPEN; this is distinct from the verified JSON payload.

Physical realization, molecular eigenproblems, measured response time on the
user's phone, receipt import/resume, and extensions to Hydrogen/Helium remain
separately scoped work. No numerical agreement here enlarges those claims.
