import importlib.util, random
from fractions import Fraction as F
spec=importlib.util.spec_from_file_location("hz","/home/claude/harm/harmonizer.py"); hz=importlib.util.module_from_spec(spec); spec.loader.exec_module(hz)
S=137; half=F(1,2); rnd=random.Random(99)
def ref(q,x,h,kp):
    """independent path: brute-force nearest sector on the ring, signed ring offset, (1-w)*offset"""
    x0=x-S*(x//S)
    def off(t):
        o=(x0-t)%S
        return o-S if o>F(S,2) else o
    best=min(abs(off(t)) for t in range(S))
    cands=[t for t in range(S) if abs(off(t))==best]
    assert len(cands)<=2
    if len(cands)==2:
        lo=[t for t in cands if off(t)==half][0]; s=(lo+1)%S
    else: s=cands[0]
    d=off(s); m=abs(d)
    if m<=h: w=kp
    else:
        u=(half-m)/(half-h); w=kp*(3*u**2-2*u**3)
    y=(s+(1-w)*d)%S
    return s,y
n=0
for _ in range(1500):
    q=rnd.randrange(4)
    x=F(rnd.randrange(-10**5,10**5),rnd.choice([1,2,3,4,7,10,64,1000]))
    if rnd.random()<0.3: x=F(rnd.randrange(-300,300))+half
    h=F(rnd.randrange(0,501),1000); kp=F(rnd.randrange(0,1001),1000)
    s,y=ref(q,x,h,kp); r=hz.H(q,x,h,kp)
    assert (s,y)==(r["s"],r["y"]) and r["a"]==s+S*((q-s)%4); n+=1
print("independent path (argmin over 137 sectors, signed ring offset) agrees:",n,"cases incl. ties")
N2=lambda a:(a+274)%548; NC=lambda a:(a+274*(a%2))%548
for _ in range(2000):
    q=rnd.randrange(4); x=F(rnd.randrange(0,137*1000),1000); h=F(rnd.randrange(0,501),1000); kp=F(rnd.randrange(0,1001),1000)
    a=hz.H(q,x,h,kp)["a"]
    assert N2(a)==hz.H((q+2)%4,x,h,kp)["a"] and NC(a)==hz.H((-q)%4,x,h,kp)["a"]
print("a-output commutes with N2 and N_c (q -> q+2, q -> -q): 2000 cases")
for k in range(S):
    assert hz.H(0,F(2*k+1,2),F(1,10),F(1))["s"]==(k+1)%S
print("tie rule: every half-integer goes to the larger sector: 137/137")
for h,kp in [(F(0),F(1)),(F(1,10),F(1)),(F(2,5),F(3,4)),(F(49,100),F(1)),(F(1,3),F(1,5))]:
    for k in (0,5,136):
        t=F(2*k+1,2)
        for e in (F(1,10**3),F(1,10**5),F(1,10**7)):
            L=hz.H(0,t-e,h,kp); R=hz.H(0,t+e,h,kp)
            yl=(t-e)-L["w"]*L["d"]; yr=(t+e)-R["w"]*R["d"]
            gap=yr-yl
            assert abs(gap-2*e)<=10*e*e*kp/(half-h)**2, (h,kp,k,e,float(gap-2*e))
print("h < 1/2: y continuous and C^1 across ties (slope 1, gap = 2e + O(e^2)): 5 (h,kappa) x 3 ties x 3 e")
for kp in (F(1),F(3,4),F(1,10)):
    t=F(1,2); e=F(1,10**9)
    L=hz.H(0,t-e,half,kp); R=hz.H(0,t+e,half,kp)
    yl=(t-e)-L["w"]*L["d"]; yr=(t+e)-R["w"]*R["d"]
    assert abs((yr-yl)-(2*e+kp))<=4*e
print("h = 1/2: jump across a tie equals kappa (1, 3/4, 1/10)")
c=0
for _ in range(1000):
    h=F(rnd.randrange(1,501),1000); kp=F(rnd.randrange(0,1001),1000); d=F(rnd.randrange(-1000,1001),1000)*h
    x=F(rnd.randrange(1,136))+d
    r=hz.H(0,x,h,kp); assert r["w"]==kp and r["y"]==(x-kp*d)%S; c+=1
print("plateau |d|<=h: w = kappa, y = x0 - kappa*d:",c,"cases")
# mean slope across the shoulder span [s+h, s+1-h]: exactly (1 - 2(1-kappa)h)/(1 - 2h) >= 1; = 1/(1-2h) at kappa = 1
c=0
for _ in range(400):
    h=F(rnd.randrange(0,500),1000); kp=F(rnd.randrange(0,1001),1000); s=rnd.randrange(0,136)
    yu=lambda x:(lambda r:x-r["w"]*r["d"])(hz.H(0,x,h,kp))
    a,b=F(s)+h,F(s+1)-h
    M=(yu(b)-yu(a))/(b-a)
    assert M==(1-2*(1-kp)*h)/(1-2*h) and M>=1
    if kp==1: assert M==1/(1-2*h)
    N=200; best=max((yu(a+(b-a)*(i+1)/N)-yu(a+(b-a)*i/N))/((b-a)/N) for i in range(N))
    assert best>=M; c+=1
print("shoulder-span mean slope = (1 - 2(1-kappa)h)/(1 - 2h), >= 1, = 1/(1-2h) at kappa = 1; a finite-difference slope >= it:",c,"cases")
