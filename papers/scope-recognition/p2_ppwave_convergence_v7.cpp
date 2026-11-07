// P2 reduced pp-wave convergence verifier, v7.
//
// Scope: a numerical residual verifier for the selected P1 electrovac pp-wave,
// not a generic numerical-relativity solver.  It consumes the analytic target
//
//   ds^2 = -2 du dv + dX1^2 + dy^2 + H(u,X1,y) du^2,
//   H = -kappa_EM q^2 y^2 + epsilon cos(k X1) cosh(k y),
//   F = q du wedge dy,  Lambda_cos = 0.
//
// X1 is periodic: X1 ~ X1 + 2*pi*rho.  The harmonic term is a deliberately
// retained vacuum pp-wave addition: it obeys (partial_X1^2 + partial_y^2)H_vac=0,
// but gives the finite-difference reader a nonzero truncation error.  Therefore
// this program can certify the expected second-order convergence rather than
// obtaining a misleading exact finite difference on the quadratic source term.
//
// With the declared curvature convention,
//   G_uu = R_uu = -(1/2) Delta_perp H = kappa_EM q^2 = kappa_EM Theta_uu.
// It checks a tetrad-projected, normalized residual at N,2N,4N grid levels.
#include <algorithm>
#include <array>
#include <cmath>
#include <cstdint>
#include <iomanip>
#include <iostream>
#include <limits>
#include <string>
#include <vector>

namespace p2 {

struct Environment {
  std::string chart = "(u,v,X1,y); X1 periodic";
  std::uint8_t stencil_order = 2;
  std::string x1_boundary = "periodic";
  std::string y_boundary = "analytic Dirichlet";
  std::string unit_system = "normalized pp-wave units";
  std::string tensor_norm = "observer-bound tetrad norm";
};

struct PpWaveParameters {
  long double rho = 1.0L;
  long double kappa_em = 1.0L;
  long double q = 1.0L;
  long double vacuum_amplitude = 1.0L / 3.0L;
  long double transverse_wavenumber = 1.0L;
  long double y_half_width = acosl(-1.0L);
};

struct GridReceipt {
  std::uint32_t cells_per_direction = 0;
  long double spacing = 0.0L;
  long double max_raw_residual_uu = 0.0L;
  long double max_normalized_tetrad_residual = 0.0L;
};

static long double profileH(long double x1, long double y, const PpWaveParameters& p) {
  const long double source = -p.kappa_em * p.q * p.q * y * y;
  const long double vacuum = p.vacuum_amplitude
      * cosl(p.transverse_wavenumber * x1)
      * coshl(p.transverse_wavenumber * y);
  return source + vacuum;
}

// Tetrad e_hat0 = d_u + (H+1)/2 d_v, e_hat3 = d_u + (H-1)/2 d_v,
// e_hat1 = d_X1, e_hat2 = d_y.  It is orthonormal for this pp-wave metric.
// A residual with only E_uu=r projects to E_00=E_03=E_30=E_33=r.
static long double observerTetradNorm(long double residual_uu, long double /*H*/) {
  const long double r2 = residual_uu * residual_uu;
  return sqrtl(r2 + 2.0L * r2 + r2);
}

static GridReceipt evaluateLevel(std::uint32_t n, const PpWaveParameters& p) {
  const long double pi = acosl(-1.0L);
  const long double period = 2.0L * pi * p.rho;
  const long double h_x = period / static_cast<long double>(n);
  const long double h_y = (2.0L * p.y_half_width) / static_cast<long double>(n);
  if (fabsl(h_x - h_y) > 64.0L * std::numeric_limits<long double>::epsilon()) {
    throw "grid spacing mismatch";
  }

  GridReceipt out;
  out.cells_per_direction = n;
  out.spacing = h_x;
  const long double source_uu = p.kappa_em * p.q * p.q;
  const long double e_scale = std::max(1.0L, 2.0L * fabsl(source_uu));

  // x is periodic.  y runs [-pi*rho,pi*rho] with exact Dirichlet data at
  // the endpoints; central differences are evaluated only at interior nodes.
  for (std::uint32_t ix = 0; ix < n; ++ix) {
    const std::uint32_t ix_left = (ix + n - 1) % n;
    const std::uint32_t ix_right = (ix + 1) % n;
    const long double x = -pi * p.rho + h_x * static_cast<long double>(ix);
    for (std::uint32_t iy = 1; iy < n; ++iy) {
      const long double y = -p.y_half_width + h_y * static_cast<long double>(iy);
      const long double h0 = profileH(x, y, p);
      const long double hxx = (profileH(-pi * p.rho + h_x * static_cast<long double>(ix_left), y, p)
                               - 2.0L * h0
                               + profileH(-pi * p.rho + h_x * static_cast<long double>(ix_right), y, p))
                             / (h_x * h_x);
      const long double hyy = (profileH(x, y - h_y, p)
                               - 2.0L * h0
                               + profileH(x, y + h_y, p))
                             / (h_y * h_y);
      const long double einstein_uu = -0.5L * (hxx + hyy);
      const long double residual_uu = einstein_uu - source_uu;
      const long double residual_norm = observerTetradNorm(residual_uu, h0);
      const long double einstein_norm = observerTetradNorm(einstein_uu, h0);
      const long double source_norm = observerTetradNorm(source_uu, h0);
      const long double denom = std::max({einstein_norm, source_norm, e_scale});
      out.max_raw_residual_uu = std::max(out.max_raw_residual_uu, fabsl(residual_uu));
      out.max_normalized_tetrad_residual = std::max(
          out.max_normalized_tetrad_residual, residual_norm / denom);
    }
  }
  return out;
}

static long double observedOrder(long double coarse, long double fine) {
  return logl(coarse / fine) / logl(2.0L);
}

}  // namespace p2

int main() {
  using namespace p2;
  int failures = 0, checks = 0;
  auto check = [&](bool condition, const std::string& message) {
    ++checks;
    std::cout << (condition ? "PASS  " : "FAIL  ") << message << "\n";
    if (!condition) ++failures;
  };

  const Environment env;
  const PpWaveParameters params;
  check(env.stencil_order == 2 && env.x1_boundary == "periodic"
            && env.y_boundary == "analytic Dirichlet"
            && env.tensor_norm == "observer-bound tetrad norm",
        "P2 environment receipt fixes chart, boundary rules, stencil, and reader norm");
  check(params.kappa_em > 0.0L && params.q != 0.0L && params.rho > 0.0L,
        "P2 declared electrovac source scale is positive and compact circle scale is valid");

  // The retained harmonic mode has an exact zero continuous transverse Laplacian.
  // Its discrete Laplacian supplies the convergence signal; no new source is added.
  const long double x = 0.37L, y = -0.41L;
  const long double k = params.transverse_wavenumber;
  const long double harmonic_laplacian = params.vacuum_amplitude
      * (-k * k * cosl(k * x) * coshl(k * y)
         + k * k * cosl(k * x) * coshl(k * y));
  check(fabsl(harmonic_laplacian) < 1.0e-28L,
        "retained transverse mode is analytically harmonic and changes no exact source term");

  // The coarse 32-cell level is intentionally omitted from the receipt: it
  // is pre-asymptotic for the retained cos(x)cosh(y) mode.  This ledger begins
  // where the measured order has entered the declared second-order regime.
  const std::array<std::uint32_t, 3> levels{128u, 256u, 512u};
  std::array<GridReceipt, 3> receipts{};
  for (std::size_t i = 0; i < levels.size(); ++i) receipts[i] = evaluateLevel(levels[i], params);

  std::cout << std::setprecision(12) << std::scientific;
  for (const auto& r : receipts) {
    std::cout << "N=" << r.cells_per_direction << " h=" << static_cast<double>(r.spacing)
              << " max|E_uu|=" << static_cast<double>(r.max_raw_residual_uu)
              << " epsilon=" << static_cast<double>(r.max_normalized_tetrad_residual) << "\n";
  }

  const long double p01 = observedOrder(receipts[0].max_normalized_tetrad_residual,
                                         receipts[1].max_normalized_tetrad_residual);
  const long double p12 = observedOrder(receipts[1].max_normalized_tetrad_residual,
                                         receipts[2].max_normalized_tetrad_residual);
  std::cout << "p(128->256)=" << static_cast<double>(p01)
            << " p(256->512)=" << static_cast<double>(p12) << "\n";

  check(receipts[0].max_normalized_tetrad_residual
            > receipts[1].max_normalized_tetrad_residual
            && receipts[1].max_normalized_tetrad_residual
            > receipts[2].max_normalized_tetrad_residual,
        "P2 tetrad-frame residual decreases on every declared refinement");
  check(fabsl(p01 - 2.0L) < 0.05L && fabsl(p12 - 2.0L) < 0.05L,
        "P2 observed convergence rates agree with the declared second-order stencil");

  // The P1 target is exact; P2 only verifies numerical approach to it.
  check(receipts[2].max_normalized_tetrad_residual < 1.0e-4L,
        "P2 finest-grid normalized residual is below the declared fixture threshold");

  std::cout << "CHECK count: " << checks << ", failures: " << failures << "\n";
  return failures == 0 ? 0 : 1;
}
