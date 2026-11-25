import json, subprocess, random, importlib.util
from fractions import Fraction as F
def load(n,p):
    s=importlib.util.spec_from_file_location(n,p); m=importlib.util.module_from_spec(s); s.loader.exec_module(m); return m
rr=load("rr","/home/claude/rr/relax_receipt.py")
def node(cmds):
    r=subprocess.run(["node","/home/claude/rr/relax_cli.js"],input="\n".join(json.dumps(c) for c in cmds),capture_output=True,text=True)
    assert r.returncode==0, r.stderr[:1500]; return json.loads(r.stdout)
def pyv(t):
    try: return rr.check(json.loads(t))
    except Exception: return "INVALID"
rnd=random.Random(77)
cmds=[];exp=[]
for _ in range(3000):
    q,s,k=rnd.randrange(4),rnd.randrange(137),rnd.randrange(2,301); d=F(rnd.randrange(-500,500),rnd.choice([1000,7,97,1013]))
    if not -F(1,2)<=d<F(1,2): d=F(1,3)
    cmds.append({"op":"step","q":q,"s":s,"d":rr.fs(d),"k":k}); exp.append({"r":rr.step(q,s,d,k),"rho":rr.fs(rr.rho(k)),"kappa":rr.fs(1-rr.rho(k))})
got=node(cmds); print("value parity (q,s,a,d',rho,kappa), Fraction vs BigInt:",sum(g==e for g,e in zip(got,exp)),"/",len(exp))
texts=[]
for _ in range(400):
    q,s,k=rnd.randrange(4),rnd.randrange(137),rnd.randrange(2,301); d=F(rnd.randrange(-500,500),1000)
    rc=rr.make_receipt(q,s,d,k,"x"); texts.append(json.dumps(rc))
    for _ in range(3):
        q2,s2=rnd.randrange(4),rnd.randrange(137); rec={"q":q2,"s":s2,"a":rr.addr(q2,s2),"d":rr.fs(F(rnd.randrange(-500,501),1000))}
        if rec==rc["recomputed"]: continue
        r2=rr.make_receipt(q,s,d,k,"x",recorded=rec); texts.append(json.dumps(r2)); r2["delta"]=[]; texts.append(json.dumps(r2))
        r2["delta"]=[{"recorded":dict(rec),"recomputed":dict(rc["recomputed"],d="1/3")}]; texts.append(json.dumps(r2))
base=json.dumps(rr.make_receipt(2,9,F(1,8),12,"x"),indent=1)
edge={"k 12.0":('"k": 12','"k": 12.0'),"q 2.0":('"q": 2,','"q": 2.0,'),"s 9e0":('"s": 9,','"s": 9e0,'),"s -0 form":('"s": 9,','"s": 09,'),"q +2":('"q": 2,','"q": +2,'),
      "label tab":('"label": "x"','"label": "x\\t"'),"extra ws":('"q": 2,','"q":   2 ,'),"phase_step 2.0":('"phase_step": 2','"phase_step": 2.0'),"phase_step 2e0":('"phase_step": 2','"phase_step": 2e0'),
      "checks 1":('"non_expansion": true','"non_expansion": 1'),"d -0/1 text":('"d": "1/8"','"d": "-0/1"'),"d 2/16 text":('"d": "1/8"','"d": "2/16"')}
et=[]
for k,(a,b) in edge.items():
    assert a in base,k; et.append(base.replace(a,b,1))
allt=texts+et; js=node([{"op":"check","text":t} for t in allt])
bad=[i for i,t in enumerate(allt) if pyv(t)!=js[i]]
print("verdict parity on",len(texts),"generated texts + ",len(et),"edge forms: diffs",bad)
for i,k in enumerate(edge): print("  edge",k,"-> py",pyv(et[i]),"| js",js[len(texts)+i])
non=["not json","[]","null","5",'{"schema":1}','{}']
jn=node([{"op":"check","text":t} for t in non]); assert all(pyv(t)==j=="INVALID" for t,j in zip(non,jn)); print("non-object / malformed texts: both INVALID")
assert not bad
