// ART-002 v7: single idle candidate; inherits v4 anatomy, no reference pixels.
const {AnimatedManta,PALETTE}=require('../master-v4/motion.js');
const V7=Object.freeze({...PALETTE,top:'#36ebff',middle:'#098cfb',deep:'#1022e8',edge:'#10117e',spot:'#0752c3'});
class RefinedIdleManta extends AnimatedManta {
 constructor(palette=V7){super(palette);}
 nearWing(lift){
  if(lift!==0)throw Error('v7 idle only');
  const p=this.p;
  return `<g id="near-wing"><path fill="url(#back)" stroke="${p.edge}" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" d="M57 107 C58 132 69 154 87 166 C95 172 102 175 106 165 C111 149 125 130 139 120 Q141 117 137 115"/><g fill="${p.spot}" opacity=".96"><ellipse cx="81" cy="124" rx="6.5" ry="2.8" transform="rotate(5 81 124)"/><ellipse cx="102" cy="140" rx="6.6" ry="2.8" transform="rotate(-5 102 140)"/><ellipse cx="107" cy="121" rx="5.1" ry="2.2"/></g></g>`;
 }
 face(expression){
  if(expression!=='idle')throw Error('v7 idle only');
  const p=this.p;
  return `<g id="face" stroke-linecap="round" stroke-linejoin="round"><path fill="url(#nose)" stroke="${p.edge}" stroke-width="2.3" d="M28 106 C18 105 12 110 12 116 C12 123 19 127 29 126 C38 125 43 120 43 116"/><path fill="#fffdf6" stroke="#10112d" stroke-width="2.1" d="M32 91 Q42 87 51 96 Q56 102 55 110 Q46 110 37 116 Q28 111 28 102 Q28 96 32 91Z"/><path fill="#080d22" d="M33 92 Q40 89 45 98 Q49 108 41 114 L37 115 Q29 111 29 102 Q29 96 33 92Z"/><ellipse cx="35.5" cy="98.3" rx="3.7" ry="4.1" fill="#fff"/><path d="M35 118 Q41 122 46 116" stroke="${p.edge}" stroke-width="2" fill="none"/></g>`;
 }
 single(index=0){if(index!==0)throw Error('v7 idle only');return super.single(0);}
 atlas(){throw Error('v7 idle only; do not use with old atlases/masks');}
}
module.exports={RefinedIdleManta,V7};
