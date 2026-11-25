const m=require('../sources/relax_receipt.js');
const out=require('fs').readFileSync(0,'utf8').split('\n').filter(Boolean).map(l=>{const j=JSON.parse(l);
 if(j.op==='check')return m.checkText(j.text);
 const d=m.unfs(j.d);const r=m.step(j.q,j.s,d,j.k);return {r,rho:m.fs(m.rho(j.k)),kappa:m.fs(m.kappa(j.k))};});
console.log(JSON.stringify(out));
