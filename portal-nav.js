(() => {
  'use strict';
  const legacy=new Set(['reference','questions','construction','field','language','verification','sources','provenance']);
  const page=location.pathname.split('/').pop();
  if((page===''||page==='index.html')&&legacy.has(location.hash.slice(1))){
    location.replace('architecture.html'+location.hash);
  }
})();
