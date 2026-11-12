/* NOP browser arithmetic kernel 0.2.0. No network, DOM, or storage access. */
(function (root, factory) {
  if (typeof module === 'object' && module.exports) module.exports = factory();
  else root.NOPAudit = factory();
}(typeof globalThis !== 'undefined' ? globalThis : this, function () {
  'use strict';
  const VERSION = '0.2.0', SCHEMA = '0.1';
  const COLUMNS = ['run_id','arm','sample_id','occurrence','time_min','is_baseline','fio2','pressure_kpa','oxygen','oxygen_low','oxygen_high','ros','ros_low','ros_high','scavenger','scavenger_low','scavenger_high','endpoint','endpoint_low','endpoint_high'];
  const METRICS = ['r','a','q','scale_squared','endpoint_normalized'];
  const fail = message => { throw new Error(message); };
  const abs = x => x < 0n ? -x : x;
  function gcd(a,b) { a=abs(a); b=abs(b); while(b) [a,b]=[b,a%b]; return a; }
  class Q {
    constructor(n,d=1n) { if(d===0n) fail('zero denominator'); if(d<0n){n=-n;d=-d;} const g=gcd(n,d); this.n=n/g; this.d=d/g; }
    mul(b){return new Q(this.n*b.n,this.d*b.d);}
    div(b){return new Q(this.n*b.d,this.d*b.n);}
    cmp(b){const x=this.n*b.d-b.n*this.d;return x<0n?-1:x>0n?1:0;}
    eq(b){return this.n===b.n&&this.d===b.d;}
    toString(){return this.d===1n?String(this.n):`${this.n}/${this.d}`;}
  }
  const ZERO=new Q(0n), ONE=new Q(1n);
  function fraction(raw,loc='value') {
    if(typeof raw!=='string'||!raw.trim()) fail(`${loc}: a numeric value is required`);
    const s=raw.trim();
    if(s.length>4096) fail(`${loc}: browser resource limit is 4096 characters per numeric field`);
    try {
      const r=s.match(/^([+-]?[0-9]+)\s*\/\s*([+-]?[0-9]+)$/);
      if(r) return new Q(BigInt(r[1]),BigInt(r[2]));
      if(!/^[+-]?(?:[0-9]+(?:\.[0-9]*)?|\.[0-9]+)(?:[eE][+-]?[0-9]+)?$/.test(s)) throw Error('syntax');
      const parts=s.toLowerCase().split('e'), exponent=parts.length===2?Number(parts[1]):0;
      if(!Number.isSafeInteger(exponent)||Math.abs(exponent)>10000) fail(`${loc}: browser resource limit is an exponent magnitude of 10000`);
      let decimal=parts[0],sign=1n;
      if(decimal[0]==='-'||decimal[0]==='+'){if(decimal[0]==='-')sign=-1n;decimal=decimal.slice(1);}
      const point=decimal.indexOf('.'), digitsAfter=point<0?0:decimal.length-point-1;
      const n=sign*BigInt(decimal.replace('.','')), power=exponent-digitsAfter;
      return power>=0?new Q(n*10n**BigInt(power)):new Q(n,10n**BigInt(-power));
    } catch(e) {
      if(e.message.includes('browser resource limit')) throw e;
      fail(`${loc}: invalid finite decimal/rational value ${JSON.stringify(s)}`);
    }
  }
  // JSON.parse alone silently replaces duplicate keys. This parser retains the
  // Python admission rule, including duplicates inside nested metadata objects.
  function parseMetadata(text) {
    text=text.replace(/^\uFEFF/,''); let i=0;
    const ws=()=>{while(/[\x20\t\r\n]/.test(text[i]||'!'))i++;};
    function str(){const start=i++;let escape=false;for(;i<text.length;i++){const c=text[i];if(!escape&&c==='"'){i++;return JSON.parse(text.slice(start,i));}if(!escape&&c==='\\')escape=true;else escape=false;}fail('metadata: unterminated JSON string');}
    function value(){
      ws(); const c=text[i];
      if(c==='"') return str();
      if(c==='{') {i++;const obj=Object.create(null),seen=new Set();ws();if(text[i]==='}'){i++;return obj;}while(true){ws();if(text[i]!=='"')fail('metadata: expected JSON object key');const k=str();if(seen.has(k))fail(`metadata: duplicate JSON key ${JSON.stringify(k)}`);seen.add(k);ws();if(text[i++]!==':')fail('metadata: expected colon');obj[k]=value();ws();const sep=text[i++];if(sep==='}')return obj;if(sep!==',')fail('metadata: expected object separator');}}
      if(c==='['){i++;const a=[];ws();if(text[i]===']'){i++;return a;}while(true){a.push(value());ws();const sep=text[i++];if(sep===']')return a;if(sep!==',')fail('metadata: expected array separator');}}
      const match=text.slice(i).match(/^(?:true|false|null|-?(?:0|[1-9][0-9]*)(?:\.[0-9]+)?(?:[eE][+-]?[0-9]+)?)/);
      if(!match)fail('metadata: invalid JSON value');i+=match[0].length;const x=JSON.parse(match[0]);
      if(typeof x==='number'){
        if(!Number.isFinite(x))fail('metadata: nonfinite JSON number');
        if(Number.isInteger(x)&&!Number.isSafeInteger(x))fail('metadata: integer exceeds the browser safe range; encode exact parameters as quoted decimal/rational strings');
        if(x===0&&/[1-9]/.test(match[0].split(/[eE]/)[0]))fail('metadata: nonzero number underflows in the browser; encode it as a quoted decimal/rational string');
      }
      return x;
    }
    const result=value();ws();if(i!==text.length)fail('metadata: trailing JSON content');return result;
  }
  function parseCSV(text) {
    text=text.replace(/^\uFEFF/,'');const records=[];let row=[],field='',quoted=false,after=false,touched=false,line=1;
    const push=()=>{if(touched||row.length||field!==''){row.push(field);records.push({cells:row,line});}else records.push({cells:[],line});row=[];field='';touched=false;after=false;};
    for(let i=0;i<text.length;i++){
      const c=text[i],newline=c==='\n'||c==='\r',crlf=c==='\r'&&text[i+1]==='\n';
      if(quoted){if(c==='"'){if(text[i+1]==='"'){field+='"';i++;}else{quoted=false;after=true;}}else{field+=c;if(newline){if(crlf){field+='\n';i++;}line++;}}continue;}
      if(after&&c!==','&&!newline)fail(`data: CSV row ${line}: expected comma after closing quote`);
      if(c===',' ){row.push(field);field='';touched=true;after=false;}
      else if(newline){push();if(crlf)i++;line++;}
      else if(c==='"'&&field===''&&!after){quoted=true;touched=true;}
      else{field+=c;touched=true;}
    }
    if(quoted)fail(`data: CSV row ${line}: unterminated quoted field`);
    if(touched||row.length||field!==''||after)push();
    return records;
  }
  const isObject=x=>x!==null&&typeof x==='object'&&!Array.isArray(x);
  function required(obj,key,loc){if(typeof obj[key]!=='string'||!obj[key].trim())fail(`${loc}.${key}: a nonempty string is required`);return obj[key];}
  function descriptor(meta,key){if(!isObject(meta[key]))fail(`metadata.${key}: an object is required`);for(const f of ['unit','compartment','assay'])required(meta[key],f,`metadata.${key}`);return meta[key];}
  function validateMetadata(meta){
    if(!isObject(meta))fail('metadata: must be a JSON object');
    if(meta.schema_version!==SCHEMA)fail(`metadata.schema_version: expected '${SCHEMA}'`);
    required(meta,'dataset_id','metadata');
    if(meta.data_origin==='extracted_summary')fail('metadata.data_origin: extracted_summary cannot establish paired sample observations');
    if(!['synthetic','measured'].includes(meta.data_origin))fail('metadata.data_origin: expected synthetic, measured, or extracted_summary');
    if(!Array.isArray(meta.source_refs)||meta.source_refs.some(x=>typeof x!=='string'||!x.trim()))fail('metadata.source_refs: a list of nonempty source-reference strings is required');
    const oxygen=descriptor(meta,'oxygen_read');
    if(!['dry_inspired_po2','arterial_po2','tissue_po2'].includes(oxygen.kind))fail('metadata.oxygen_read.kind: unrecognized oxygen read');
    if(oxygen.unit!=='kPa')fail("metadata.oxygen_read.unit: expected 'kPa'");
    const ros=descriptor(meta,'ros'),scavenger=descriptor(meta,'scavenger');
    if(Object.prototype.hasOwnProperty.call(meta,'endpoint'))required(descriptor(meta,'endpoint'),'name','metadata.endpoint');
    const warnings=[];
    if(ros.compartment.trim()!==scavenger.compartment.trim())warnings.push({code:'cross_compartment_redox_composite',message:'r, a, q, and scale_squared combine the separately declared ROS and scavenger compartments; they carry no inferred compartment or molecular equivalence.',ros_compartment:ros.compartment,scavenger_compartment:scavenger.compartment});
    return warnings;
  }
  function measurement(row,name,loc,{required=true,computed=null,allowZero=false}={}){
    const text=row[name].trim(),lo=row[name+'_low'].trim(),hi=row[name+'_high'].trim();
    if(Boolean(lo)!==Boolean(hi))fail(`${loc}: ${name}_low and ${name}_high must both be present or both be empty`);
    let v;
    if(text){v=fraction(text,`${loc}.${name}`);if(computed!==null&&!v.eq(computed))fail(`${loc}.${name}: supplied ${v} differs from exact fio2 * pressure_kpa = ${computed}`);}
    else if(computed!==null)v=computed;
    else if(required)fail(`${loc}.${name}: a value is required`);
    else{if(lo)fail(`${loc}.${name}: uncertainty bounds require a value`);return null;}
    if(v.cmp(ZERO)<0||(!allowZero&&v.eq(ZERO)))fail(`${loc}.${name}: value must be ${allowZero?'nonnegative':'strictly positive'}`);
    let low=v,high=v,bounds_kind='point_as_entered';
    if(lo){low=fraction(lo,`${loc}.${name}_low`);high=fraction(hi,`${loc}.${name}_high`);if(low.cmp(ZERO)<0||(!allowZero&&low.eq(ZERO)))fail(`${loc}.${name}_low: bound must be ${allowZero?'nonnegative':'strictly positive'}`);if(low.cmp(v)>0||v.cmp(high)>0)fail(`${loc}.${name}: required low <= value <= high`);bounds_kind='recorded_interval';}
    return {value:v,low,high,bounds_kind};
  }
  const publicMeasurement=m=>m===null?null:{value:String(m.value),low:String(m.low),high:String(m.high),bounds_kind:m.bounds_kind};
  function metric(v,lo,hi,baseline=false){return {value:String(v),low:String(lo),high:String(hi),status:hi.cmp(ONE)<0?'below_baseline':lo.cmp(ONE)>0?'above_baseline':lo.eq(ONE)&&hi.eq(ONE)?'baseline_exact_as_entered':'unresolved_at_recorded_bounds',bounds_basis:baseline?'baseline_self_cancellation':'conservative_interval_arithmetic'};}
  const ratio=(cur,base,self)=>self?metric(ONE,ONE,ONE,true):metric(cur.value.div(base.value),cur.low.div(base.high),cur.high.div(base.low));
  function logInt(n){const s=String(n),prefix=s.slice(0,16);return Math.log(Number(prefix))+(s.length-prefix.length)*Math.LN10;}
  function eta(q){let x;if(q.cmp(new Q(1n,2n))>=0&&q.cmp(new Q(2n))<=0){const difference=q.n-q.d;if(difference===0n)return 0;const sign=difference<0n?-1:1;const delta=sign*Math.exp(logInt(abs(difference))-logInt(q.d));x=.5*Math.log1p(delta);}else x=.5*(logInt(q.n)-logInt(q.d));if(!Number.isFinite(x))fail('eta: approximate display could not be represented as a finite float');return x;}
  function derive(cur,base){
    const self=cur.is_baseline,m=cur.readings,b=base.readings,R=m.ros,A=m.scavenger,R0=b.ros,A0=b.scavenger;
    const r=ratio(R,R0,self),a=ratio(A,A0,self),qv=R.value.mul(A0.value).div(A.value.mul(R0.value));
    const q=self?metric(ONE,ONE,ONE,true):metric(qv,R.low.mul(A0.low).div(A.high.mul(R0.high)),R.high.mul(A0.high).div(A.low.mul(R0.low)));
    const scale=self?metric(ONE,ONE,ONE,true):metric(R.value.mul(A.value).div(R0.value.mul(A0.value)),R.low.mul(A.low).div(R0.high.mul(A0.high)),R.high.mul(A.high).div(R0.low.mul(A0.low)));
    const o=m.oxygen,o0=b.oxygen;
    const comparison=o.low.eq(o.high)&&o.low.eq(o0.low)&&o.low.eq(o0.high)?'exact_read_return':o.low.cmp(o0.high)<=0&&o0.low.cmp(o.high)<=0?'compatible_with_return':'changed_read';
    const difference=[r,a].some(x=>['above_baseline','below_baseline'].includes(x.status));
    const relationship=self?'baseline_record':comparison==='compatible_with_return'?'return_candidate':comparison==='changed_read'?'changed_read':difference?'returned_read_with_redox_difference':'exact_read_return_without_resolved_redox_difference';
    let endpoint=null;if(m.endpoint!==null){if(b.endpoint===null)fail(`${cur.location}.endpoint: run baseline ${base.sample_id} has no endpoint value`);endpoint=ratio(m.endpoint,b.endpoint,self);}
    return {source_row:cur.source_row,run_id:cur.run_id,arm:cur.arm,sample_id:cur.sample_id,occurrence:String(cur.occurrence),time_min:String(cur.time_min),is_baseline:self,baseline_sample_id:base.sample_id,inputs:{fio2:String(cur.fio2),pressure_kpa:String(cur.pressure_kpa),oxygen:publicMeasurement(o),ros:publicMeasurement(R),scavenger:publicMeasurement(A),endpoint:publicMeasurement(m.endpoint)},derived:{r,a,q,scale_squared:scale,endpoint_normalized:endpoint},eta:{approximate_float:eta(qv),display_only:true},oxygen_comparison:comparison,redox_difference_resolved:difference,relationship,extra_fields:cur.extra_fields};
  }
  function audit(metadata,csvText){
    const meta=typeof metadata==='string'?parseMetadata(metadata):metadata,warnings=validateMetadata(meta),records=parseCSV(csvText);
    if(!records.length||!records[0].cells.length)fail('data: CSV header is required');
    const headers=records.shift().cells;
    if(new Set(headers).size!==headers.length)fail('data: duplicate CSV column names');
    const missing=COLUMNS.filter(x=>!headers.includes(x));if(missing.length)fail(`data: missing CSV columns: ${missing.join(', ')}`);
    const extras=headers.filter(x=>!COLUMNS.includes(x));if(extras.some(x=>!x.trim()))fail('data: blank CSV column names are invalid');
    if(extras.length)warnings.push({code:'extra_csv_columns_preserved',columns:extras,message:"Additional columns are retained in each row's extra_fields and are not used for inference."});
    const runs=new Map(),rows=[],tied=[];
    for(const record of records){
      if(!record.cells.length)continue;
      const loc=`data: CSV row ${record.line}`;
      if(record.cells.length!==headers.length)fail(`${loc}: row has a different number of cells from the header`);
      const raw=Object.create(null);headers.forEach((key,i)=>raw[key]=record.cells[i]);
      for(const key of ['run_id','arm','sample_id'])if(!raw[key].trim())fail(`${loc}.${key}: a nonempty identifier is required`);
      const run_id=raw.run_id.trim(),arm=raw.arm.trim(),sample_id=raw.sample_id.trim(),occurrence=fraction(raw.occurrence,`${loc}.occurrence`),time_min=fraction(raw.time_min,`${loc}.time_min`);
      if(occurrence.d!==1n||occurrence.cmp(ZERO)<0)fail(`${loc}.occurrence: a nonnegative integer is required`);
      const bt=raw.is_baseline.trim().toLowerCase();if(!['0','1','false','true'].includes(bt))fail(`${loc}.is_baseline: expected 0, 1, false, or true`);
      const is_baseline=bt==='1'||bt==='true';let state=runs.get(run_id);
      if(!state){if(!is_baseline)fail(`${loc}.is_baseline: first submitted row for run must be its baseline`);}
      else{if(is_baseline)fail(`${loc}.is_baseline: run already has a baseline`);if(arm!==state.arm)fail(`${loc}.arm: a run must retain its declared arm`);if(state.samples.has(sample_id))fail(`${loc}.sample_id: duplicate sample_id within run`);if(occurrence.cmp(state.occurrence)<=0)fail(`${loc}.occurrence: occurrences must strictly increase in submitted order within a run`);if(time_min.cmp(state.time_min)<0)fail(`${loc}.time_min: clock readings must be nondecreasing in submitted order within a run`);if(time_min.eq(state.time_min))tied.push(record.line);}
      const fio2=fraction(raw.fio2,`${loc}.fio2`),pressure=fraction(raw.pressure_kpa,`${loc}.pressure_kpa`);
      if(fio2.cmp(ZERO)<0||fio2.cmp(ONE)>0)fail(`${loc}.fio2: fraction must lie in [0, 1]`);
      if(pressure.cmp(ZERO)<=0)fail(`${loc}.pressure_kpa: pressure must be strictly positive`);
      const dry=meta.oxygen_read.kind==='dry_inspired_po2',oxygen=measurement(raw,'oxygen',loc,{computed:dry?fio2.mul(pressure):null,allowZero:dry}),ros=measurement(raw,'ros',loc),scavenger=measurement(raw,'scavenger',loc),endpoint=measurement(raw,'endpoint',loc,{required:false});
      if(endpoint!==null&&!Object.prototype.hasOwnProperty.call(meta,'endpoint'))fail(`${loc}.endpoint: values require a metadata.endpoint measurement declaration`);
      const extra_fields=Object.create(null);for(const key of extras)extra_fields[key]=raw[key];
      const cur={source_row:record.line,location:loc,run_id,arm,sample_id,occurrence,time_min,is_baseline,fio2,pressure_kpa:pressure,readings:{oxygen,ros,scavenger,endpoint},extra_fields};
      if(!state){state={baseline:cur,arm,samples:new Set()};runs.set(run_id,state);}
      rows.push(derive(cur,state.baseline));state.samples.add(sample_id);state.occurrence=occurrence;state.time_min=time_min;
    }
    if(!rows.length)fail('data: at least one data row is required');
    if(tied.length)warnings.push({code:'tied_clock_readings_ordered_by_occurrence',source_rows:tied,message:'Distinct occurrences share a recorded clock reading; submitted occurrence order is retained. Ties may represent finite clock resolution or left/right jump events. No derivative is inferred from tied timestamps.'});
    if(rows.length===runs.size)warnings.push({code:'no_followup_rows',message:'The input contains baseline records only; there are no paired follow-up comparisons.'});
    const relationships={};for(const row of rows)relationships[row.relationship]=(relationships[row.relationship]||0)+1;
    return {schema_version:SCHEMA,tool_version:VERSION,edition:'browser',dataset_id:meta.dataset_id,data_origin:meta.data_origin,metadata:meta,counts:{rows:rows.length,runs:runs.size,baselines:runs.size,followup_rows:rows.length-runs.size,endpoint_rows:rows.filter(x=>x.inputs.endpoint!==null).length,tied_clock_rows:tied.length,warnings:warnings.length,relationships},warnings,interpretation:{row_order:'submitted order retained; runs may interleave; no sorting',baseline:'one first record per run; all ratios use that same run baseline',bounds:'Missing bounds denote a point as entered, not biological certainty. Propagated intervals are conservative; baseline self-ratios cancel exactly.',oxygen:'Comparisons concern the declared oxygen read, compartment, and assay. dry_inspired_po2 is the nominal dry-gas proxy fio2 * pressure_kpa.',scope:'Arithmetic paired-data audit. No inferred tissue, assay, HIF isoform, causal mechanism, or clinical equivalence; no fitted model or derivative from tied clock readings.',endpoint:'Optional endpoint normalization retains the single declared endpoint and the same run baseline; no causal attribution.',eta:'Approximate float display of 0.5 * log(q); exact classifications use rational bounds.'},rows};
  }
  function csvCell(value){const s=String(value??'');return /[",\r\n]/.test(s)?'"'+s.replace(/"/g,'""')+'"':s;}
  function derivedCSV(report){
    const cols=['source_row','run_id','arm','sample_id','occurrence','time_min','is_baseline','baseline_sample_id','fio2','pressure_kpa'];
    for(const n of ['oxygen','ros','scavenger','endpoint'])cols.push(n,n+'_low',n+'_high',n+'_bounds_kind');
    for(const n of METRICS)cols.push(n,n+'_low',n+'_high',n+'_status');
    cols.push('eta_approximate_display_only','oxygen_comparison','redox_difference_resolved','relationship','extra_fields_json');
    const records=[cols.map(csvCell).join(',')];
    for(const row of report.rows){const flat={...row,fio2:row.inputs.fio2,pressure_kpa:row.inputs.pressure_kpa,is_baseline:row.is_baseline?'1':'0',redox_difference_resolved:row.redox_difference_resolved?'1':'0',eta_approximate_display_only:row.eta.approximate_float,extra_fields_json:JSON.stringify(row.extra_fields)};
      for(const n of ['oxygen','ros','scavenger','endpoint']){const m=row.inputs[n];if(m){flat[n]=m.value;for(const k of ['low','high','bounds_kind'])flat[n+'_'+k]=m[k];}}
      for(const n of METRICS){const m=row.derived[n];if(m){flat[n]=m.value;for(const k of ['low','high','status'])flat[n+'_'+k]=m[k];}}
      records.push(cols.map(k=>csvCell(flat[k])).join(','));}
    return records.join('\n')+'\n';
  }
  return {VERSION,SCHEMA,COLUMNS,METRICS,Q,fraction,parseMetadata,parseCSV,audit,derivedCSV};
}));
