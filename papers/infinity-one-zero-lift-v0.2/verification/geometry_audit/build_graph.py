from pathlib import Path
from fractions import Fraction
from copy import deepcopy
import json,hashlib,xml.etree.ElementTree as ET,shutil,re,html
import cairosvg
O=Path(__file__).resolve().parent; B=O/'references'; W=O
ref=O/'references';ref.mkdir(exist_ok=True)
files=['mirror-recognition(2).svg','complete-operator-algebra(2).svg','the-exact-reader(2).svg','four-phase-eight-state(2).svg','independent-tunability(2).svg']
for f in files:
 if (B/f).resolve() != (ref/f).resolve(): shutil.copy2(B/f,ref/f)
ns={'s':'http://www.w3.org/2000/svg'}
SVG='http://www.w3.org/2000/svg';ET.register_namespace('',SVG)
# Extract and freeze the shared publication frame, with original coordinate scale.
r=ET.parse(ref/files[2]).getroot()
outer=next(x for x in r if x.tag==f'{{{SVG}}}g')
first41=[deepcopy(x) for x in list(outer)[:41]]
assert len(first41)==41 and sum(x.tag==f'{{{SVG}}}circle' for x in first41)==2
# All four thin-arc examples share these exact 41 geometric elements.
for name in files[1:]:
 rr=ET.parse(ref/name).getroot();gg=rr.find('s:g',ns)
 assert [ET.tostring(x) for x in list(gg)[:41]] == [ET.tostring(x) for x in first41], name
# Across five references, all primary frame coordinates, background and footer match.
measured=[]
for name in files:
 rr=ET.parse(ref/name).getroot();gg=rr.find('s:g',ns);foot=list(rr)[-1]
 eq=rr.find('s:svg',ns)
 assert rr.attrib['viewBox']=='0 0 800 1050'
 assert rr.find('s:rect',ns).attrib['fill']=='#faf8f3'
 assert gg[0].attrib=={'cx':'400','cy':'560','r':'202'}
 assert gg[1].attrib=={'cx':'400','cy':'560','r':'185','opacity':'.5'}
 assert abs(float(eq.attrib['x'])+float(eq.attrib['width'])/2-400)<1e-6
 assert abs(float(eq.attrib['y'])+float(eq.attrib['height'])/2-836)<1e-6
 assert foot.attrib=={'fill':'#777065','font-family':'Arial, Helvetica, sans-serif','text-anchor':'middle'}
 assert foot[0].attrib=={'x':'400','y':'932','font-size':'11','letter-spacing':'2.2'}
 assert foot[1].attrib=={'x':'400','y':'956','font-size':'9','letter-spacing':'1.7'}
 measured.append({'file':name,'sha256':hashlib.sha256((ref/name).read_bytes()).hexdigest()})
# Template is a production source artifact only; it is not a new proposed cover.
template=ET.Element(f'{{{SVG}}}svg',{'width':'800','height':'1050','viewBox':'0 0 800 1050'})
ET.SubElement(template,f'{{{SVG}}}title').text='Coppalini measured publication frame — content slots unfilled'
template.append(deepcopy(r.find('s:rect',ns)))
for el in [r.find('s:text',ns)]:
 el=deepcopy(el);el.text='TITLE';template.append(el)
frame=ET.SubElement(template,f'{{{SVG}}}g',outer.attrib)
for el in first41:frame.append(el)
ET.SubElement(template,f'{{{SVG}}}g',{'id':'verified-diagram','data-center':'400,560','data-max-content-radius':'169'})
ET.SubElement(template,f'{{{SVG}}}g',{'id':'equation','data-center':'400,836'})
template.append(deepcopy(list(r)[-1]))
ET.ElementTree(template).write(O/'COPPALINI_COVER_FRAME.svg',encoding='utf-8',xml_declaration=True)
lock={'title':'Coppalini published-cover reference lock','authority':'Five original published SVGs supplied by the user, not generated proposals','source_files':measured,'canvas':{'width':800,'height':1050,'viewBox':'0 0 800 1050'},'background':'#faf8f3','title':{'x':400,'baseline_y':143,'font_family':'Georgia, Times New Roman, serif','font_size':42,'fill':'#262522','anchor':'middle'},'subtitle_variant':{'source':'independent-tunability(2).svg','baseline_y':191,'font_size':18,'opacity':0.65},'second_title_line_variant':{'baseline_y':192,'font_size':[37,42]},'diagram':{'center':[400,560],'outer_radius':202,'inner_radius':185,'stroke':'#b38d4e','stroke_width':1,'ticks':28,'cardinal_extensions':4,'standard_band_radius':175,'standard_band_width':6,'band_opacity':0.7,'band_order_clockwise_from_top':['#a4bfae','#a2b4cd','#a6a4c5','#b9a8bf','#d8a6a3','#e1bc9b','#d9d09e'],'mirror_recognition_variant':'seven filled annular sectors, radius121 to169, subdivided into four slots'},'equation_center':[400,836],'footer':{'font_family':'Arial, Helvetica, sans-serif','fill':'#777065','author':{'x':400,'y':932,'font_size':11,'letter_spacing':2.2},'imprint':{'x':400,'y':956,'font_size':9,'letter_spacing':1.7}},'constraints':['Use one centered, source-addressed diagram.','Preserve the spacious single-column hierarchy.','Use source-derived incidence and labeled maps.','A drawing crossing does not create a node.','A display radius, projection or angle is a declared layout convention, unless source-defined.','Keep the seven-band palette and source matching assignments when representing the reader.','Generated dark poster, R-series masthead, ring emblem, equation sidebar, extra seam slogan and topic list are not part of these five reference covers.'],'project':{'title':'Infinity One Zero Lift','subtitle':'The Normal Form of Projective Memory','private_record_boundary':'End at the first R²; later private codex content is excluded.'},'checks':{'all_five_shared_frame_constants':'PASS','four_thin_arc_frames_exact_element_match':'PASS','all_five_equation_centers':[400,836]}}
(O/'COPPALINI_COVER_STYLE_LOCK.json').write_text(json.dumps(lock,indent=2))
# Graph derived only from the verified data; one line element per unordered pair.
data=json.loads((O/'graph_coordinates.json').read_text())
pal=lock['diagram']['band_order_clockwise_from_top']
parts=['<svg xmlns="http://www.w3.org/2000/svg" width="1040" height="760" viewBox="0 0 1040 760">',
'<title>Linear Infinity to the twenty-eight-seam reader — exact incidence audit</title>',
'<desc>Eight different occurrence addresses from two four-phase cycles. All 28 unordered edges appear once, colored by the seven source matchings. Positions are a declared rational projection of the phase-and-lift display, not a physical metric. Crossings do not create vertices.</desc>',
'<rect width="1040" height="760" fill="#faf8f3"/>']
def text(x,y,s,size=18,fill='#262522',anchor='middle',**kw):
 extra=' '.join(f'{k.replace("_","-")}="{v}"' for k,v in kw.items())
 return f'<text x="{x}" y="{y}" font-family="DejaVu Serif, serif" font-size="{size}" fill="{fill}" text-anchor="{anchor}" {extra}>{html.escape(s)}</text>'
parts.append(text(520,48,'Linear Infinity → eight occurrences → 28 seams',28))
parts.append(text(225,89,'F⁴(p, z) = (p, Lₐₓz)',18, '#4d4940'))
parts.append(text(545,89,'Λ(Lₐₓz) = Λ(z) + T',18, '#4d4940'))
parts.append(text(860,89,'n = 4c + p',18, '#4d4940'))
parts.append(text(520,121,'Technical incidence drawing · all 28 pairs · source color assignment preserved',14,'#777065'))
coords=[]
for v in data['vertices']:
 a,b=(float(Fraction(x)) for x in v['projection'])
 coords.append((520+150*(a-1.4),365-150*(b-0.3)))
parts.append('<g id="all-28-edges" fill="none" stroke-linecap="butt">')
for e in data['edges']:
 a,b=e['i'],e['j'];x1,y1=coords[a];x2,y2=coords[b]
 parts.append(f'<line id="edge-{a}-{b}" data-pair="{a},{b}" data-matching="{e["matching_a"]}" data-slot="{e["slot_b"]}" data-q="{e["scan_q"]}" x1="{x1:.8f}" y1="{y1:.8f}" x2="{x2:.8f}" y2="{y2:.8f}" stroke="{pal[e["matching_a"]]}" stroke-width="1.65"/>')
parts.append('</g><g id="eight-occurrences">')
# Offsets point away from each cycle's center, keeping node identity clear.
off=[(21,-4),(0,-23),(-23,4),(0,31)]
for i,(x,y) in enumerate(coords):
 parts.append(f'<circle id="occurrence-{i}" cx="{x:.8f}" cy="{y:.8f}" r="6" fill="#faf8f3" stroke="#b38d4e" stroke-width="1.3"/>')
 dx,dy=off[i%4];parts.append(text(x+dx,y+dy,str(i),17))
parts.append('</g>')
parts.append(text(290,612,'cycle c: 0, 1, 2, 3',18))
parts.append(text(745,612,'cycle c + 1: 4, 5, 6, 7',18))
parts.append(text(520,647,'6 within the first cycle  +  16 between cycles  +  6 within the next cycle  =  28',19))
# Legend only; each band counts exactly four edges.
for a,col in enumerate(pal):
 x=290+a*76;parts.append(f'<line x1="{x-17}" y1="684" x2="{x+3}" y2="684" stroke="{col}" stroke-width="4"/>');parts.append(text(x+17,690,str(a),14))
parts.append(text(520,721,'Seven matchings × four edges. Projection and spacing are display choices; crossings are not vertices.',14,'#777065'))
parts.append('</svg>');svg='\n'.join(parts)
(O/'linear_infinity_28_seam_graph.svg').write_text(svg)
t=ET.fromstring(svg);lines=t.findall('.//s:line[@data-pair]',ns);vs=t.findall('.//s:circle',ns)
assert len(lines)==28 and len(vs)==8
assert len({p.attrib['data-pair'] for p in lines})==28
assert all(sum(l.attrib['data-matching']==str(a) for l in lines)==4 for a in range(7))
cairosvg.svg2png(bytestring=svg.encode(),write_to=str(O/'linear_infinity_28_seam_graph.png'),output_width=1560)
cairosvg.svg2pdf(bytestring=svg.encode(),write_to=str(O/'linear_infinity_28_seam_graph.pdf'))
# A compact interactive audit reader, same fixed coordinates and geometry.
options='<option value="all">All 28 edges</option>'+''.join(f'<option value="{a}">Matching {a}: four edges</option>' for a in range(7))
ht=f'''<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Infinity One Zero Lift — incidence audit</title><style>body{{max-width:1040px;margin:20px auto;padding:0 16px;background:#faf8f3;color:#262522;font:16px Georgia,serif}}svg{{width:100%;height:auto}}select,input{{font:inherit}}label{{margin-right:18px}}#receipt{{min-height:30px}}.controls{{display:flex;flex-wrap:wrap;gap:12px;align-items:center;padding:16px 0}}details{{margin:20px 0;line-height:1.5}}code{{font-size:14px}}</style><div class="controls"><label>Reader <select id="matching">{options}</select></label><label>Scan q <input type="range" id="scan" min="0" max="27" step="1" value="0"></label><button id="all">Restore all</button></div><div id="receipt">28 unordered seams; every occurrence has degree seven.</div>{svg}<details><summary>Exact coordinate and source contract</summary><p>Occurrence i=4ℓ+p, ℓ∈{{0,1}}, p∈{{0,1,2,3}}. The declared spatial display is (cos(πp/2),sin(πp/2),ℓ). The drawing applies the rational projection [[1,1/5,14/5],[1/7,1,3/5]]. Pixel spacing carries no physical metric.</p><p>For matching construction only, address 7 is relabeled ∞; addresses 0–6 retain their labels. This is the assignment used by the supplied published Four-Phase Addressing SVG. Scan q uses (a,b)=(q mod7,q mod4). Occurrence index n and scan coordinate q retain separate roles.</p><p>Sources: Linear Infinity, canonical 0.1, pp.2–3; Mirror Escapement Time Lift, §V; Language Mechanics 011 v0.2, §§1–7. The exact edge set and source palette assignments are checked by the accompanying Python verifier.</p></details><script>const edges=[...document.querySelectorAll('line[data-pair]')];const label=document.getElementById('receipt');function reset(){{edges.forEach(e=>{{e.style.opacity=1;e.style.strokeWidth='1.65'}});document.getElementById('matching').value='all';label.textContent='28 unordered seams; every occurrence has degree seven.'}}document.getElementById('all').onclick=reset;document.getElementById('matching').onchange=e=>{{let a=e.target.value;edges.forEach(x=>x.style.opacity=a==='all'||x.dataset.matching===a?1:.06);label.textContent=a==='all'?'All 28 unordered seams.':'Matching '+a+': '+edges.filter(x=>x.dataset.matching===a).map(x=>'{{'+x.dataset.pair+'}}').join('  ')}};document.getElementById('scan').oninput=e=>{{let q=e.target.value;edges.forEach(x=>{{x.style.opacity=x.dataset.q===q?1:.06;x.style.strokeWidth=x.dataset.q===q?'3':'1.65'}});let selected=edges.find(x=>x.dataset.q===q);label.textContent='q='+q+' → matching '+selected.dataset.matching+', slot '+selected.dataset.slot+' → edge {{'+selected.dataset.pair+'}}.'}};</script></html>'''
(O/'incidence_reader.html').write_text(ht)
# Additional machine-verifiable render/template receipts, separate from mathematical checks.
(O/'render_receipt.json').write_text(json.dumps({'published_reference_frames_checked':5,'identical_thin_arc_element_prefixes':4,'frame_elements_per_standard_prefix':41,'equation_center':[400,836],'rendered_graph_edge_elements':28,'rendered_graph_vertex_elements':8,'rendered_graph_matching_sizes':[4]*7,'computed_matrix_drawn_without_manual_vertex_edits':True,'new_cover_emitted':False},indent=2))
print('PASS five frame references; PASS exact 28-edge graph; wrote SVG/PNG/PDF and interactive incidence reader.')
