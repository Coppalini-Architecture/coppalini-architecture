#!/usr/bin/env python3
"""Exact checks supplementing the source geometry audit.

Symbolic identities are checked as identities, finite sets exhaustively,
and illustrative state records as labeled examples. No float tolerance
or machine-checked status for the analytic propositions is asserted.
"""
from pathlib import Path
from itertools import combinations
import json, hashlib, re, sys
import sympy as s
import xml.etree.ElementTree as ET
ROOT=Path(__file__).resolve().parents[1]
checks=[]
def check(name, ok, kind='exact symbolic identity'):
    if not bool(ok):
        raise AssertionError(name)
    checks.append({'name':name,'status':'PASS','kind':kind})
def zero(A): return all(s.simplify(v)==0 for v in A)
I=s.eye(2);M=s.Matrix([[1,0],[1,-1]])
C=s.Matrix([[0,-1],[1,0]]);Q=s.Matrix([[1,1],[1,0]])
G=C*Q-Q*C; rt=s.sqrt(5);H=G/rt;L=(Q+2*I)/rt
P=s.Matrix([[1,2+rt],[0,rt]]);Z=s.Matrix([[1,s.I],[0,s.I]])
U=s.I*M;K=s.Matrix([[1,-1],[-1,2]])
check('M determinant and involution', M.det()==-1 and M*M==I)
x,y=s.symbols('x y',real=True)
v=s.Matrix([x,y]);check('complete homogeneous fixed-point polynomial',s.det(s.Matrix.hstack(v,M*v)).expand()==x*x-2*x*y)
check('complex phase adapter',zero(U-Z*C*Z.inv()))
check('Hermitian metric from adapter',zero(K-Z.inv().conjugate().T*Z.inv()))
check('positive metric leading minors',K[0,0]>0 and K.det()>0,'exact finite arithmetic')
check('lift preserves Hermitian metric',zero(U.conjugate().T*K*U-K))
check('lift determinant and exact order four',U.det()==1 and U**2==-I and U**4==I and U!=I)
check('real mirror adapter',zero(P*H*P.inv()-M))
LM=s.simplify(P*L*P.inv());GM=s.simplify(P.inv().T*G*P.inv())
check('printed transported metric',zero(GM-s.Matrix([[-2,2+rt],[2+rt,-4-2*rt]])))
check('transported metric invariance',zero(LM.T*GM*LM-GM))
check('transported mirror invariance',zero(M.T*GM*M-GM))
q=s.symbols('q',integer=True)
check('all-integer Zeno homogeneous identity',zero(M*s.Matrix([1-q,1])+s.Matrix([q-1,q])))
xf,yf,f=s.symbols('x_f y_f f',nonzero=True)
check('thin-lens polynomial normalization', s.expand((f*xf)*(f*yf)-f*(f*xf+f*yf)-f*f*(xf*yf-xf-yf))==0)
m=s.Matrix(s.symbols('m0:8',real=True));r=s.Matrix(s.symbols('r0:8',real=True))
a=(m.T*r)[0];nm=(m.T*m)[0];nr=(r.T*r)[0];D=m*r.T-r*m.T
check('signed matrix alternation',zero(D+D.T))
check('generic decoder before unit normalization',zero(a*m+D.T*m-nm*r))
w=s.Matrix([D[j,k] for j,k in combinations(range(8),2)])
check('Lagrange exterior-product identity',s.expand((w.T*w)[0]-nm*nr+a*a)==0)
mu=s.ones(8,1)/s.sqrt(8);au=(mu.T*r)[0];Du=mu*r.T-r*mu.T
check('uniform reference normalized', (mu.T*mu)[0]==1)
check('uniform-reference edge differences',all(s.simplify(Du[j,k]-(r[k]-r[j])/s.sqrt(8))==0 for j,k in combinations(range(8),2)))
check('uniform-reference decoder',all(s.simplify(au/s.sqrt(8)+sum(Du[k,j] for k in range(8))/s.sqrt(8)-r[j])==0 for j in range(8)))
# Exact coordinate projector decomposition from the verified edge ledger.
data=json.loads((ROOT/'verification/geometry_audit/graph_coordinates.json').read_text())
projectors=[]
for b in range(7):
    diag=[int(e['matching_a']==b) for e in data['edges']]
    projectors.append(s.diag(*diag))
check('all seven projector dimensions',[p.trace() for p in projectors]==[4]*7,'exhaustive finite calculation')
check('all 49 projector products',all(projectors[a]*projectors[b]==(projectors[a] if a==b else s.zeros(28)) for a in range(7) for b in range(7)),'exhaustive finite calculation')
check('projector sum identity',sum(projectors,s.zeros(28))==s.eye(28),'exhaustive finite calculation')
# Polynomial check on each symbolic seam norm; partition is exhaustive.
check('seven-band norm partition',s.expand(sum((w.T*p*w)[0] for p in projectors)-(w.T*w)[0])==0)
examples=[s.eye(8)[:,0],-s.eye(8)[:,0],s.Matrix([s.Rational(3,5),s.Rational(4,5),0,0,0,0,0,0]),mu]
check('normal-form normalized state examples',all((rv.T*rv)[0]==1 and zero(((mu.T*rv)[0]*mu+(mu*rv.T-rv*mu.T).T*mu)-rv) for rv in examples),'finite illustrative examples')
check('Euclidean address example range',all(4*(n//4)+n%4==n for n in range(112)),'finite illustrative examples; universal proof in manuscript')
# Exact model derivative identifying the cyclic Noether momentum.
eps,delta,ddot,Ldot=s.symbols('epsilon delta deltadot Lambdadot',real=True)
lag=(ddot**2+eps*s.cosh(delta)**2*Ldot**2)/2
check('Noether momentum differentiation',s.simplify(s.diff(lag,Ldot)-eps*s.cosh(delta)**2*Ldot)==0)
ns={'s':'http://www.w3.org/2000/svg'}
root=ET.parse(ROOT/'assets/cover.svg').getroot()
g=root.find("s:g[@id='verified-diagram']",ns)
edges=g.findall('s:line',ns);nodes=g.findall('s:circle',ns)
check('cover eight occurrences',len(nodes)==8 and {v.attrib['data-occurrence'] for v in nodes}==set(map(str,range(8))),'exact SVG inspection')
check('cover full edge identity',len(edges)==28 and {tuple(map(int,e.attrib['data-pair'].split(','))) for e in edges}==set(combinations(range(8),2)),'exact SVG inspection')
check('cover matching assignments',all(e.attrib['data-matching']==str(next(d['matching_a'] for d in data['edges'] if f"{d['i']},{d['j']}"==e.attrib['data-pair'])) for e in edges),'exact SVG inspection')
check('cover eight unique projected positions',len({(v.attrib['cx'],v.attrib['cy']) for v in nodes})==8,'exact SVG inspection')
check('source style ground and canvas',root.attrib['viewBox']=='0 0 800 1050' and root.find('s:rect',ns).attrib['fill']=='#faf8f3','exact SVG inspection')
report={'sympy':s.__version__,'total':len(checks),'checks':checks,'status':'PASS','scope':'Exact supplementary identities, exhaustive finite relations, and separately labeled examples. Not a new Lean or empirical certificate.'}
(ROOT/'verification/manuscript_checks.json').write_text(json.dumps(report,indent=2))
text='\n'.join(f"PASS [{c['kind']}] {c['name']}" for c in checks)+f'\n\nALL {len(checks)} MANUSCRIPT CHECKS PASS\n'
(ROOT/'verification/manuscript_checks.txt').write_text(text)
print(text)
