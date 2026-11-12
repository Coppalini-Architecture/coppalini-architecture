#!/usr/bin/env python3
"""Independent exact quartic normal-form check for the equal-mass Euler three-body orbit.

Units: masses m=1, outer bodies at x=+-1, Newton constant G_N=4/5,
orbital rate omega=1. Reduce center of mass and fix angular momentum ell=2.

Claim: The quartic hyperbolic Birkhoff coefficient in the analytically reduced
Hamiltonian is nonzero, obstructing an analytic conjugacy to the linear Q^2 map on an open saddle
neighborhood. It does not affect branchwise stable/unstable conjugacies.

Requires sympy. Run: python verify_euler_birkhoff_c1.py
"""
import sympy as s

t = s.symbols('t', real=True)
r, x, y, p, u, v = s.symbols('r x y p u v', real=True)
xi, eta = s.symbols('xi eta', real=True)
R0 = s.sqrt(2)
R = R0 + t*r
X, Y, P, U, V = [t*j for j in (x,y,p,u,v)]

def inv_distance(sign):
    # |(R + sign*sqrt(3)*X, sqrt(3)*Y)|^-1 to degree four.
    d2 = (R + sign*s.sqrt(3)*X)**2 + 3*Y**2
    a1 = s.expand((d2 - 2)/2).coeff(t, 1)
    a2 = s.expand((d2 - 2)/2).coeff(t, 2)
    z = t*a1 + t*t*a2
    return s.expand(sum(s.binomial(-s.Rational(1,2), k) *
                        s.series(z**k,t,0,5).removeO() for k in range(5))) / R0

q = t*r/R0
inv_R = sum((-q)**k for k in range(5))/R0
inv_R2 = sum((-1)**k*(k+1)*q**k for k in range(5))/2

# Exact Jacobi/rotation-reduced 3-body Hamiltonian at ell=2:
# H = (p_r^2+p_x^2+p_y^2)/2 + (ell-x*p_y+y*p_x)^2/(2R^2)
#       - (4/5)[1/(sqrt(2)R) + sqrt(2)/|R e1 -sqrt(3)w|
#                                     +sqrt(2)/|R e1 +sqrt(3)w|].
potential = s.Rational(4,5) * (inv_R/s.sqrt(2)
             +s.sqrt(2)*(inv_distance(1)+inv_distance(-1)))
H_taylor = s.expand(s.Rational(1,2)*(P**2+U**2+V**2)
           +s.Rational(1,2)*(2-X*V+Y*U)**2 * inv_R2 - potential)
H = [s.expand(H_taylor.coeff(t,k)) for k in range(5)]

assert H[1] == 0, 'Equilibrium linear term'
H2_expected = (p**2+r**2+u**2+v**2)/2 +u*y-v*x-s.Rational(12,5)*x**2+s.Rational(6,5)*y**2
H3_expected = s.sqrt(2)*r*(-5*r**2-10*u*y+10*v*x+36*x**2-18*y**2)/10
H4_shape = (u*y-v*x)**2/4-s.Rational(18,5)*x**4+s.Rational(54,5)*x**2*y**2-s.Rational(27,20)*y**4
for name,actual,expected in [ ('quadratic',H[2],H2_expected),
                              ('cubic',H[3],H3_expected),
                              ('shape quartic',H[4].subs(r,0),H4_shape) ]:
    assert s.simplify(actual-expected)==0,name

# Canonical variables (r,x,y;p,u,v). J = [[0,I],[-I,0]].
z = s.Matrix([r,x,y,p,u,v]);J=s.zeros(6);J[:3,3:]=s.eye(3);J[3:,:3]=-s.eye(3)
A = J*s.hessian(H[2],z)
lam=s.symbols('lambda')
nu2 = (1+2*s.sqrt(51))/5
kap2 = (2*s.sqrt(51)-1)/5
assert s.simplify(A.charpoly(lam).as_expr()-(lam**2+1)*(lam**2-nu2)*(lam**2+kap2))==0

nu=s.sqrt(nu2)
b=(s.sqrt(51)-14)/(5*nu)
# Hyperbolic mode in shape canonical coordinates (x,y,u,v).
eplus=s.Matrix([1,b,nu-b,nu*b+1]); eminus=s.Matrix([1,-b,-nu+b,nu*b+1])
shape_A=A.extract([1,2,4,5],[1,2,4,5])
assert all(s.simplify(v)==0 for v in shape_A*eplus-nu*eplus)
assert all(s.simplify(v)==0 for v in shape_A*eminus+nu*eminus)
J4=s.Matrix([[0,0,1,0],[0,0,0,1],[-1,0,0,0],[0,-1,0,0]])
W=s.simplify((eplus.T*J4*eminus)[0]); assert W!=0
symplectic_pair=s.simplify((eplus.T*J4*(eminus/W))[0]);assert symplectic_pair==1
sub=s.Matrix([eplus[i]*xi+eminus[i]*eta/W for i in range(4)])
repl=dict(zip([x,y,u,v],sub))

# H2|hyperbolic = nu*xi*eta in these canonical mode coordinates.
assert s.simplify(H[2].subs({r:0,p:0}).subs(repl)-nu*xi*eta)==0

# H3 = radial cubic + radial * F2(shape); the radial mode has frequency 1.
F2 = s.sqrt(2)*(-u*y+v*x+s.Rational(18,5)*x**2-s.Rational(9,5)*y**2)
assert s.simplify(H[3]+s.sqrt(2)*r**3/2 - r*F2)==0
f=s.Poly(s.expand(F2.subs(repl)),xi,eta)
a=f.coeff_monomial(xi**2)
beta=f.coeff_monomial(xi*eta)
c=f.coeff_monomial(eta**2)
d=s.Poly(s.expand(H4_shape.subs(repl)),xi,eta).coeff_monomial(xi**2*eta**2)

# Exact Lie-transform correction from eliminating H3 = r F2 + radial cubic.
# Each term r*c_ab*xi^a*eta^b has a generator
#    chi_ab = c_ab*(p - nu*(a-b)*r)/(1+nu^2*(a-b)^2)*xi^a*eta^b,
# satisfying {chi_ab,H2}=-r*c_ab*xi^a*eta^b.
# In H4 + (1/2){chi,H3}, only the radial bracket contributes to xi^2 eta^2,
# giving -(a*c)/(1+4*nu^2) - beta^2/2.
correction = -a*c/(1+4*nu2) - beta**2/2
h_coefficient=s.simplify(d+correction)
expected=s.Rational(-215881566,585841760)*s.sqrt(51)-s.Rational(82891803,585841760)
assert s.simplify(h_coefficient-expected)==0
assert h_coefficient!=0

phi=(1+s.sqrt(5))/2
sigma=2*s.log(phi)/nu
c1=s.simplify(2*sigma*h_coefficient)
print('CHECKS PASSED: equilibrium, H2/H3/H4, spectrum, eigenvectors, symplectic normalization, Hamiltonian normal form')
print('nu =',s.N(nu,16))
print('sampling sigma* =',s.N(sigma,16))
print('symplectic eigenvector pairing =',s.N(W,16))
print('H4 direct xi^2 eta^2 =',s.N(d,16))
print('cubic elimination correction =',s.N(correction,16))
print('quartic Hamiltonian saddle coefficient a =',h_coefficient)
print('a (numeric) =',s.N(h_coefficient,16))
print('time-map normal form c1 = 2*sigma* *a =',s.N(c1,16))
print('RESULT: c1 != 0; the hyperbolic saddle normal form has a nonzero analytic linearization obstruction.')
print('SCOPE: local fixed-angular-momentum equal-mass Euler model; branchwise cross remains conjugate.')
