import Init.Grind

set_option autoImplicit false
namespace SutureRankGeneral
variable {K : Type} [Lean.Grind.Field K]

theorem zero_mul (u t : K) (h : u*t = 0) (hu : u ≠ 0) : t = 0 := by
  grind

theorem uv_total (u v t : K) (h1 : u*t = 0) (h2 : v*t = 0)
    (h : u ≠ 0 ∨ v ≠ 0) : t = 0 := by
  grind

theorem two (t : K) (h2 : (2 : K) ≠ 0) (hm : (2 : K)*t = 0) : t = 0 := by
  grind

end SutureRankGeneral
#print axioms SutureRankGeneral.zero_mul
