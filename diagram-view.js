(()=>{
  'use strict';
  const stage=document.getElementById('diagram-stage'),art=document.getElementById('diagram-art');if(!stage||!art)return;
  const out=document.getElementById('diagram-scale'),minus=document.getElementById('diagram-out'),plus=document.getElementById('diagram-in');let zoom=1;
  function render(fit=false){
    const x=(stage.scrollLeft+stage.clientWidth/2)/Math.max(stage.scrollWidth,1),y=(stage.scrollTop+stage.clientHeight/2)/Math.max(stage.scrollHeight,1);
    const width=art.naturalWidth||800,height=art.naturalHeight||1050,base=Math.min((stage.clientWidth-32)/width,(stage.clientHeight-32)/height);
    art.style.width=Math.max(1,width*base*zoom)+'px';art.style.height='auto';art.style.maxWidth='none';art.style.maxHeight='none';
    out.textContent=zoom===1?'Fit':Math.round(zoom*100)+'%';minus.disabled=zoom<=.5;plus.disabled=zoom>=4;
    stage.scrollTo({left:fit?0:x*stage.scrollWidth-stage.clientWidth/2,top:fit?0:y*stage.scrollHeight-stage.clientHeight/2,behavior:'instant'});
  }
  function change(delta){zoom=Math.max(.5,Math.min(4,Math.round((zoom+delta)*4)/4));render()}
  minus.addEventListener('click',()=>change(-.25));plus.addEventListener('click',()=>change(.25));
  document.getElementById('diagram-fit').addEventListener('click',()=>{zoom=1;render(true)});
  stage.addEventListener('keydown',e=>{if(e.key==='+'||e.key==='='){e.preventDefault();change(.25)}else if(e.key==='-'){e.preventDefault();change(-.25)}else if(e.key==='0'){e.preventDefault();zoom=1;render(true)}});
  art.addEventListener('load',()=>render(true));new ResizeObserver(()=>render()).observe(stage);render(true);
})();
