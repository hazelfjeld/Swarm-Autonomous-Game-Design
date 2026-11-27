// ART-002: one Blueberry, five directional keys. Original geometry; no reference pixels.
const {AnimatedManta}=require('../master-v4/motion.js');
const mix=(a,b,t)=>Math.round((a+(b-a)*t)*10)/10;
class TurningManta extends AnimatedManta {
  projected(t,prefix){
    if(t!==0&&t!==1)throw Error('front or quarter only');
    const p=this.p,x=(a,b)=>mix(a,b,t),head=x(128,79),s=x(128,64);
    const back=`M${x(84,43)} 116 C${x(76,36)} 97 ${x(91,48)} 79 ${x(111,66)} 79 Q${head} 72 ${x(145,94)} 79 C${x(163,115)} 79 ${x(178,143)} 98 ${x(172,157)} 117 C${x(162,139)} 133 ${x(145,117)} 139 ${x(130,94)} 136 Q${x(96,53)} 140 ${x(84,43)} 116Z`;
    const far=`M${x(112,70)} 100 C${x(76,50)} 94 ${x(38,27)} 113 ${x(16,21)} 145 Q${x(9,15)} 160 ${x(24,28)} 160 C${x(65,53)} 153 ${x(94,79)} 132 ${x(121,96)} 117Z`;
    const near=`M${x(146,93)} 103 C${x(180,126)} 94 ${x(213,164)} 112 ${x(239,157)} ${x(145,150)} Q${x(247,153)} ${x(160,171)} ${x(232,139)} ${x(160,171)} C${x(194,116)} ${x(153,164)} ${x(165,108)} 134 ${x(145,96)} 122Z`;
    const tail=t===1?'M135 104 C162 104 202 104 241 115 Q248 118 241 120 C198 111 169 113 137 119Z':'M139 109 C151 93 178 78 192 60 Q198 55 193 65 C180 84 156 99 144 119Z';
    const belly=`M${x(85,46)} 115 Q${head} 104 ${x(170,136)} 115 Q${x(164,131)} 143 ${x(153,119)} 151 Q${head} 158 ${x(103,59)} 145 Q${x(87,43)} 135 ${x(85,46)} 115Z`;
    const stroke=`stroke="${p.edge}" stroke-width="2.3" stroke-linecap="round" stroke-linejoin="round"`;
    const shape=(d,fill)=>`<path d="${d}" fill="url(#${fill})" ${stroke}/>`;
    const eye=(cx,cy,k)=>`<g transform="translate(${cx} ${cy}) scale(${k})"><path d="M-10 -9 Q-2 -16 7 -10 Q13 -5 12 7 Q5 9 -3 14 Q-13 8 -12 -2 Q-12 -6 -10 -9Z" fill="#fffdf6" stroke="${p.edge}" stroke-width="1.9"/><path d="M-8 -9 Q-3 -14 3 -7 Q8 3 2 10 L-3 13 Q-11 8 -11 -1 Q-11 -6 -8 -9Z" fill="url(#iris)"/><ellipse cx="-6" cy="-5" rx="3" ry="3.6" fill="white"/><circle cx="1" cy="7" r="1.1" fill="#c3efff"/></g>`;
    const spots=[[x(96,104),94,5,2.4],[x(112,123),86,6,2.3],[x(147,139),92,5.7,2.5],[x(161,145),102,4.7,2.1],[x(174,121),115,5.5,2.5],[x(193,137),130,6,2.6],[x(214,143),141,4.8,2.1],[x(62,38),130,5,2.3]].map(([cx,cy,rx,ry])=>`<ellipse cx="${cx}" cy="${cy}" rx="${rx}" ry="${ry}" fill="${p.spot}" opacity=".94"/>`).join('');
    const face=eye(head-18,105,x(1,.68))+eye(head+18,105,1)+`<path d="M${s-10} 115 C${s-24} 115 ${s-24} 128 ${s-15} 132 C${s-8} 136 ${s+9} 135 ${s+15} 131 Q${s+23} 123 ${s+12} 117 Q${s+6} 113 ${s-10} 115Z" fill="url(#nose)" ${stroke}/><path d="M${s+x(-9,3)} 137 Q${s+x(0,12)} 143 ${s+x(9,20)} 134" fill="none" stroke="${p.edge}" stroke-width="1.8" stroke-linecap="round"/>`;
    const defs=this.defs().replace('cx="93" cy="92" r="100"',`cx="${head-10}" cy="89" r="115"`).replace('</defs>',`<clipPath id="spotClip"><path d="${far}"/><path d="${back}"/><path d="${near}"/></clipPath></defs>`);
    return (defs+shape(tail,'back')+shape(far,'back')+`<path d="${belly}" fill="url(#bellyFill)" stroke="${p.bellyShade}" stroke-width="1.8"/>`+shape(back,'back')+shape(near,'back')+`<g clip-path="url(#spotClip)">${spots}</g>`+face).replace(/id="([^"]+)"/g,(_,id)=>'id="'+prefix+'-'+id+'"').replace(/url\(#([^)]*)\)/g,(_,id)=>'url(#'+prefix+'-'+id+')');
  }
  cell(i){
    if(!Number.isInteger(i)||i<0||i>4)throw Error('bad direction');
    const data=i===0||i===4?this.renderFrame(0,'turn'+i):this.projected(i===2?0:1,'turn'+i);
    return i>=3?'<g transform="translate(256 0) scale(-1 1)">'+data+'</g>':data;
  }
  single(i){return '<svg xmlns="http://www.w3.org/2000/svg" width="256" height="256" viewBox="0 0 256 256">'+this.cell(i)+'</svg>\n';}
  atlas(){return '<svg xmlns="http://www.w3.org/2000/svg" width="1280" height="256" viewBox="0 0 1280 256">'+[0,1,2,3,4].map(i=>'<g transform="translate('+i*256+' 0)">'+this.cell(i)+'</g>').join('')+'</svg>\n';}
}
module.exports={TurningManta};
