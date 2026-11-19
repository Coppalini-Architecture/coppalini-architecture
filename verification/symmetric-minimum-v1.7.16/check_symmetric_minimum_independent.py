#!/usr/bin/env python3
"""Independent exact re-derivation of the finite identities displayed in
'Symmetric Minimum: An Inherited Closure' (v1.7.14), Part I.7-I.13, and the closure family J of v1.7.16.
sympy exact arithmetic; each family carries a negative control (a perturbed
input that must FAIL). Not the author's verifier; reproduces displayed identities only."""
import itertools, sys
import sympy as sp
from sympy import Matrix, sqrt, Rational, I, eye, zeros, simplify, symbols, cosh, sinh, exp, log, cos, sin, pi

R = []          # (name, passed, is_control)
def ok(name, cond):   R.append((name, bool(cond), False))
def ctl(name, cond):  R.append((name, not bool(cond), True))   # control passes when cond is FALSE
def Z(M): return M.applyfunc(lambda e: sp.simplify(sp.expand(e))) == zeros(*M.shape)

Phi = (1 + sqrt(5)) / 2
Q  = Matrix([[1,1],[1,0]]); J = Matrix([[0,-1],[1,0]]); Om = -J; Id = eye(2)
def comm(A,B): return A*B - B*A
G  = comm(Q,Om)
H  = G/sqrt(5)
S  = H*J
s  = symbols('s', real=True); a_ = symbols('alpha', real=True)
def L(t): return cosh(t)*Id + sinh(t)*S          # e^{tS}, S^2=I
Lax = (Q + 2*Id)/sqrt(5)

# --- A. root matrices and metric chart -----------------------------------
ok('A1 G=[Q,Om]=[[-2,1],[1,2]]', G == Matrix([[-2,1],[1,2]]))
ok('A2 G=[J,Q]', Z(G - comm(J,Q)))
ok('A3 G symmetric', G == G.T)
ok('A4 G^2=5I', G*G == 5*Id)
ok('A5 det G=-5; sqrt5=sqrt(-det G)', G.det()==-5 and sqrt(-G.det())==sqrt(5))
ok('A6 G^-1=G/5=H/sqrt5', Z(G.inv()-G/5) and Z(G.inv()-H/sqrt(5)))
ok('A7 signature (1,1): eigenvalues +-sqrt5', sorted(G.eigenvals().keys(), key=lambda e: float(e)) == [-sqrt(5), sqrt(5)])
x,y = symbols('x y', real=True); z = Matrix([x,y])
q = sp.expand((z.T*G*z)[0])
ok('A8 z^T G z = -2x^2+2xy+2y^2', q == -2*x**2+2*x*y+2*y**2)
ok('A9 factorization -2(x-Phi y)(x-(1-Phi)y)', sp.simplify(q + 2*(x-Phi*y)*(x-(1-Phi)*y))==0)
for v in (Matrix([Phi,1]), Matrix([1-Phi,1])):
    ok('A10 null vector %s'%list(v), sp.simplify((v.T*G*v)[0])==0)
ok('A11 H^2=I, H symmetric', H*H==Id and H==H.T)
ok('A12 root: Phi^2=Phi+1, Phi(1-Phi)=-1', sp.simplify(Phi**2-Phi-1)==0 and sp.simplify(Phi*(1-Phi)+1)==0)
ctl('A-ctl1 G with Om->+Om has wrong sign', comm(Q,J)==G)
ctl('A-ctl2 G/sqrt2 is a mirror (H^2=I)', (G/sqrt(2))**2==Id)
ctl('A-ctl3 G^2=4I', G*G==4*Id)

# --- B. turn, phase family, i-fold ---------------------------------------
ok('B1 J^2=-I', J*J==-Id)
ok('B2 J^T G J=-G', J.T*G*J==-G)
ok('B3 J swaps null lines: J(Phi,1)=Phi*(1-Phi,1) and J(1-Phi,1)=(1-Phi)*(Phi,1)',
   Z(J*Matrix([Phi,1]) - Phi*Matrix([1-Phi,1])) and Z(J*Matrix([1-Phi,1]) - (1-Phi)*Matrix([Phi,1])))
ok('B4 H J H = J^-1 = -J', Z(H*J*H - J.inv()) and Z(H*J*H + J))
U = lambda t: cos(t)*Id + sin(t)*J
ok('B5 U_pi/2=J, U_pi=-I, U_2pi=I', Z(U(pi/2)-J) and Z(U(pi)+Id) and Z(U(2*pi)-Id))
ok('B6 H U_alpha H = U_-alpha', Z(sp.simplify(H*U(a_)*H - U(-a_))))
ok('B7 U_alpha = exp(alpha J) (series)', Z(sp.simplify((a_*J).exp() - U(a_))))
ok('B8 g_J(u,v)=u^T Om J v = u^T v  (Om J = I)', Om*J==Id)
ok('B9 g_J positive definite', (Om*J).is_positive_definite)
ok('B10 G=[Q,Om] sign: Q^T Om Q=-Om, (Q^2)^T Om Q^2=Om', Q.T*Om*Q==-Om and (Q**2).T*Om*Q**2==Om)
ok('B11 Q^T G Q=-G, (Q^2)^T G Q^2=G', Q.T*G*Q==-G and (Q**2).T*G*Q**2==G)
ctl('B-ctl1 J^T G J=+G', J.T*G*J==G)
ctl('B-ctl2 H J H = J', H*J*H==J)
ctl('B-ctl3 Q preserves Om (det Q=-1)', Q.T*Om*Q==Om)
fib=[0,1]; [fib.append(fib[-1]+fib[-2]) for _ in range(70)]
ok('B12 Q^n=[[F(n+1),F(n)],[F(n),F(n-1)]], n=1..25', all((Q**n)==Matrix([[fib[n+1],fib[n]],[fib[n],fib[n-1]]]) for n in range(1,26)))

# --- C. carriage ---------------------------------------------------------
ok('C1 S=HJ=(2Q-I)/sqrt5', Z(S-(2*Q-Id)/sqrt(5)))
ok('C2 S^2=I', Z(S*S-Id))
ok('C3 L_s^T G L_s = G (symbolic s)', Z(sp.simplify(L(s).T*G*L(s)-G)))
ok('C4 H L_s H = L_-s (symbolic s)', Z(sp.simplify(H*L(s)*H-L(-s))))
ok('C5 L_t L_s = L_{t+s}', Z(sp.simplify(L(a_)*L(s)-L(a_+s))))
ok('C6 det L_s = 1; tr L_s = 2cosh s', sp.simplify(L(s).det()-1)==0 and sp.simplify(L(s).trace()-2*cosh(s))==0)
ok('C7 L_{log Phi} = (Q+2I)/sqrt5', Z((L(log(Phi))-Lax).applyfunc(lambda e: sp.simplify(sp.expand(e.rewrite(exp))))))
ok('C8 L_ax^2=Q^2', Z(Lax*Lax-Q**2))
ok('C9 L_ax^T G L_ax = G', Z(Lax.T*G*Lax-G))
ok('C10 H L_ax H = L_ax^-1', Z(H*Lax*H-Lax.inv()))
ok('C11 finite guard: (L_ax^n)^T L_ax^n != I, n=1..8', all(((Lax**n).T*(Lax**n)-Id)!=zeros(2,2) for n in range(1,9)))
ok('C12 L_ax symmetric', Lax==Lax.T)
ctl('C-ctl1 L built from J (not S) preserves... G? (cosh+sinh J)', Z(sp.simplify((cosh(s)*Id+sinh(s)*J).T*G*(cosh(s)*Id+sinh(s)*J)-G)))
ctl('C-ctl2 L_ax orthogonal', Lax.T*Lax==Id)

# --- D. sign character on the carriage group, all 27 words ---------------
gens = {'J':(J,-1),'H':(H,1),'L':(Lax,1)}
bad=0; n=0
for w in itertools.product('JHL', repeat=3):
    M=eye(2); chi=1
    for g in w: M=M*gens[g][0]; chi*=gens[g][1]
    n+=1
    if not Z(sp.simplify(M.T*G*M - chi*G)): bad+=1
ok('D1 gamma^T G gamma = chi(gamma) G on all 27 length-3 words (n=%d)'%n, bad==0 and n==27)
ok('D2 H^T G H = G directly (G^3/5 = G, G symmetric, G^2=5I)', Z(H.T*G*H-G) and Z(G*G*G/5-G))
# the sign-character law as multiplicativity: chi(g1 g2)=chi(g1)chi(g2)
ok('D3 chi multiplicative: (g1g2)^T G g1g2 = g2^T (g1^T G g1) g2',
   all(Z(sp.simplify((A*B).T*G*(A*B) - B.T*(A.T*G*A)*B)) for A in (J,H,Lax) for B in (J,H,Lax)))
# dihedral D4
D4=set(); frontier=[Id]
while frontier:
    M=frontier.pop()
    key=tuple(sp.nsimplify(sp.simplify(e)) for e in M)
    if key in D4: continue
    D4.add(key)
    for g in (J,H): frontier.append((M*g).applyfunc(sp.simplify))
ok('D4 <J,H> has order 8 (dihedral)', len(D4)==8)
ctl('D-ctl1 chi(J)=+1 would give wrong law on J', Z(J.T*G*J - G))
ctl('D-ctl2 <J,H> has order 4', len(D4)==4)

# --- E. action and conservation -----------------------------------------
t=symbols('t'); X=sp.Function('X')(t); Y=sp.Function('Y')(t)
zt=Matrix([X,Y]); zd=zt.diff(t)
Lag=sp.Rational(1,2)*(zt.T*Om*zd)[0]+sp.Rational(1,2)*(zt.T*H*zt)[0]
eqs=sp.calculus.euler.euler_equations(Lag,[X,Y],t)
EL=Matrix([e.lhs-e.rhs for e in eqs])
target=Om*zd+H*zt
ok('E1 Euler-Lagrange == Om z_dot + H z', Z(sp.simplify(EL-target)) or Z(sp.simplify(EL+target)))
ok('E2 Om S = -H', Z(Om*S+H))
ok('E3 (Om z_dot + H z = 0) <=> z_dot = S z', Z(sp.simplify(Om.inv()*(-H)-S)))
ok('E4 S^T H + H S = 0', Z(S.T*H+H*S))
z0=Matrix(symbols('p q', real=True)); zs=L(s)*z0
Hax=lambda w: -sp.Rational(1,2)*(w.T*H*w)[0]
ok('E5 d/ds H_ax(L_s z0) = 0', sp.simplify(sp.diff(Hax(zs),s))==0)
ok('E6 d/ds L_s = S L_s (z_dot = S z)', Z(sp.simplify(L(s).diff(s)-S*L(s))))
ctl('E-ctl1 wrong generator (J) does not conserve H_ax', sp.simplify(sp.diff(Hax((sp.cos(s)*Id+sp.sin(s)*J)*z0),s))==0)

# --- F. wheel, residual, rail, axial coordinate -------------------------
def Fesc(ph,zz): return (ph+1,zz) if ph in (0,1,2) else (0,(Lax*zz).applyfunc(sp.simplify))
zz0=Matrix([sp.Rational(2),sp.Rational(-3)]); good=True
for ph in range(4):
    st=(ph,zz0)
    for _ in range(4): st=Fesc(*st)
    good = good and st[0]==ph and Z(st[1]-Lax*zz0)
ok('F1 F_esc^4(phi,z)=(phi,L_ax z) for phi=0..3', good)
q0=(zz0.T*G*zz0)[0]
ok('F2 eps_G(J^n;z)=((-1)^n-1) z^T G z, n=0..7', all(sp.simplify(((J**n*zz0).T*G*(J**n*zz0))[0]-q0-((-1)**n-1)*q0)==0 for n in range(8)))
ok('F3 eps_G(H)=eps_G(L_ax^n)=0', sp.simplify(((H*zz0).T*G*(H*zz0))[0]-q0)==0 and all(sp.simplify(((Lax**n*zz0).T*G*(Lax**n*zz0))[0]-q0)==0 for n in range(1,9)))
zi=sp.I
mob=lambda M,w: sp.simplify((M[0,0]*w+M[0,1])/(M[1,0]*w+M[1,1]))
ok('F4 fixed points of L_ax on the boundary: z^2-z-1=0 => Phi, 1-Phi', sp.simplify(mob(Lax,Phi)-Phi)==0 and sp.simplify(mob(Lax,1-Phi)-(1-Phi))==0)
ok('F5 i lies on rail |z-1/2|^2=5/4', sp.simplify(abs(zi-sp.Rational(1,2))**2-sp.Rational(5,4))==0)
w=mob(Lax,zi)
ok('F6 L_ax i = 1+i (still on rail)', sp.simplify(w-(1+zi))==0 and sp.simplify(abs(w-sp.Rational(1,2))**2-sp.Rational(5,4))==0)
cd=1+abs(zi-w)**2/(2*sp.im(zi)*sp.im(w))
ok('F7 hyperbolic step i -> L_ax i has cosh d=3/2=cosh(2 log Phi)', sp.simplify(cd-sp.Rational(3,2))==0 and sp.simplify(sp.cosh(2*sp.log(Phi)).rewrite(sp.exp)-sp.Rational(3,2))==0)
ok('F8 tr L_ax = sqrt5 = 2cosh(log Phi); translation length 2 log Phi', sp.simplify(Lax.trace()-sqrt(5))==0 and sp.simplify(2*sp.cosh(sp.log(Phi)).rewrite(sp.exp)-sqrt(5))==0)
tt=symbols('tt',real=True); v,k,Tp=symbols('v k T',real=True)
rho=lambda Lam: (tt*Lam/2*J).exp()
ok('F9 (series) exp((t/2)(v+kT)J)=exp(t v/2 J)exp(k t logPhi J)', Z(sp.simplify((tt*(v+k*2*log(Phi))/2*J).exp()-(tt*v/2*J).exp()*(k*tt*log(Phi)*J).exp())))
ctl('F-ctl1 rail wrong centre (0): i not on |z|^2=5/4', sp.simplify(abs(zi)**2-sp.Rational(5,4))==0)
ctl('F-ctl2 step is cosh d = 2', sp.simplify(cd-2)==0)

# --- G. projective / unitary chart --------------------------------------
M=Matrix([[1,0],[1,-1]]); K=Matrix([[1,-1],[-1,2]]); Zc=Matrix([[1,I],[0,I]])
ok('G1 M^2=I, det M=-1', M*M==Id and M.det()==-1)
Up=I*M
ok('G2 U_pr^2=-I, U_pr^4=I', Z(Up*Up+Id) and Z(Up**4-Id))
ok('G3 U_pr = Z J Z^-1', Z(sp.simplify(Zc*J*Zc.inv()-Up)))
ok('G4 K=(Z^-1)^dagger Z^-1', Z(sp.simplify(Zc.inv().H*Zc.inv()-K)))
ok('G5 K positive definite', K.is_positive_definite)
ok('G6 J^dagger J=I', Z(J.H*J-Id))
ok('G7 U_pr^dagger K U_pr = K', Z(sp.simplify(Up.H*K*Up-K)))
A=Matrix([[1,2+sqrt(5)],[0,sqrt(5)]])
ok('G8 A_ch H A_ch^-1 = M_pr', Z(sp.simplify(A*H*A.inv()-M)))
Lpr=(A*Lax*A.inv()).applyfunc(sp.simplify)
ok('G9 L_pr=[[1+sqrt5,-2-sqrt5],[1,-1]]', Z(Lpr-Matrix([[1+sqrt(5),-2-sqrt(5)],[1,-1]])))
ok('G10 M L_pr M = L_pr^-1, det L_pr = 1', Z(sp.simplify(M*Lpr*M-Lpr.inv())) and sp.simplify(Lpr.det()-1)==0)
xs,ys=symbols('xs ys'); Ap=(xs*Id+ys*M)*A
ok('G11 (xI+yM)A_ch satisfies A\'H=M A\'', Z(sp.simplify(Ap*H-M*Ap)))
a1,a2,a3,a4=symbols('a1:5'); Gen=Matrix([[a1,a2],[a3,a4]])
sol=sp.solve(list(Gen*H-M*Gen),[a1,a2,a3,a4],dict=True)[0]
ok('G12 solution space of A\'H=M A\' has dimension 2', len(Gen.free_symbols-set(sol.keys()))==2)
ctl('G-ctl1 adapter with wrong entry (2-sqrt5) fails', Z(sp.simplify(Matrix([[1,2-sqrt(5)],[0,sqrt(5)]])*H*Matrix([[1,2-sqrt(5)],[0,sqrt(5)]]).inv()-M)))
ctl('G-ctl2 K indefinite alternative [[1,-2],[-2,2]]', Matrix([[1,-2],[-2,2]]).is_positive_definite)

# --- H. arithmetic address -----------------------------------------------
aa,bb=symbols('aa bb',integer=True)
Nalg=sp.expand((aa+bb*Phi)*(aa+bb*(1-Phi)))
ok('H1 N(a+b Phi)=a^2+ab-b^2', sp.simplify(Nalg-(aa**2+aa*bb-bb**2))==0)
zx=Matrix([bb,aa])
ok('H2 z_x^T G z_x = 2N(x)', sp.simplify((zx.T*G*zx)[0]-2*(aa**2+aa*bb-bb**2))==0)
Nf=lambda a,b: a*a+a*b-b*b
ok('H3 N(Phi x)=-N(x), N(Phi^2 x)=N(x) (Phi*(a+bPhi)=b+(a+b)Phi)', all(Nf(b,a+b)==-Nf(a,b) and Nf(a+b,a+2*b)==Nf(a,b) for a in range(-9,10) for b in range(-9,10)))
ok('H4 Fac_G(Phi x)=Fac_G(x) on a 19x19 grid (x!=0)', all(sp.factorint(abs(Nf(b,a+b)))==sp.factorint(abs(Nf(a,b))) for a in range(-9,10) for b in range(-9,10) if Nf(a,b)!=0))
ok('H5 F9=34 and 137=1+4*34=11^2+4^2', fib[9]==34 and 137==1+4*34==11**2+4**2)
lucas=[2,1]; [lucas.append(lucas[-1]+lucas[-2]) for _ in range(10)]
ok('H5b Lucas L5=11', lucas[5]==11)
ok('H6 137 prime; 4^17 = -1 mod 137; ord_137(4)=34', sp.isprime(137) and pow(4,17,137)==136 and sp.n_order(4,137)==34)
ok('H7 |F_137^x|=136=4*34 so F^x/<4> has order 4 (cyclic quotient C4)', sp.totient(137)==136 and 136//34==4)
ok('H8 548=4*137; Z/548 = Z/4 x Z/137 (gcd=1, CRT bijection)', 548==4*137 and sp.gcd(4,137)==1 and len({(n%4,n%137) for n in range(548)})==548)
ctl('H-ctl1 N(Phi x)=+N(x)', all(Nf(b,a+b)==Nf(a,b) for a in range(-3,4) for b in range(-3,4)))
ctl('H-ctl2 ord_137(4)=17', sp.n_order(4,137)==17)
ctl('H-ctl3 417 = -1 mod 137 read literally (4*100+17)', 417%137==136)


# --- extra: J preserves Om; non-orthogonality for all tested n -------------
ok('B13 J^T Om J = Om (det J = 1)', J.T*Om*J==Om)
ok('C13 (L_ax^n)^T L_ax^n = Q^(2n) and != I, n=1..25', all((Lax**n).T*(Lax**n)==Q**(2*n) and Q**(2*n)!=Id for n in range(1,26)))
ok('C14 off-diagonal of Q^(2n) is F(2n) >= 1, n=1..25', all((Q**(2*n))[0,1]==fib[2*n] and fib[2*n]>=1 for n in range(1,26)))

# --- I. pointwise identities quoted in section 9.3 -------------------------
import random
random.seed(20261119)
def rsym(n):
    M=zeros(n,n)
    for i in range(n):
        for j in range(i,n):
            M[i,j]=M[j,i]=sp.Integer(random.randint(-4,4))
    return M
def rpd(n):
    A=Matrix(n,n,lambda i,j: sp.Integer(random.randint(-3,3)))
    return A*A.T+n*eye(n)
def dewitt(n,trials=15):
    good=True
    for _ in range(trials):
        g=rpd(n); B=g.inv(); P=rsym(n); Hm=rsym(n)
        tau=(g*P).trace(); lam=(B*Hm).trace()
        K=2*g*P*g-tau*g; C=lam*B-B*Hm*B
        good = good and ((K*C).trace()==-2*(P*Hm).trace())
    return good
ok('I1 DeWitt contraction tr(KC)=-2 tr(PH), dim 3, 15 random exact samples', dewitt(3))
ctl('I-ctl1 same contraction in dimension 4', dewitt(4))
ctl('I-ctl2 same contraction in dimension 2', dewitt(2))
X=symbols('X1:4'); vs=[sp.Function('v%d'%i)(*X) for i in range(1,4)]; As=[sp.Function('A%d'%i)(*X) for i in range(1,4)]
Fm=lambda i,j: sp.diff(As[j],X[i])-sp.diff(As[i],X[j])
def lhs(j,improve=True):
    t=sum(vs[i]*Fm(i,j) for i in range(3))
    return t+(sp.diff(sum(vs[i]*As[i] for i in range(3)),X[j]) if improve else 0)
def rhs(j): return sum(vs[i]*sp.diff(As[j],X[i])+As[i]*sp.diff(vs[i],X[j]) for i in range(3))
ok('I2 Maxwell improvement: v^i F_ij + d_j(v.A) = (L_v A)_j, j=1..3', all(sp.simplify(sp.expand(lhs(j)-rhs(j)))==0 for j in range(3)))
ctl('I-ctl3 without the improvement term the identity fails', all(sp.simplify(sp.expand(lhs(j,False)-rhs(j)))==0 for j in range(3)))
Nf_=sp.Function('N')(*X); Mf_=sp.Function('M')(*X)
gm=Matrix([[2,1,0],[1,3,1],[0,1,2]]); gi=gm.inv()
w_up=[sum(gi[i,j]*(Nf_*sp.diff(Mf_,X[j])-Mf_*sp.diff(Nf_,X[j])) for j in range(3)) for i in range(3)]
w_dn=[sum(gm[i,k]*w_up[i] for i in range(3)) for k in range(3)]
ok('I3 lowering w_k = g_ik w^i = N d_k M - M d_k N (exact)', all(sp.simplify(sp.expand(w_dn[k]-(Nf_*sp.diff(Mf_,X[k])-Mf_*sp.diff(Nf_,X[k]))))==0 for k in range(3)))
ctl('I-ctl4 raising with g instead of g^-1 does not lower back', all(sp.simplify(sp.expand(sum(gm[i,k]*sum(gm[i,j]*(Nf_*sp.diff(Mf_,X[j])-Mf_*sp.diff(Nf_,X[j])) for j in range(3)) for i in range(3))-(Nf_*sp.diff(Mf_,X[k])-Mf_*sp.diff(Nf_,X[k]))))==0 for k in range(3)))
rho=sp.Function('rho')(*X)
div=lambda f: sum(sp.diff(f[i],X[i]) for i in range(3))
stokes=-Nf_*div([vs[i]*rho for i in range(3)])-sum(vs[i]*sp.diff(Nf_,X[i]) for i in range(3))*rho+div([Nf_*vs[i]*rho for i in range(3)])
ok('I4 density transfer: -N div(v rho) - (v.dN) rho + div(N v rho) = 0 (so the integral transfer holds when the flux vanishes)', sp.simplify(sp.expand(stokes))==0)
ctl('I-ctl5 wrong sign: -N div(v rho) + (v.dN) rho + div(N v rho)', sp.simplify(sp.expand(-Nf_*div([vs[i]*rho for i in range(3)])+sum(vs[i]*sp.diff(Nf_,X[i]) for i in range(3))*rho+div([Nf_*vs[i]*rho for i in range(3)])))==0)

# --- J. closure: the twenty-eighth word (v1.7.16) ---------------------------
th = symbols('theta', real=True)
def U(t): return cos(t)*Id + sin(t)*J                    # U(t)=exp(tJ), J^2=-I
qx, qy = symbols('x y', real=True); qv = Matrix([qx, qy])
ok('J1 U(pi)=-I, U(2pi)=I, U(8pi)=I, U(pi/2)=J', U(pi)==-Id and U(2*pi)==Id and U(8*pi)==Id and U(pi/2)==J)
ok('J2 U(k pi)=I iff k even (k=1..8): 8pi is four minimum loops', all((U(k*pi)==Id)==(k%2==0) for k in range(1,9)))
ctl('J-ctl1 U(pi)=I (the vector does not return after a half-turn)', U(pi)==Id)
ctl('J-ctl2 U(7pi)=I', U(7*pi)==Id)
ok('J3 det[q,U(theta)q]=sin(theta)|q|^2', sp.simplify(Matrix.hstack(qv,U(th)*qv).det()-sin(th)*(qx**2+qy**2))==0)
ok('J4 [-q]=[q]: U(pi)q=-q is collinear with q, and U(pi)q != q for q != 0', sp.simplify(Matrix.hstack(qv,U(pi)*qv).det())==0 and (U(pi)*qv-qv)==Matrix([-2*qx,-2*qy]))
ctl('J-ctl3 a quarter turn returns every line (det[q,Jq]=0 for all q)', sp.simplify(Matrix.hstack(qv,J*qv).det())==0)
ok('J5 U(t)^T I U(t)=I for every t', Z((U(th).T*U(th)).applyfunc(sp.trigsimp)-Id))
ok('J6 U(t)^T G U(t)=cos(2t) G + sin(2t) G J', Z((U(th).T*G*U(th)-(cos(2*th)*G+sin(2*th)*G*J)).applyfunc(sp.trigsimp)))
ok('J7 U(pi)^T G U(pi)=G', U(pi).T*G*U(pi)==G)
ctl('J-ctl4 U(pi/2)^T G U(pi/2)=G (a quarter turn reverses the sign instead)', U(pi/2).T*G*U(pi/2)==G)
ok('J8 difference remains: U(pi)-I=-2I != 0; silence: I+U(pi)=0', U(pi)-Id==-2*Id and Id+U(pi)==zeros(2,2) and (U(pi)-Id)!=zeros(2,2))
ctl('J-ctl5 the half-turn is blank: U(pi)-I=0', U(pi)-Id==zeros(2,2))
ok('J9 J^2=-I, J^4=I, J^k != I for k=1..3 (four-form)', J**2==-Id and J**4==Id and all(J**k!=Id for k in (1,2,3)))
psi = 1 - Phi
fib = [0,1]
for _ in range(60): fib.append(fib[-1]+fib[-2])
ok('J10 Q^n(1,1)^T=(F_{n+2},F_{n+1})^T, n=0..40', all((Q**n)*Matrix([1,1])==Matrix([fib[n+2],fib[n+1]]) for n in range(41)))
ok('J11 det[Q^n(1,1),(Phi,1)] = psi^(n+1), n=0..40', all(sp.simplify(sp.expand(Matrix.hstack((Q**n)*Matrix([1,1]),Matrix([Phi,1])).det()-psi**(n+1)))==0 for n in range(41)))
ok('J12 det[Q^n(1,1),(psi,1)] = Phi^(n+1), n=0..40', all(sp.simplify(sp.expand(Matrix.hstack((Q**n)*Matrix([1,1]),Matrix([psi,1])).det()-Phi**(n+1)))==0 for n in range(41)))
ok('J13 |psi|<1<Phi: the line [(1,1)] approaches [(Phi,1)] and leaves [(psi,1)]', abs(psi.evalf())<1<Phi.evalf())
ctl('J-ctl6 the orbit of [(1,1)] approaches [(psi,1)] (det[Q^n(1,1),(psi,1)] decreasing)', all(abs((fib[n+2]-psi*fib[n+1]).evalf())>abs((fib[n+3]-psi*fib[n+2]).evalf()) for n in range(30)))
ok('J14 fixed lines of Q on P(V): det[z,Qz]=x^2-xy-y^2, roots x/y=Phi,psi', sp.simplify(Matrix.hstack(qv,Q*qv).det()-(qx**2-qx*qy-qy**2))==0 and sp.simplify(Phi**2-Phi-1)==0 and sp.simplify(psi**2-psi-1)==0)
ok('J15 z^T G z = -2 det[z,Qz]: the read is 0 exactly on the fixed lines of Q', sp.simplify((qv.T*G*qv)[0]+2*Matrix.hstack(qv,Q*qv).det())==0)
ok('J16 read 0 at the fixed points: (Phi,1)^T G (Phi,1)=0=(psi,1)^T G (psi,1)', sp.simplify((Matrix([Phi,1]).T*G*Matrix([Phi,1]))[0])==0 and sp.simplify((Matrix([psi,1]).T*G*Matrix([psi,1]))[0])==0)
ctl('J-ctl7 the unit (1,1) reads 0', (Matrix([1,1]).T*G*Matrix([1,1]))[0]==0)
ok('J17 unit address x=1+Phi=Phi^2 has z_x=(1,1), N_alg=1, z^T G z=2', sp.simplify(1+Phi-Phi**2)==0 and (Matrix([1,1]).T*G*Matrix([1,1]))[0]==2 and 1*1+1*1-1*1==1)
ok('J18 Q=multiplication by Phi on addresses: z_{Phi x}=Q z_x for x=a+b Phi', all(Matrix([a+b,b])==Q*Matrix([b,a]) for a in range(-4,5) for b in range(-4,5)))
ok('J19 (-I)^8=I: eight half-turns close', (-Id)**8==Id and U(pi)**8==Id)
Hm=H
ok('J22 D_infinity: H^2=I, (H Lax)^2=I, H Lax H = Lax^-1, so <H,Lax> is generated by two involutions with product Lax', Hm*Hm==Id and Z((Hm*Lax)*(Hm*Lax)-Id) and Z(Hm*Lax*Hm-Lax.inv()))
ok('J23 tr(Lax^n)=Phi^n+Phi^-n > 2 for n=1..40, so Lax has infinite order', all(sp.simplify(sp.expand((Lax**n).trace()-(Phi**n+Phi**(-n))))==0 and (Phi**n+Phi**(-n)).evalf()>2 for n in range(1,41)))
ctl('J-ctl10 Lax^k=I for some k in 1..40 (the extension would close like D4)', any(Z(Lax**k-Id) for k in range(1,41)))
# 28 = C(8,2): round-robin one-factorization of K8 on Z7 u {inf}, and Lagrange's identity in R^8
INF='inf'
rounds=[]
for r in range(7):
    m=[frozenset((INF,r))]+[frozenset(((r+k)%7,(r-k)%7)) for k in (1,2,3)]
    rounds.append(m)
allp=[p for m in rounds for p in m]
alls={frozenset(c) for c in itertools.combinations(list(range(7))+[INF],2)}
ok('J20 K8: 7 rounds of 4, each a perfect matching, every one of the 28 pairs exactly once', len(alls)==28 and len(allp)==28 and set(allp)==alls and all(len(frozenset().union(*m))==8 for m in rounds))
ctl('J-ctl8 six rounds cover all 28 pairs', len({p for m in rounds[:6] for p in m})==28)
av=symbols('a0:8'); bv=symbols('b0:8')
lag_l=sum(x*x for x in av)*sum(y*y for y in bv)-sum(x*y for x,y in zip(av,bv))**2
lag_r=sum((av[i]*bv[j]-av[j]*bv[i])**2 for i,j in itertools.combinations(range(8),2))
ok('J21 Lagrange in R^8: |a|^2|b|^2-(a.b)^2 = sum over the 28 pairs (a_i b_j - a_j b_i)^2', sp.expand(lag_l-lag_r)==0)
lag_r27=sum((av[i]*bv[j]-av[j]*bv[i])**2 for i,j in list(itertools.combinations(range(8),2))[:-1])
ctl('J-ctl9 27 pair terms give the same identity', sp.expand(lag_l-lag_r27)==0)

# --- report ----------------------------------------------------------
passed=sum(1 for _,p,c in R if p); total=len(R); ctls=sum(1 for _,_,c in R if c)
for name,p,c in R:
    if not p: print('FAIL', name)
fam={}
for name,p_,c in R:
    k=name[0] if not name.split()[0].split('-')[0].endswith('ctl') else name[0]
    d=fam.setdefault(k,[0,0]); d[0]+=1; d[1]+= (1 if c else 0)
print('FAMILIES', ' '.join('%s=%d/%d'%(k,v[0],v[1]) for k,v in sorted(fam.items())))
print('checks: %d total, %d passed, %d negative controls (all must pass as "refused")'%(total,passed,ctls))
print('RESULT', 'OK' if passed==total else 'FAILED'); sys.exit(0 if passed==total else 1)
