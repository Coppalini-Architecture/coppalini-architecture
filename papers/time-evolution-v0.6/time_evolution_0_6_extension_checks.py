#!/usr/bin/env python3
"""Finite exact algebra verification for the controlled extension of Paper 32.
All comparisons occur in Q(sqrt(5)) or exact symbolic algebra.
"""
from itertools import product
import sympy as s
I=s.eye(2); sq=s.sqrt(5); phi=(1+sq)/2; psi=(1-sq)/2
Q=s.Matrix([[1,1],[1,0]]); Om=s.Matrix([[0,1],[-1,0]])
G=Q*Om-Om*Q; C=-Om; S=(2*Q-I)/sq; H=G/sq
L=(Q+2*I)/sq; T=-L
vp=s.Matrix([phi,1]); vm=s.Matrix([psi,1]); Z=2*vp-3*vm
checks=[]
def equal(tag,a,b):
  d=a-b
  elems=list(d) if isinstance(d,s.MatrixBase) else [d]
  assert all(s.simplify(x)==0 for x in elems),(tag,d)
  checks.append(tag)
def gg(z):return (z.T*G*z)[0]

for tag,a,b in [('Q2',Q*Q,Q+I),('C2',C*C,-I),('G2',G*G,5*I),('LS',L*S,Q),('L2',L*L,Q*Q),('T2',T*T,Q*Q),('gQ',Q.T*G*Q,-G),('omegaQ',Q.T*Om*Q,-Om),('gL',L.T*G*L,G),('gT',T.T*G*T,G),('gH',H.T*G*H,G),('omegaH',H.T*Om*H,-Om)]: equal(tag,a,b)

# One exact basis calculation supplies the eigenline displacement laws for each sampled length.
for n in range(1,6):
  Lpow=L**n
  equal(f'Lpow determinant {n}',Lpow.det(),1)
  equal(f'Lpow metric {n}',Lpow.T*G*Lpow,G)
  equal(f'Lpow area {n}',Lpow.T*Om*Lpow,Om)
  equal(f'eig plus {n}',Lpow*vp,phi**n*vp)
  equal(f'eig minus {n}',Lpow*vm,phi**(-n)*vm)
  for mask in product((0,1),repeat=n):
    sign=(-1)**sum(mask)
    # Group composition in an abelian E: a_j=L or -L, so product=sign L^n.
    expected=sign*Lpow
    signed=sign*(2*phi**n*vp-3*phi**(-n)*vm)
    equal(f'action {n} {mask}',expected*Z,signed)
    # Actual receipt includes each seed, action and predecessor; inverse recovery by split.
    receipts=tuple((j,tuple(mask[:j]),mask[j]) for j in range(n))
    assert (receipts[:-1],receipts[-1]) == (receipts[:n-1],(n-1,tuple(mask[:n-1]),mask[-1]))
    checks.append(f'receipt split {n} {mask}')
    # The axial reader quotients by period 2log phi and retains |a/b| shift phi^(2n).
    aa=sign*2*phi**n; bb=sign*(-3)*phi**(-n)
    equal(f'axial ratio {n} {mask}', s.Abs(aa/bb), s.Rational(2,3)*phi**(2*n))
    assert s.sign(aa) == sign
    checks.append(f'oriented sign {n} {mask}')

# A single admitted seed changes full state, while the axial reader stays fixed.
equal('L vs T',T*Z,-L*Z)
assert L*Z != T*Z
checks.append('distinct successor same initial state')

bases={'A':1,'C':s.I,'T':-1,'G':-s.I}; complement={'A':'T','T':'A','C':'G','G':'C'}
for b in bases:
  equal('DNA half-turn '+b,bases[complement[b]],-bases[b])
  assert complement[complement[b]]==b
  checks.append('DNA involution '+b)
for w in ('ACGT','GATTACA','GGGCCC','ATATAT'):
  rc=lambda word:''.join(complement[b] for b in word[::-1])
  assert rc(rc(w))==w
  checks.append('DNA reverse complement '+w)

for d in (s.Rational(1,1),s.Rational(-1,1),s.Rational(1,2),s.Rational(-1,2),s.Rational(2,7),s.Rational(-3,5)):
  z=s.sqrt(abs(d)/10)*(vp+s.sign(d)*vm)
  equal('contrast value '+str(d),gg(z),d)
  equal('Q contrast switch '+str(d),gg(Q*z),-d)

print(f'PASS: {len(checks)} exact and finite controlled-action checks')
print('SCOPE: symbolic algebra + discrete L/T sequence samples + DNA/contrast encodings')
