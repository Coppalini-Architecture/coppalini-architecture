from pathlib import Path
SOURCE = Path(__file__).resolve().parents[1] / "sources"
HERE = Path(__file__).resolve().parent
import importlib.util, random, json
from fractions import Fraction as F
def load(n,p):
    s=importlib.util.spec_from_file_location(n,p); m=importlib.util.module_from_spec(s); s.loader.exec_module(m); return m
rr=load("rr",str(SOURCE / "relax_receipt.py")); hz=load("hz",str(SOURCE / "harmonizer.py"))
rnd=random.Random(41); S=137
# independent path: rho_k from the matrix power Q^k = [[Fib_{k+1},Fib_k],[Fib_k,Fib_{k-1}]]; address from a CRT table
def mm(A,B): return [[A[0][0]*B[0][0]+A[0][1]*B[1][0],A[0][0]*B[0][1]+A[0][1]*B[1][1]],[A[1][0]*B[0][0]+A[1][1]*B[1][0],A[1][0]*B[0][1]+A[1][1]*B[1][1]]]
Qm=[[1,1],[1,0]]; P=[[1,0],[0,1]]; RHO={}
for k in range(1,301):
    P=mm(P,Qm)
    if k>=2: RHO[k]=F(P[1][1],P[0][1])           # Fib_{k-1} / Fib_k read off Q^k
crt={(a%4,a%137):a for a in range(548)}
n=0
for _ in range(3000):
    q,s,k=rnd.randrange(4),rnd.randrange(S),rnd.randrange(2,301); d=F(rnd.randrange(-500,500),1000)
    rc=rr.make_receipt(q,s,d,k,"x"); w=rc["recomputed"]
    assert rr.unfs(w["d"])==RHO[k]*d and w["q"]==(q+2)%4 and w["s"]==s and w["a"]==crt[((q+2)%4,s)]
    assert rc["input"]["a"]==crt[(q,s)] and (w["a"]-rc["input"]["a"])%548==274   # N2 on the address: a -> a+274
    assert rr.unfs(rc["trace"]["kappa"])==1-RHO[k] and abs(rr.unfs(w["d"]))<=abs(d); n+=1
print("matrix-power rho_k and CRT addresses agree with the receipt; a -> a+274 (N2); |d'| <= |d|:",n,"cases")
# chain: receipts feed each other; telescoping factor and sign
m=0
for _ in range(200):
    q0,s=rnd.randrange(4),rnd.randrange(S); d0=F(rnd.randrange(-499,500),1000); a,b=rnd.randrange(2,60),0; b=a+rnd.randrange(1,40)
    q,d=q0,d0
    for k in range(a+1,b+1):
        rc=rr.make_receipt(q,s,d,k,"x"); assert rr.check(rc)=="OK"
        o=rc["recorded"]; q,d=o["q"],rr.unfs(o["d"])
    assert d==d0*F(rr.FIB[a],rr.FIB[b]) and q==(q0+2*(b-a))%4; m+=1
print("receipt chains: each recorded output feeds the next input; final offset = d0*Fib_m/Fib_n, phase q0 + 2(n-m): ",m,"chains")
# link to the harmonizer on the plateau: y - s = d' exactly
c=0
for _ in range(1000):
    s,k=rnd.randrange(S),rnd.randrange(2,60); d=F(rnd.randrange(-499,500),1000)
    r=hz.H(0,s+d,F(1,2),1-RHO[k]); assert (r["y"]-s)%S==(rr.unfs(rr.step(0,s,d,k)["d"]))%S; c+=1
print("receipt offset d' = harmonizer y - s on the plateau (h = 1/2, kappa = 1 - Fib_{k-1}/Fib_k):",c,"cases")
# text-level: canonical-fraction and integer-token behaviour via json
rc=rr.make_receipt(2,9,F(1,8),12,"x"); t=json.dumps(rc)
assert rr.check(json.loads(t))=="OK"
for a,b in (('"k": 12','"k": 12.0'),('"q": 2','"q": 2.0'),('"s": 9,','"s": 9e0,')):
    assert a in t; assert rr.check(json.loads(t.replace(a,b,1)))=="INVALID"
print("float-token integers (12.0, 2.0, 9e0) -> INVALID in the Python checker")
