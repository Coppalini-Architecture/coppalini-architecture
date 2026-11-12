(function(){
  'use strict';
  const $=id=>document.getElementById(id),K=globalThis.NOPAudit,encoder=new TextEncoder(),decoder=new TextDecoder('utf-8',{fatal:true});
  const LIMIT=2*1024*1024,MAX_ROWS=5000,PAGE_SIZE=50;
  const sources={metadata:null,data:null},fileVersions={metadata:0,data:0};let active=null,generation=0,page=0;
  const labels={baseline_record:'Baseline record',return_candidate:'Return candidate',changed_read:'Changed oxygen read',returned_read_with_redox_difference:'Returned read · redox difference',exact_read_return_without_resolved_redox_difference:'Returned read · difference unresolved'};
  function invalidate(){generation++;active=null;$('results').hidden=true;$('error').hidden=true;}
  function error(message){$('error').textContent=message;$('error').hidden=false;$('status').textContent='Audit stopped. Correct the input and run again.';}
  for(const type of ['metadata','data']){
    $(type+'-text').addEventListener('input',()=>{fileVersions[type]++;if(sources[type])sources[type].dirty=true;invalidate();$(type+'-file-name').textContent='Edited text · hashes will describe these UTF-8 bytes';});
    $(type+'-file').addEventListener('change',async event=>{
      invalidate();const token=++fileVersions[type],file=event.target.files[0];if(!file)return;
      sources[type]=null;$(type+'-text').value='';$(type+'-file-name').textContent=`Reading ${file.name}…`;
      try{if(file.size>LIMIT)throw Error(`${file.name}: browser file limit is 2 MiB`);const bytes=new Uint8Array(await file.arrayBuffer());const text=decoder.decode(bytes);if(token!==fileVersions[type])return;$(type+'-text').value=text;sources[type]={bytes,text:$(type+'-text').value,rawText:text,name:file.name,dirty:false,source_kind:'selected_file'};$(type+'-file-name').textContent=`${file.name} · ${file.size.toLocaleString()} bytes`;}
      catch(e){if(token===fileVersions[type]){$(type+'-file-name').textContent='File rejected';error(e.message);}}
    });
  }
  function source(type){const text=$(type+'-text').value,previous=sources[type];if(previous&&!previous.dirty&&previous.text===text)return {...previous,text:previous.rawText??previous.text};return {text,bytes:encoder.encode(text),name:previous?`${previous.name} (edited UTF-8 text)`:type==='metadata'?'entered-metadata.json':'entered-data.csv',source_kind:'entered_or_edited_text'};}
  async function digest(bytes){if(!globalThis.crypto||!globalThis.crypto.subtle)return {status:'unavailable',sha256:null};try{const hash=await globalThis.crypto.subtle.digest('SHA-256',bytes);return {status:'computed_in_browser',sha256:Array.from(new Uint8Array(hash),b=>b.toString(16).padStart(2,'0')).join('')};}catch(e){return {status:'unavailable',sha256:null,reason:e.name||'WebCrypto failure'};}}
  const pretty=x=>JSON.stringify(x,null,2)+'\n';
  async function run(){
    invalidate();const token=generation;$('run').disabled=true;$('status').textContent='Validating identities, source order, and exact interval arithmetic…';
    try{
      const meta=source('metadata'),data=source('data');for(const input of [meta,data])if(input.bytes.length>LIMIT)throw Error(`${input.name}: browser file limit is 2 MiB`);
      if(K.parseCSV(data.text).slice(1).filter(x=>x.cells.length).length>MAX_ROWS)throw Error('Browser record limit is 5,000 data records. Use the Python edition for larger inputs.');
      const report=K.audit(meta.text,data.text);
      const [mh,dh]=await Promise.all([digest(meta.bytes),digest(data.bytes)]);if(token!==generation)return;
      report.provenance={metadata:{name:meta.name,source_kind:meta.source_kind,bytes:meta.bytes.length,...mh},data:{name:data.name,source_kind:data.source_kind,bytes:data.bytes.length,...dh},code:{edition:'browser',kernel:'NOPAudit',version:K.VERSION,status:'not_measured_in_browser',sha256:null}};
      const auditText=pretty(report),csvText=K.derivedCSV(report);
      const [ah,ch]=await Promise.all([digest(encoder.encode(auditText)),digest(encoder.encode(csvText))]);if(token!==generation)return;
      const receipt={schema_version:K.SCHEMA,tool_version:K.VERSION,edition:'browser',dataset_id:report.dataset_id,data_origin:report.data_origin,status:'validated_paired_data',counts:report.counts,provenance:report.provenance,outputs:{'audit.json':ah,'derived.csv':ch},scope:'Browser-kernel execution, input validation, exact arithmetic, and available byte hashes. This receipt does not execute or attest the Python kernel, verify assay validity, or establish a biological mechanism.'};
      active={report,auditText,csvText,receiptText:pretty(receipt)};page=0;render(report);$('status').textContent=`Audit complete: ${report.counts.rows} records in submitted order. ${report.data_origin==='synthetic'?'Synthetic example; no participant measurements.':'Origin declared measured by the input metadata.'}`;
      $('hash-status').textContent=mh.status==='computed_in_browser'&&dh.status==='computed_in_browser'?'Input SHA-256 computed locally. Browser kernel version recorded; kernel bytes were not independently hashed.':'SHA-256 unavailable in this browser context. The exported receipt records that status explicitly.';
    }catch(e){if(token===generation)error(e.message);}finally{$('run').disabled=false;}
  }
  $('audit-form').addEventListener('submit',event=>{event.preventDefault();run();});
  $('demo').addEventListener('click',()=>{
    for(const type of ['metadata','data']){fileVersions[type]++;const text=type==='metadata'?globalThis.NOP_DEMO.metadataText:globalThis.NOP_DEMO.csvText;$(type+'-text').value=text;sources[type]={text:$(type+'-text').value,rawText:text,bytes:encoder.encode(text),name:type==='metadata'?'synthetic-metadata.json':'synthetic.csv',dirty:false,source_kind:'embedded_synthetic_demo'};$(type+'-file-name').textContent='Embedded synthetic demo · no file download required';$(type+'-file').value='';}
    run();
  });
  function element(tag,text,className){const el=document.createElement(tag);if(text!==undefined)el.textContent=text;if(className)el.className=className;return el;}
  function render(report){
    $('results').hidden=false;$('dataset').textContent=report.dataset_id;$('origin').textContent=report.data_origin==='synthetic'?'Synthetic data':'Declared measured';
    $('summary').replaceChildren();for(const [label,n] of [['Records',report.counts.rows],['Runs',report.counts.runs],['Returned read + difference',report.counts.relationships.returned_read_with_redox_difference||0],['Return candidates',report.counts.relationships.return_candidate||0]]){const box=element('div');box.append(element('strong',String(n)),element('span',label));$('summary').append(box);}
    $('warnings-box').hidden=!report.warnings.length;$('warnings-title').textContent=`${report.warnings.length} recorded qualification${report.warnings.length===1?'':'s'}`;$('warnings').replaceChildren();for(const w of report.warnings)$('warnings').append(element('li',w.message));
    $('metadata-view').textContent=pretty(report.metadata);$('run-filter').replaceChildren(new Option('All runs',''));for(const id of new Set(report.rows.map(x=>x.run_id)))$('run-filter').add(new Option(id,id));renderRows();
  }
  function metricCell(metric){const td=element('td');td.append(element('code',metric.value));if(metric.low!==metric.high)td.append(element('small',`[${metric.low}, ${metric.high}]`));if(metric.status)td.append(element('small',metric.status.replaceAll('_',' ')));return td;}
  function renderRows(){
    if(!active)return;const selected=$('run-filter').value,rows=active.report.rows.filter(x=>!selected||x.run_id===selected),pages=Math.max(1,Math.ceil(rows.length/PAGE_SIZE));page=Math.min(page,pages-1);$('result-rows').replaceChildren();
    for(const row of rows.slice(page*PAGE_SIZE,(page+1)*PAGE_SIZE)){
      const tr=element('tr'),sample=element('td'),button=element('button',row.sample_id,'sample-button');button.type='button';button.setAttribute('aria-label',`Inspect exact record ${row.sample_id}`);button.addEventListener('click',()=>{$('row-title').textContent=row.sample_id;$('row-json').textContent=pretty(row);$('row-dialog').showModal();});sample.append(element('small',row.run_id),button);tr.append(sample);
      const occurrence=element('td');occurrence.append(element('code',row.occurrence),element('small',`${row.time_min} min`));tr.append(occurrence,metricCell(row.inputs.oxygen));for(const name of ['r','a','q','scale_squared'])tr.append(metricCell(row.derived[name]));const verdict=element('td',labels[row.relationship]||row.relationship,'verdict'+(row.relationship==='returned_read_with_redox_difference'?' difference':''));verdict.append(element('small',row.oxygen_comparison.replaceAll('_',' ')));tr.append(verdict);$('result-rows').append(tr);
    }
    $('page-info').textContent=`${rows.length? page*PAGE_SIZE+1:0}–${Math.min((page+1)*PAGE_SIZE,rows.length)} of ${rows.length}`;$('previous').disabled=page===0;$('next').disabled=page===pages-1;
  }
  $('run-filter').addEventListener('change',()=>{page=0;renderRows();});$('previous').addEventListener('click',()=>{page--;renderRows();});$('next').addEventListener('click',()=>{page++;renderRows();});$('close-dialog').addEventListener('click',()=>$('row-dialog').close());
  function download(name,text,type){const url=URL.createObjectURL(new Blob([text],{type})),a=document.createElement('a');a.href=url;a.download=name;document.body.append(a);a.click();a.remove();setTimeout(()=>URL.revokeObjectURL(url),1000);}
  $('export-audit').addEventListener('click',()=>{if(active)download('audit.json',active.auditText,'application/json');});$('export-csv').addEventListener('click',()=>{if(active)download('derived.csv',active.csvText,'text/csv');});$('export-receipt').addEventListener('click',()=>{if(active)download('receipts.json',active.receiptText,'application/json');});
}());
