const m=require('./harmonizer.js');
const lines=require('fs').readFileSync(0,'utf8').split('\n').filter(Boolean);
const out=lines.map(l=>{const j=JSON.parse(l);
 if(j.op==='check')return m.checkText(j.text);
 const r=m.H(j.q,m.dec(j.x),m.dec(j.h),m.dec(j.k));return {s:r.s,a:r.a,y:m.fs(r.y),d:m.fs(r.d),w:m.fs(r.w),x0:m.fs(r.x0)};});
console.log(JSON.stringify(out));
