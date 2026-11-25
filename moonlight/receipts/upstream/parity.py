import json, subprocess, random, importlib.util
from fractions import Fraction as F
spec=importlib.util.spec_from_file_location("hz","/home/claude/harm/harmonizer.py"); hz=importlib.util.module_from_spec(spec); spec.loader.exec_module(hz)
def node(cmds):
    r=subprocess.run(["node","/home/claude/harm/harm_cli.js"],input="\n".join(json.dumps(c) for c in cmds),capture_output=True,text=True)
    assert r.returncode==0, r.stderr[:1500]
    return json.loads(r.stdout)
rnd=random.Random(5)
# 1. value parity
cmds=[];exp=[]
for _ in range(3000):
    q=rnd.randrange(4)
    x="%s%d.%d"%(rnd.choice(["","-"]),rnd.randrange(0,2000),rnd.randrange(0,10**rnd.randrange(1,7)))
    if rnd.random()<0.25: x=str(rnd.randrange(-300,300))+".5"
    h=rnd.choice(["0","0.5","0.1","0.25","0.49","0.3333"]); k=rnd.choice(["0","1","0.5","0.75","0.123"])
    cmds.append({"op":"H","q":q,"x":x,"h":h,"k":k})
    r=hz.H(q,hz.dec(x),hz.dec(h),hz.dec(k))
    exp.append({"s":r["s"],"a":r["a"],"y":hz.fs(r["y"]),"d":hz.fs(r["d"]),"w":hz.fs(r["w"]),"x0":hz.fs(r["x0"])})
got=node(cmds)
print("value parity (s,a,y,d,w,x0), python Fraction vs JS BigInt:",sum(g==e for g,e in zip(got,exp)),"/",len(exp))
# 2. verdict parity on texts, incl. lexical edge forms
def pyv(t):
    try: return hz.check(json.loads(t))
    except Exception: return "INVALID"
texts=[]
for _ in range(400):
    q=rnd.randrange(4); x="%d.%d"%(rnd.randrange(-400,400),rnd.randrange(0,10**rnd.randrange(1,5))); h=rnd.choice(["0","0.1","0.5","0.3"]); k=rnd.choice(["0","1","0.5"])
    rc=hz.make_receipt(q,x,h,k,"x"); texts.append(json.dumps(rc))
    s=rnd.randrange(137); y=hz.fs(F(rnd.randrange(0,137*20),20))
    rec={"s":s,"a":hz.addr(q,s),"y":y}
    if rec!=rc["recomputed"]:
        rc2=hz.make_receipt(q,x,h,k,"x",recorded=rec); texts.append(json.dumps(rc2)); rc2["delta"]=[]; texts.append(json.dumps(rc2))
base=json.dumps(hz.make_receipt(0,"1.5","0.1","1","x"),indent=1)
edge={"q 0.0":('"q": 0,','"q": 0.0,'),"q 0e0":('"q": 0,','"q": 0e0,'),"q -0":('"q": 0,','"q": -0,'),"q 00":('"q": 0,','"q": 00,'),"q +0":('"q": 0,','"q": +0,'),"s 2.0 recomputed":('"s": 2,','"s": 2.0,'),
      "label tab":('"label": "x"','"label": "x\\t"'),"extra ws":('"q": 0,','"q":   0 ,')}
etexts=[]
for k,(a,b) in edge.items():
    assert a in base,k; etexts.append(base.replace(a,b,1))
allt=texts+etexts
js=node([{"op":"check","text":t} for t in allt])
d=[(i,pyv(t),js[i]) for i,t in enumerate(allt) if pyv(t)!=js[i]]
print("verdict parity on",len(texts),"generated texts:", "diffs",[x for x in d if x[0]<len(texts)])
for i,(k,_) in enumerate(edge.items()):
    j=len(texts)+i; print("  edge",k,"-> py",pyv(allt[j]),"| js",js[j])

# regression: non-canonical fraction text for y
def mk(y_text):
    rc=hz.make_receipt(0,"0","0","0","x"); w=rc["recomputed"]
    rec={"s":0,"a":0,"y":y_text}; rc["recorded"]=rec; rc["delta"]=[{"recorded":dict(rec),"recomputed":dict(w)}]
    return json.dumps(rc)
bad=[mk(t) for t in ("-0/1","0/2","00/1","+0/1","0/-1","0")]
good=[mk("1/2")]
res=node([{"op":"check","text":t} for t in bad+good])
print("non-canonical recorded y (-0/1, 0/2, 00/1, +0/1, 0/-1, 0):",[ (pyv(t),r) for t,r in zip(bad,res)][:6])
print("canonical wrong y 1/2 with true delta:",pyv(good[0]),"|",res[-1])
