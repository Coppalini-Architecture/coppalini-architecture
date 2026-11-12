#!/usr/bin/env python3
"""R58 checks: retain R57 and bind Suture Audit v0.3 into the public exact-reader surfaces."""
from pathlib import Path
import hashlib, json, subprocess, sys, zipfile
ROOT=Path(__file__).resolve().parents[1]

def h(p):
    x=hashlib.sha256()
    with open(p,'rb') as f:
        for b in iter(lambda:f.read(1048576),b''): x.update(b)
    return x.hexdigest()

def req(c,m):
    if not c: raise AssertionError(m)

r=subprocess.run([sys.executable,'-I','tools/verify_r57_discovery_finish.py'],cwd=ROOT,text=True,capture_output=True)
req(r.returncode==0 and 'R57 PASS' in r.stdout, r.stderr or r.stdout or 'R57 regression failed')
print('R57 BASELINE PASS')
zip_path=ROOT/'downloads/Suture_Audit_v0_3.zip'
req(h(zip_path)=='7f48d8a1e4bf515a400eb0953c8c7e67026e6e9e7d1b94d903e902179e5d7a3e','Suture v0.3 archive hash drifted')
req(h(ROOT/'papers/suture-field/05a_suture_field_dynamics.pdf')=='d6d7f4fcb983bec9f1fd8257e6614af3787809e250dab0da754d31b7ebecb0bf','Dynamics PDF hash drifted')
req(h(ROOT/'papers/suture-field/source/05a_suture_field_dynamics.tex')=='d2c7e21279a6aa938dd37de938ee9b5bff8c2852ded2b79339b0ff93229fdf6e','Dynamics source hash drifted')
req(h(ROOT/'research/suture-field/residual_ledger_v0_3.md')=='c2012aa79dd153b3863cffe1e9226a272929267bed917ecbf0d5d7071fb22f28','Residual ledger hash drifted')
with zipfile.ZipFile(zip_path) as z:
    req('Suture_Audit_v0_3/source/verify_suture_field_dynamics_v0_3.py' in z.namelist(),'active Dynamics verifier missing from archive')
    req(hashlib.sha256(z.read('Suture_Audit_v0_3/source/verify_suture_field_dynamics_v0_3.py')).hexdigest()=='ec8117911340965c1ac1c29944302b5bb523689534c685c323d629916c085114','active Dynamics verifier hash drifted')
reg=json.loads((ROOT/'research/public-claim-registry-v0.3.json').read_text())
rec=next(x for x in reg['artifacts'] if x['id']=='S-5/05a')
req(rec['sha256']=='7f48d8a1e4bf515a400eb0953c8c7e67026e6e9e7d1b94d903e902179e5d7a3e' and rec['artifact'].endswith('Suture_Audit_v0_3.zip'),'registry Suture record drifted')
man=json.loads((ROOT/'research/verification-manifest-v0.3.json').read_text())
req(man['claim_registry']['sha256']==h(ROOT/'research/public-claim-registry-v0.3.json'),'manifest registry hash mismatch')
req(man['reader_contract']['sha256']==h(ROOT/'research/reader-contract.json'),'manifest reader contract hash mismatch')
req(man['registry_index']['sha256']==h(ROOT/'research/registry-index.json'),'manifest registry-index hash mismatch')
for page in ('verify.html','library.html','llms-full.txt'):
    t=(ROOT/page).read_text()
    req('Suture_Audit_v0_3.zip' in t,f'{page} lacks current Suture artifact')
req('R-1 through R-3 are closed' in (ROOT/'verify.html').read_text() or 'closes R-1' in (ROOT/'verify.html').read_text(),'verify page lacks closure notice')
print('SUTURE V0.3 PASS  archive, PDF/source, ledger, registry and manifest bound')
print('R58 PASS')
