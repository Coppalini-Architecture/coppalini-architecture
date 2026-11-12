from __future__ import annotations
from pathlib import Path
from fractions import Fraction as F
from itertools import combinations
import sympy as sp
import json, hashlib, csv, math, xml.etree.ElementTree as ET

OUT=Path(__file__).resolve().parent; OUT.mkdir(exist_ok=True,parents=True)
checks=[]
def check(name,condition,detail=''):
    if not bool(condition): raise AssertionError(name+': '+detail)
    checks.append({'test':name,'status':'PASS','detail':detail})
def canon(e): return tuple(sorted(e))
# Source algebra: Linear Infinity (canonical 0.1), pp.2,7-9,12-15.
r=sp.sqrt(5); I=sp.eye(2)
Q=sp.Matrix([[1,1],[1,0]]); C=sp.Matrix([[0,-1],[1,0]])
G=C*Q-Q*C; H=G/r; S=(2*Q-I)/r; L=(Q+2*I)/r
simp=lambda X:X.applyfunc(sp.simplify)
check('Q recurrence',Q*Q==Q+I)
check('root quarter-turn',C**2==-I and C**4==I)
check('G root',G==sp.Matrix([[-2,1],[1,2]]) and G**2==5*I)
check('welded mirrors',simp(H*C-S)==sp.zeros(2) and simp(H*H)==I)
check('axial square',simp(L*L)==Q*Q)
check('axial signed metric',simp(L.T*G*L)==G)
check('axial reversal',simp(H*L*H-L.inv())==sp.zeros(2))
phi=(1+r)/2; psi=(1-r)/2; z=sp.Symbol('z')
xi=lambda z:(phi-z)/(z-psi)
act=lambda A,z:(A[0,0]*z+A[0,1])/(A[1,0]*z+A[1,1])
check('golden chart dilation',sp.simplify(xi(act(L,z))-phi**-2*xi(z))==0)
# New explicitly named change of basis; no physical identification.
M=sp.Matrix([[1,0],[1,-1]])
P=sp.Matrix([[1,2+r],[0,r]])
check('projective mirror',M*M==I and M.det()==-1)
check('new change of basis P H P^-1 = M',simp(P*H*P.inv()-M)==sp.zeros(2))
L_M=simp(P*L*P.inv())
check('new conjugated carriage reverses',simp(M*L_M*M-L_M.inv())==sp.zeros(2))
check('central lift', (sp.I*M)**2==-I and (sp.I*M)**4==I)

# Source METL Sec.V; symbolic phase cases prove all n, not just examples.
c,k=sp.symbols('c k',integer=True,nonnegative=True)
for p in range(4):
 for t in range(4):
  # n=4k+t; the number of wrap events is k+(p+t)//4.
  check(f'carry identity p={p}, n mod4={t}',
        sp.expand(4*(k+(p+t)//4)+(p+t)%4 - (4*k+p+t))==0)
check('four-step lift as source-defined carry', all((p+4)%4==p and (p+4)//4==1 for p in range(4)))

offsets=[(ell,p,4*ell+p) for ell in range(2) for p in range(4)]
check('eight occurrence addresses',len({n for ell,p,n in offsets})==8)
edges=list(combinations(range(8),2)); es=set(edges)
check('all unordered pairs',len(es)==28)
check('every occurrence degree seven', all(sum(v in e for e in edges)==7 for v in range(8)))
counts=[sum(a//4==0 and b//4==0 for a,b in edges),sum(a//4!=b//4 for a,b in edges),sum(a//4==1 and b//4==1 for a,b in edges)]
check('two-cycle decomposition',counts==[6,16,6],str(counts))
# Published four-phase SVG uses occurrence label 7 for the distinguished infinity slot.
matchings={a:[canon((7,a))]+[canon(((a+j)%7,(a-j)%7)) for j in range(1,4)] for a in range(7)}
flatten=[e for a in range(7) for e in matchings[a]]
check('seven complete matchings',all(len({v for e in mm for v in e})==8 for mm in matchings.values()))
check('matching partition equals K8',len(flatten)==28 and len(set(flatten))==28 and set(flatten)==es)
slot={e:(a,b) for a in range(7) for b,e in enumerate(matchings[a])}
scan=[matchings[q%7][q%4] for q in range(28)]
check('CRT scanner bijection',len(set(scan))==28 and set(scan)==es)
check('CRT inverse',all((8*a+21*b)%28==q for q,(a,b) in enumerate([(q%7,q%4) for q in range(28)])))
# Incidence and triangle maps: exact integer rank.
D=sp.zeros(28,8)
for row,(a,b) in enumerate(edges):D[row,a]=-1;D[row,b]=1
triangles=list(combinations(range(8),3)); B=sp.zeros(56,28); index={e:j for j,e in enumerate(edges)}
for row,(a,b,c_) in enumerate(triangles):
 B[row,index[a,b]]=1;B[row,index[b,c_]]=1;B[row,index[a,c_]]=-1
check('potential difference rank',D.rank()==7)
check('triangle constraint rank',B.rank()==21)
check('triangle telescoping',B*D==sp.zeros(56,8))
check('triangle-potential dimensions',28-B.rank()==D.rank())
# Exact declared spatial display: four unit phase positions, two normalized lift levels.
xy=[(1,0),(0,1),(-1,0),(0,-1)]
verts=[(F(xy[p][0]),F(xy[p][1]),F(ell)) for ell,p,n in offsets]
# Rational oblique projection; selected for legibility, NOT a physical metric.
# The axial displacement maps to a horizontal separation with a small vertical offset.
A=sp.Matrix([[1,sp.Rational(1,5),sp.Rational(14,5)],
             [sp.Rational(1,7),1,sp.Rational(3,5)]])
coords=[]
for v in verts:
 t=A*sp.Matrix(v);coords.append((F(t[0]),F(t[1])))
check('declared 3D display affine rank',sp.Matrix([list(sp.Matrix(v)-sp.Matrix(verts[0])) for v in verts[1:]]).rank()==3)
check('2D display keeps eight vertices',len(set(coords))==8)
# Diagnose unintended vertex-on-edge collisions; true crossing locations have no vertex.
def interior(p,a,b):
 cross=(p[0]-a[0])*(b[1]-a[1])-(p[1]-a[1])*(b[0]-a[0])
 return cross==0 and sum((p[i]-a[i])*(p[i]-b[i]) for i in range(2))<0
collisions=[(v,e) for v in range(8) for e in edges if v not in e and interior(coords[v],coords[e[0]],coords[e[1]])]
check('no vertex lies inside an unrelated edge',not collisions,str(collisions))
# Compare the 28 edges and colors with the actual supplied published SVG.
ns={'s':'http://www.w3.org/2000/svg'}
svg_path=OUT/'references'/'four-phase-eight-state(2).svg'
root=ET.fromstring(svg_path.read_text());g=root.find('s:g',ns)
nodes=[e for e in g if e.tag.endswith('}circle') and e.attrib.get('r')=='4']
node_xy=[(F(n.attrib['cx']),F(n.attrib['cy'])) for n in nodes]
import re
palette=['#a4bfae','#a2b4cd','#a6a4c5','#b9a8bf','#d8a6a3','#e1bc9b','#d9d09e']
svg_edges=[]
for e in g:
 if e.tag.endswith('}path') and e.attrib.get('opacity')=='.72':
  nums=list(map(F,re.findall(r'-?\d+(?:\.\d+)?',e.attrib['d'])))
  a=node_xy.index(tuple(nums[:2]));b=node_xy.index(tuple(nums[2:4]));edge=canon((a,b))
  svg_edges.append(edge)
  check(f'published SVG matching for edge {edge}',e.attrib['stroke']==palette[slot[edge][0]])
check('published cover edge set',len(svg_edges)==28 and set(svg_edges)==es)

records=[]
for a,b in edges:
 layer,position=slot[(a,b)]
 q=(8*layer+21*position)%28
 records.append({'i':a,'j':b,'cycle_i':a//4,'phase_i':a%4,'cycle_j':b//4,'phase_j':b%4,'matching_a':layer,'slot_b':position,'scan_q':q})
with (OUT/'edge_ledger.csv').open('w',newline='') as f:
 w=csv.DictWriter(f,fieldnames=records[0]);w.writeheader();w.writerows(records)
coord_records=[{'i':i,'ell':i//4,'phase':i%4,'spatial':[str(x) for x in verts[i]],'projection':[str(x) for x in coords[i]]} for i in range(8)]
(OUT/'graph_coordinates.json').write_text(json.dumps({'spatial_convention':'(cos(pi*p/2),sin(pi*p/2),ell); ell=0,1 relative to cycle c','display_projection':str(A),'metric_claim':'No physical metric; declared diagram only. Crossings are not vertices.','vertices':coord_records,'edges':records},indent=2))
receipt={'arithmetic':'exact integer, rational, and Q(sqrt(5)); SymPy '+sp.__version__,'proof_status':'Executable checks plus source proofs; this audit has not been run through Lean.','tests':checks,'count':len(checks),'summary':{'vertices':8,'edges':28,'vertex_degree':7,'within_first_cycle':6,'cross_cycle':16,'within_second_cycle':6,'matching_dimensions':[4]*7,'triangle_rank':21,'potential_rank':7},'new_basis_change':{'P':str(P),'L_M':str(L_M),'scope':'Exact matrix conjugacy; separately derived here.'}}
(OUT/'verification.json').write_text(json.dumps(receipt,indent=2))
(OUT/'verification.txt').write_text('\n'.join(f"PASS {c['test']}"+(f" — {c['detail']}" if c['detail'] else '') for c in checks)+f"\n\nALL {len(checks)} CHECKS PASS\nNo Lean certification asserted for this new audit.\n")
print(json.dumps({'tests':len(checks),'summary':receipt['summary'],'P':str(P),'L_M':str(L_M),'coords':coord_records},indent=2))
