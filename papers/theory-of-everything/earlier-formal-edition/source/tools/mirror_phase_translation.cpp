#include <type_traits>

// Exact compile-time receipt for the declared 2–3–2 translation packet.
// Compatible with C++17; C++20 additionally checks the closure concept.

struct Mat2 {
    long long a, b, c, d;
    constexpr bool operator==(const Mat2& other) const {
        return a == other.a && b == other.b && c == other.c && d == other.d;
    }
};

constexpr Mat2 add(Mat2 x, Mat2 y) { return {x.a + y.a, x.b + y.b, x.c + y.c, x.d + y.d}; }
constexpr Mat2 scale(long long k, Mat2 x) { return {k * x.a, k * x.b, k * x.c, k * x.d}; }
constexpr Mat2 mul(Mat2 x, Mat2 y) {
    return {
        x.a * y.a + x.b * y.c, x.a * y.b + x.b * y.d,
        x.c * y.a + x.d * y.c, x.c * y.b + x.d * y.d,
    };
}
constexpr Mat2 transpose(Mat2 x) { return {x.a, x.c, x.b, x.d}; }

constexpr Mat2 I{1, 0, 0, 1};
constexpr Mat2 Q{1, 1, 1, 0};
constexpr Mat2 Omega{0, 1, -1, 0};
constexpr Mat2 i = scale(-1, Omega);
constexpr Mat2 G = add(mul(Q, Omega), scale(-1, mul(Omega, Q)));
constexpr Mat2 S_raw = add(scale(2, Q), scale(-1, I));

template <long long A>
constexpr Mat2 scalar_carrier() { return {A, 0, 0, A}; }

// Integer / cleared-denominator exact identities.
static_assert(mul(Q, Q) == add(Q, I));
static_assert(mul(Omega, Omega) == scale(-1, I));
static_assert(mul(i, i) == scale(-1, I));
static_assert(mul(G, G) == scale(5, I));
static_assert(mul(mul(transpose(Q), G), Q) == scale(-1, G));
static_assert(mul(S_raw, S_raw) == scale(5, I));
static_assert(add(mul(transpose(S_raw), G), mul(G, S_raw)) == Mat2{0, 0, 0, 0});
static_assert(mul(mul(G, i), G) == scale(-5, i));
static_assert(add(mul(Q, i), scale(-1, mul(i, Q))) == scale(-1, G));

// H = G/sqrt(5).  G*D*G = 5D is H*D*H = D after clearing denominators.
constexpr Mat2 D2 = scalar_carrier<2>();
static_assert(mul(D2, Q) == mul(Q, D2));
static_assert(mul(D2, Omega) == mul(Omega, D2));
static_assert(mul(D2, G) == mul(G, D2));
static_assert(mul(mul(G, D2), G) == scale(5, D2));
static_assert(mul(transpose(D2), mul(G, D2)) == scale(4, G));

// Q(sqrt(5), i*sqrt(7)) with basis {1, r, j, rj}; r²=5, j²=-7.
struct Q5 {
    long long a, b;
    constexpr bool operator==(const Q5& other) const { return a == other.a && b == other.b; }
};
constexpr Q5 q5_add(Q5 x, Q5 y) { return {x.a + y.a, x.b + y.b}; }
constexpr Q5 q5_scale(long long k, Q5 x) { return {k * x.a, k * x.b}; }
constexpr Q5 q5_mul(Q5 x, Q5 y) { return {x.a * y.a + 5 * x.b * y.b, x.a * y.b + x.b * y.a}; }

constexpr Q5 two_phi{1, 1};
constexpr Q5 two_psi{1, -1};
static_assert(q5_mul(two_phi, two_phi) == q5_add(q5_scale(2, two_phi), Q5{4, 0}));
static_assert(q5_add(two_phi, q5_scale(-1, two_psi)) == Q5{0, 2});

struct Q5i7 {
    long long a, b, c, d;
    constexpr bool operator==(const Q5i7& other) const {
        return a == other.a && b == other.b && c == other.c && d == other.d;
    }
};
constexpr Q5i7 k57_mul(Q5i7 x, Q5i7 y) {
    const Q5 A{x.a, x.b}; const Q5 B{x.c, x.d};
    const Q5 C{y.a, y.b}; const Q5 D{y.c, y.d};
    const Q5 real = q5_add(q5_mul(A, C), q5_scale(-7, q5_mul(B, D)));
    const Q5 imag = q5_add(q5_mul(A, D), q5_mul(B, C));
    return {real.a, real.b, imag.a, imag.b};
}
constexpr Q5i7 golden_mirror(Q5i7 x) { return {x.a, -x.b, x.c, -x.d}; }
constexpr Q5i7 phase_reverse(Q5i7 x) { return {x.a, x.b, -x.c, -x.d}; }

constexpr Q5i7 r{0, 1, 0, 0};
constexpr Q5i7 j{0, 0, 1, 0};
constexpr Q5i7 rj{0, 0, 0, 1};
static_assert(k57_mul(r, r) == Q5i7{5, 0, 0, 0});
static_assert(k57_mul(j, j) == Q5i7{-7, 0, 0, 0});
static_assert(k57_mul(r, j) == rj && k57_mul(j, r) == rj);
static_assert(golden_mirror(golden_mirror(rj)) == rj);
static_assert(phase_reverse(phase_reverse(rj)) == rj);

// Declared state closure; this is a program-local type relation, not a claim
// about persons, networks, or the world outside this source file.
struct VerifyState {};
struct OrthogonalTrust {};

template <typename ActiveSignal>
struct NetworkTransformation {
    using terminal_phase = VerifyState;
    static constexpr bool tracking_loop_active = true;
};
template <>
struct NetworkTransformation<VerifyState> {
    using terminal_phase = OrthogonalTrust;
    static constexpr bool tracking_loop_active = false;
};
template <>
struct NetworkTransformation<OrthogonalTrust> {
    using terminal_phase = OrthogonalTrust;
    static constexpr bool tracking_loop_active = false;
};

template <typename Phase>
constexpr bool orthogonal_closure_v =
    std::is_same<typename NetworkTransformation<Phase>::terminal_phase, OrthogonalTrust>::value &&
    !NetworkTransformation<Phase>::tracking_loop_active;

static_assert(orthogonal_closure_v<VerifyState>);
static_assert(orthogonal_closure_v<OrthogonalTrust>);

#if __cplusplus >= 202002L
template <typename Phase>
concept OrthogonalClosure = orthogonal_closure_v<Phase>;
static_assert(OrthogonalClosure<VerifyState>);
static_assert(OrthogonalClosure<OrthogonalTrust>);
#endif

int main() {}
