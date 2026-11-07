# The Theory of Everything — Formal Edition

This package preserves the 34-page formal edition and the executable/source
receipts used to build it.

## Formal authority rule

A source carries formal authority only when it is a publisher/DOI record, an
official institutional data or standards record, or a content-addressed primary
project artifact fixed by a commit or SHA-256 receipt. Historical locations
without a matching byte certificate remain in the provenance registry only;
they do not support theorem, empirical, or completion assertions.

## Contents

- the_theory_of_everything_formal_edition.pdf — rendered formal edition.
- the_theory_of_everything_formal_edition.tex — master typesetting source.
- theory_of_everything_formal_edition_body.tex — full controlling draft,
  provenance appendices, and bibliography.
- theory_of_everything_current_closure.tex — current closure and executable
  receipt section.
- theory_of_everything_b4_public_path_manifest.psv — exact public path,
  alias, and SHA-256 record for Appendix B.4.
- theory_of_everything_executable_receipt.psv — exact executable source
  hashes, commands, results, and scope boundaries.
- tools/ and verification/ — Python, C++, and Lean sources named by the
  executable receipt.

## Build and verification

The PDF was built with two pdflatex passes. The accompanying executable
receipt records the exact Python and C++ commands that passed. The Lean source
is preserved as a formalization source; its independent elaboration receipt is
explicitly OPEN.

Rendered PDF SHA-256:

be03b2671aabc11742ef02248c5c73dfe57f539b7fbbf3317dff5ee826be2910
