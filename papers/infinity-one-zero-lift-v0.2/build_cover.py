"""Fill the measured Coppalini SVG frame from the checked incidence ledger."""
from pathlib import Path
from fractions import Fraction
import json, io, copy, xml.etree.ElementTree as ET
import cairosvg
import matplotlib
matplotlib.use('Agg')
from matplotlib import mathtext, font_manager

ROOT=Path(__file__).resolve().parent
A=ROOT/'verification/geometry_audit'
SVG='http://www.w3.org/2000/svg'; ET.register_namespace('',SVG)
root=ET.parse(A/'COPPALINI_COVER_FRAME.svg').getroot()
ns={'s':SVG}
root.find('s:title',ns).text='Infinity One Zero Lift — The Normal Form of Projective Memory'
desc=ET.SubElement(root,f'{{{SVG}}}desc')
desc.text=('Eight occurrence vertices and exactly 28 pair comparisons from the checked phase/lift projection. '
           'Seven colors are the source perfect matchings. Crossings are not vertices. '
           'The source-defined projection and complete edge ledger are supplied with the paper.')
title=root.find('s:text',ns); title.text='Infinity One Zero Lift'
ET.SubElement(root,f'{{{SVG}}}text',{'x':'400','y':'191','fill':'#262522','font-family':'Georgia, Times New Roman, serif','text-anchor':'middle','font-size':'18','opacity':'.65'}).text='The Normal Form of Projective Memory'
data=json.loads((A/'graph_coordinates.json').read_text())
lock=json.loads((A/'COPPALINI_COVER_STYLE_LOCK.json').read_text())
colors=lock['diagram']['band_order_clockwise_from_top']
g=root.find("s:g[@id='verified-diagram']",ns)
coords=[]
for v in data['vertices']:
 x,y=map(Fraction,v['projection']);coords.append((400+55*(float(x)-1.4),560-55*(float(y)-.3)))
for e in data['edges']:
 i,j=e['i'],e['j'];a,b=coords[i],coords[j]
 ET.SubElement(g,f'{{{SVG}}}line',{'x1':f'{a[0]:.9f}','y1':f'{a[1]:.9f}','x2':f'{b[0]:.9f}','y2':f'{b[1]:.9f}','stroke':colors[e['matching_a']],'stroke-width':'1','opacity':'.83','data-pair':f'{i},{j}','data-matching':str(e['matching_a'])})
off=[(10,-4),(0,-11),(-11,4),(0,16)]
for i,(x,y) in enumerate(coords):
 ET.SubElement(g,f'{{{SVG}}}circle',{'cx':f'{x:.9f}','cy':f'{y:.9f}','r':'3.2','fill':'#faf8f3','stroke':'#b38d4e','stroke-width':'1','data-occurrence':str(i)})
 dx,dy=off[i%4]
 ET.SubElement(g,f'{{{SVG}}}text',{'x':f'{x+dx:.9f}','y':f'{y+dy:.9f}','font-family':'Georgia, Times New Roman, serif','font-size':'11','text-anchor':'middle','fill':'#262522'}).text=str(i)
# Equation is rendered as vector glyph paths; source meaning is in title metadata.
buf=io.BytesIO()
mathtext.math_to_image(r'$M:\ \infty\longleftrightarrow 1,\quad 0\longleftrightarrow0,\quad M^2=I$',buf,prop=font_manager.FontProperties(size=22,math_fontfamily='stix'),format='svg',color='#4d4940')
eq=ET.fromstring(buf.getvalue())
for parent in eq.iter():
 for child in list(parent):
  if child.attrib.get('id')=='patch_1': parent.remove(child)
vb=list(map(float,eq.attrib['viewBox'].split()))
width=vb[2]*1.18;height=vb[3]*1.18
eq.attrib.update({'x':str(400-width/2),'y':str(836-height/2),'width':str(width),'height':str(height)})
root.find("s:g[@id='equation']",ns).append(eq)
path=ROOT/'assets/cover.svg'; ET.ElementTree(root).write(path,encoding='utf-8',xml_declaration=True)
assert len(g.findall('s:line',ns))==28
assert len(g.findall('s:circle',ns))==8
cairosvg.svg2pdf(url=str(path),write_to=str(ROOT/'assets/cover.pdf'))
cairosvg.svg2png(url=str(path),write_to=str(ROOT/'assets/cover.png'),output_width=1200)
# Make a text-free vector inset from the same exact coordinates for the body.
inset=ET.Element(f'{{{SVG}}}svg',{'width':'660','height':'410','viewBox':'0 0 660 410'})
ng=copy.deepcopy(g);ng.attrib={'transform':'translate(-470,-915) scale(2)'}
# Easier, direct normalization of coordinates into body frame.
ng.attrib={'transform':'translate(-470,-915) scale(2)'}
inset.append(ng)
ET.ElementTree(inset).write(ROOT/'assets/incidence.svg',encoding='utf-8',xml_declaration=True)
cairosvg.svg2pdf(url=str(ROOT/'assets/incidence.svg'),write_to=str(ROOT/'assets/incidence.pdf'))
print('PASS: measured frame, eight vertices, 28 source-colored edges; vector cover generated.')
