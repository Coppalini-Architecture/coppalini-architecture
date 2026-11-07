#include <concepts>
#include <type_traits>

// Condition & Constraint CAN Translator — C++20 compile-time receipt.
// A `can` result is local to this declared carrier and namespace.

namespace cct {

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
constexpr Mat2 L_phi_raw = add(Q, scale(2, I));

consteval bool root_exact() {
    return mul(Q, Q) == add(Q, I) &&
           mul(Omega, Omega) == scale(-1, I) &&
           mul(G, G) == scale(5, I) &&
           mul(mul(transpose(Q), G), Q) == scale(-1, G) &&
           mul(S_raw, S_raw) == scale(5, I) &&
           add(mul(transpose(S_raw), G), mul(G, S_raw)) == Mat2{0, 0, 0, 0} &&
           mul(L_phi_raw, L_phi_raw) == scale(5, mul(Q, Q));
}
static_assert(root_exact());

enum class Gate { can, fold };
enum class FoldReason { untyped, condition, constraint };

template <typename Candidate>
struct Can { using candidate = Candidate; static constexpr Gate gate = Gate::can; };
template <typename Candidate, FoldReason Reason>
struct Fold {
    using candidate = Candidate;
    static constexpr Gate gate = Gate::fold;
    static constexpr FoldReason reason = Reason;
};

template <long long A>
struct Scalar { static constexpr Mat2 matrix{A, 0, 0, A}; };
struct GoldenLift { static constexpr Mat2 matrix = L_phi_raw; };
struct PhaseISqrt7 { static constexpr Mat2 matrix = i; };
struct UntypedSignal {};

template <typename Candidate>
struct Traits;  // no primary definition: the absence is untyped.

template <long long A>
struct Traits<Scalar<A>> {
    static constexpr bool typed = true;
    static constexpr bool exact_root = root_exact();
    static constexpr bool nonzero = A != 0;
    static constexpr bool central =
        mul(Scalar<A>::matrix, Q) == mul(Q, Scalar<A>::matrix) &&
        mul(Scalar<A>::matrix, Omega) == mul(Omega, Scalar<A>::matrix) &&
        mul(Scalar<A>::matrix, G) == mul(G, Scalar<A>::matrix) &&
        mul(Scalar<A>::matrix, S_raw) == mul(S_raw, Scalar<A>::matrix) &&
        mul(Scalar<A>::matrix, i) == mul(i, Scalar<A>::matrix);
    static constexpr bool mirror_fixed = mul(mul(G, Scalar<A>::matrix), G) == scale(5, Scalar<A>::matrix);
    static constexpr bool conformal = mul(transpose(Scalar<A>::matrix), mul(G, Scalar<A>::matrix)) == scale(A * A, G);
    static constexpr bool lift = false;
    static constexpr bool phase = false;
};

template <>
struct Traits<GoldenLift> {
    static constexpr bool typed = true;
    static constexpr bool exact_root = root_exact();
    static constexpr bool nonzero = true;
    static constexpr bool central = false;
    static constexpr bool mirror_fixed = false;
    static constexpr bool conformal = false;
    static constexpr bool lift = mul(GoldenLift::matrix, GoldenLift::matrix) == scale(5, mul(Q, Q));
    static constexpr bool phase = false;
};

template <>
struct Traits<PhaseISqrt7> {
    static constexpr bool typed = true;
    static constexpr bool exact_root = root_exact();
    static constexpr bool nonzero = true;
    static constexpr bool central = false;
    static constexpr bool mirror_fixed = false;
    static constexpr bool conformal = false;
    static constexpr bool lift = false;
    static constexpr bool phase = scale(7, mul(i, i)) == scale(-7, I) && mul(mul(G, i), G) == scale(-5, i);
};

template <typename Candidate>
concept TypedCandidate = requires {
    { Traits<Candidate>::typed } -> std::convertible_to<bool>;
    { Traits<Candidate>::exact_root } -> std::convertible_to<bool>;
} && Traits<Candidate>::typed;

struct ExactRootCondition {
    template <TypedCandidate Candidate>
    static consteval bool holds() { return Traits<Candidate>::exact_root; }
};
struct ScalarSymmetryConstraint {
    template <TypedCandidate Candidate>
    static consteval bool holds() {
        return Traits<Candidate>::nonzero && Traits<Candidate>::central &&
               Traits<Candidate>::mirror_fixed && Traits<Candidate>::conformal;
    }
};
struct GoldenLiftConstraint {
    template <TypedCandidate Candidate>
    static consteval bool holds() { return Traits<Candidate>::lift; }
};
struct PhaseClosureConstraint {
    template <TypedCandidate Candidate>
    static consteval bool holds() { return Traits<Candidate>::phase; }
};

template <typename Condition, typename Constraint, typename Candidate>
consteval bool is_admitted() {
    if constexpr (!TypedCandidate<Candidate>) return false;
    else return Condition::template holds<Candidate>() && Constraint::template holds<Candidate>();
}

template <typename Condition, typename Constraint, typename Candidate>
consteval FoldReason admission_reason() {
    if constexpr (!TypedCandidate<Candidate>) return FoldReason::untyped;
    else if constexpr (!Condition::template holds<Candidate>()) return FoldReason::condition;
    else return FoldReason::constraint;
}

template <typename Condition, typename Constraint, typename Candidate>
using translate_t = std::conditional_t<
    is_admitted<Condition, Constraint, Candidate>(),
    Can<Candidate>,
    Fold<Candidate, admission_reason<Condition, Constraint, Candidate>()>>;

using ScalarCan = translate_t<ExactRootCondition, ScalarSymmetryConstraint, Scalar<2>>;
using ZeroScalarFold = translate_t<ExactRootCondition, ScalarSymmetryConstraint, Scalar<0>>;
using LiftCan = translate_t<ExactRootCondition, GoldenLiftConstraint, GoldenLift>;
using PhaseCan = translate_t<ExactRootCondition, PhaseClosureConstraint, PhaseISqrt7>;
using PhaseAsScalarFold = translate_t<ExactRootCondition, ScalarSymmetryConstraint, PhaseISqrt7>;
using UntypedFold = translate_t<ExactRootCondition, ScalarSymmetryConstraint, UntypedSignal>;

static_assert(std::same_as<ScalarCan, Can<Scalar<2>>>);
static_assert(std::same_as<ZeroScalarFold, Fold<Scalar<0>, FoldReason::constraint>>);
static_assert(std::same_as<LiftCan, Can<GoldenLift>>);
static_assert(std::same_as<PhaseCan, Can<PhaseISqrt7>>);
static_assert(std::same_as<PhaseAsScalarFold, Fold<PhaseISqrt7, FoldReason::constraint>>);
static_assert(std::same_as<UntypedFold, Fold<UntypedSignal, FoldReason::untyped>>);

}  // namespace cct

int main() {}
