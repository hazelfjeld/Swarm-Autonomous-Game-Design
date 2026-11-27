// Derived only from original v4/v5 SVG paint attributes; geometry and layering unchanged.
const RGB=Object.freeze({dorsal:'#ff0000',marks:'#00ff00',belly:'#0000ff',protected:'#000000'});
const FIXED=new Set(['#fff','#fffdf6','white','#c3efff','#0b1236','#351b4e','#f4a0b3','#101338','#3c70bf','#d6b76c','#111584']);
class CosmeticMask {
  static fromAtlas(svg){
    const gradients={back:RGB.dorsal,wing:RGB.dorsal,nose:RGB.dorsal,bellyFill:RGB.belly,iris:RGB.protected};
    if(!/^<svg\b/.test(svg)||/<(?:image|use|style|script)\b|\bhref=/.test(svg))throw Error('unexpected SVG structure');
    const result=svg.replace(/(<(?:radialGradient|linearGradient)\b[^>]*\bid="([^"]+)"[^>]*>)([\s\S]*?)(<\/(?:radialGradient|linearGradient)>)/g,(_,open,id,body,close)=>{
      const c=gradients[id.slice(id.lastIndexOf('-')+1)];if(!c)throw Error('unknown gradient '+id);
      return open+body.replace(/stop-color="[^"]+"/g,'stop-color="'+c+'"')+close;
    }).replace(/\b(fill|stroke)="([^"]+)"/g,(_,attr,value)=>{
      if(value==='none'||/^url\(#[\w-]+\)$/.test(value))return attr+'="'+value+'"';
      let c=RGB.protected;
      if(attr==='fill'&&value==='#0755c1')c=RGB.marks;
      else if(attr==='fill'&&value==='#1528e5')c=RGB.dorsal;
      else if(!FIXED.has(value))throw Error('unknown paint '+value);
      return attr+'="'+c+'"';
    });
    return result;
  }
}
if(require.main===module){const fs=require('node:fs'),[input,output]=process.argv.slice(2);if(!input||!output||input===output)throw Error('node mask.js source.svg new-mask.svg');fs.writeFileSync(output,CosmeticMask.fromAtlas(fs.readFileSync(input,'utf8')));}
module.exports={CosmeticMask,RGB};
