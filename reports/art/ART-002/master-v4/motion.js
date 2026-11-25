// ART-002 v4: reference-guided expression and motion; v3 remains intact.
// Original vector geometry; no external image data. Node CommonJS.
const {MantaAnatomy,BLUEBERRY}=require('../master-v3/manta.js');
const PALETTE=Object.freeze({...BLUEBERRY,top:'#27def5',middle:'#1298f5',deep:'#1528e5',edge:'#111584',spot:'#0755c1'});
const FRAMES=Object.freeze([
 {wing:0,bob:0,expression:'idle'},
 {wing:-3,bob:-1,expression:'idle'},
 {wing:-7,bob:-3,expression:'bite'},
 {wing:-11,bob:-5,expression:'bite'},
 {wing:-8,bob:-4,expression:'happy'},
 {wing:-4,bob:-2,expression:'happy'},
 {wing:1,bob:1,expression:'idle'},
 {wing:0,bob:0,expression:'idle'}
].map(Object.freeze));
class AnimatedManta extends MantaAnatomy {
 constructor(palette=PALETTE){super(palette);}
 defs(){return super.defs().replace('cx="89" cy="93" r="112"','cx="93" cy="92" r="100"').replace('offset=".42"','offset=".38"');}
 nearWing(lift){
  const p=this.p, y=lift;
  return `<g id="near-wing"><path fill="url(#back)" stroke="${p.edge}" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" d="M63 111 C64 135 73 ${153+y/2} 90 ${166+y} C99 ${173+y} 105 ${175+y} 109 ${164+y} C116 ${146+y/3} 127 128 137 122 Q141 118 137 116"/><g fill="${p.spot}" opacity=".94"><ellipse cx="89" cy="${125+y*.2}" rx="6.5" ry="2.8" transform="rotate(6 89 ${125+y*.2})"/><ellipse cx="109" cy="${138+y*.55}" rx="6.1" ry="2.6" transform="rotate(-8 109 ${138+y*.55})"/><ellipse cx="111" cy="${121+y*.15}" rx="4.8" ry="2.1"/></g></g>`;
 }
 face(expression){
  const p=this.p;
  const eye=expression==='happy'? `<path d="M31 104 Q41 92 51 104" fill="none" stroke="#101338" stroke-width="2.7"/><path d="M33 100 Q41 95 49 100" fill="none" stroke="#3c70bf" stroke-width="1.1" opacity=".65"/>` : `<path fill="#fffdf6" stroke="${p.edge}" stroke-width="1.9" d="M33 93 Q43 89 51 97 Q55 102 55 109 Q46 109 38 116 Q30 111 30 103 Q30 97 33 93Z"/><path fill="url(#iris)" d="M34 94 Q40 91 44 98 Q48 107 42 113 L38 115 Q31 111 31 103 Q31 97 34 94Z"/><ellipse cx="35.5" cy="99.3" rx="3" ry="3.6" fill="#fff"/><circle cx="42" cy="109" r="1.1" fill="#c3efff"/><path d="M32 94 Q42 89 50 96" stroke="#0b1236" stroke-width="1.5" fill="none"/>`;
  const mouth=expression==='bite'? `<path d="M34 118 Q42 114 48 119 Q46 126 40 125 Q36 124 34 118Z" fill="#351b4e" stroke="${p.edge}" stroke-width="1.6"/><path d="M39 123 Q43 120 45 123" stroke="#f4a0b3" stroke-width="1.4" fill="none"/>` : `<path d="M34 119 Q40 123 46 117" stroke="${p.edge}" stroke-width="1.8" fill="none"/>`;
  return `<g id="face" stroke-linecap="round" stroke-linejoin="round"><path fill="url(#nose)" stroke="${p.edge}" stroke-width="2.3" d="M28 106 C18 105 12 110 12 116 C12 123 19 127 29 126 C38 125 43 120 43 116"/><path fill="${p.deep}" opacity=".55" d="M34 88 Q43 83 51 90 Q54 94 55 99 Q47 91 34 88"/>${eye}${mouth}</g>`;
 }
 renderFrame(index,prefix='f'+index){
  if(!Number.isInteger(index)||index<0||index>=FRAMES.length)throw Error('bad frame');
  const s=FRAMES[index];
  // Stable body, tail, far wing, dorsal spots and facial anchors. Only bounded pose deltas.
  const body=this.defs()+`<g transform="translate(0 ${s.bob})" id="manta">${this.belly()}${this.body()}${this.farWing()}${this.markings()}${this.nearWing(s.wing)}${this.face(s.expression)}</g>`;
  return body.replace(/id="([^"]+)"/g,(_,id)=>'id="'+prefix+'-'+id+'"').replace(/url\(#([^)]*)\)/g,(_,id)=>'url(#'+prefix+'-'+id+')');
 }
 single(index){return '<svg xmlns="http://www.w3.org/2000/svg" width="256" height="256" viewBox="0 0 256 256">'+this.renderFrame(index,'sprite')+'</svg>\n';}
 atlas(){return '<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="512" viewBox="0 0 1024 512">'+FRAMES.map((_,i)=>'<g transform="translate('+((i%4)*256)+' '+(Math.floor(i/4)*256)+')">'+this.renderFrame(i)+'</g>').join('')+'</svg>\n';}
}
module.exports={AnimatedManta,PALETTE,FRAMES};
