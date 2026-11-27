// Original trial-only renderer. Run: node build-blueberry.mjs
import {writeFileSync} from 'node:fs';
function build(){
 const pal={ink:"#243453",shadow:"#365985",mid:"#579ad1",light:"#86c7ec",glow:"#bce7f5",cream:"#fff0ca",belly:"#e4cfa4",pink:"#f2a3b4",eye:"#20263e",white:"#fffdf7"};
 const poses=[{lift:0,wing:0,mouth:0},{lift:1,wing:2,mouth:0},{lift:3,wing:5,mouth:1},{lift:4,wing:3,mouth:1},{lift:2,wing:-1,mouth:0},{lift:0,wing:0,mouth:0}];
 function geometry(p,style){
  const shapes=[];const y=p.lift,w=p.wing;const xy=(x,z)=>[x,z-y]; 
  function path(c,commands){let v=[],last=[0,0];for(const q of commands){if(q.length===2){last=q;v.push(xy(...q))}else if(q.length===6){const [x1,y1,x2,y2,x3,y3]=q;const [x0,y0]=last;for(let j=1;j<=14;j++){const t=j/14,u=1-t;v.push(xy(u*u*u*x0+3*u*u*t*x1+3*u*t*t*x2+t*t*t*x3,u*u*u*y0+3*u*u*t*y1+3*u*t*t*y2+t*t*t*y3))}last=[x3,y3]}}shapes.push({c,p:v})}
  function ell(c,x,z,rx,ry){shapes.push({c,p:Array.from({length:32},(_,i)=>xy(x+rx*Math.cos(i*Math.PI/16),z+ry*Math.sin(i*Math.PI/16)))})}
  // Tail is a closed tapered ribbon, not a detachable line.
  path("ink",[[55,48],[64,48,70,53,75,61],[81,70,87,65,88,57],[89,72,80,78,72,67],[66,59,60,56,54,57]]);
  path("shadow",[[58,51],[65,52,71,57,76,64],[82,71,86,66,87,63],[83,74,77,72,72,65],[65,58,60,55,57,55]]);
  // Far wing, floppy soft tip behind the head.
  path("ink",[[36,37],[42,24-w/2,55,13-w,69,15-w],[73,15-w,70,26-w,63,33],[59,40,57,42,52,45],[44,44,39,40,36,37]]);
  path("shadow",[[39,36],[48,23-w/2,58,17-w,67,17-w],[68,22-w,64,29-w/2,59,34],[54,39,48,41,43,39]]);
  path("mid",[[44,33],[52,24-w/2,61,20-w,65,19-w],[63,25-w,58,30,53,34],[49,37,46,37,44,33]]);
  // Rounded body with soft projecting snoot and gentle cephalic lobe.
  path("ink",[[12,41],[11,35,15,31,21,34],[24,29,33,27,42,30],[54,30,64,37,66,45],[70,55,60,64,47,65],[36,67,27,62,21,56],[15,57,9,53,8,48],[7,44,9,42,12,41]]);
  path("cream",[[11,46],[13,42,19,44,24,48],[34,47,46,50,61,45],[66,53,57,61,47,62],[36,64,27,59,22,53],[16,55,10,51,11,46]]);
  path("belly",[[23,53],[34,59,47,60,57,53],[54,61,45,63,37,60],[31,59,25,56,23,53]]);
  path("mid",[[13,40],[12,35,16,34,21,36],[26,31,32,29,42,32],[52,32,62,39,63,46],[56,51,47,54,38,52],[28,51,22,48,18,47],[13,48,10,45,13,40]]);
  path("light",[[23,37],[30,32,42,32,49,36],[53,38,51,40,46,40],[38,36,30,39,24,42],[20,43,19,39,23,37]]);
  // Near wing folds below body; the tip moves but stays clear of the tail.
  path("ink",[[41,45],[48,43,56,47,61,53],[56,61,46,69+w,31,74+w],[25,76+w,23,73+w,27,66+w],[29,58,35,50,41,45]]);
  path("shadow",[[42,48],[48,46,54,49,58,53],[51,61,43,68+w,31,72+w],[27,74+w,28,70+w,30,66+w],[33,57,37,51,42,48]]);
  path("mid",[[43,49],[48,48,53,50,55,53],[49,59,43,64+w,34,67+w],[32,68+w,31,67+w,33,62+w/2],[35,55,39,52,43,49]]);
  path("light",[[37,57],[41,53,45,51,49,52],[45,57,39,62+w,35,63+w],[34,62+w,35,59,37,57]]);
  // Cream wing edge reinforces the belly without making the fin disconnected.
  path("cream",[[30,68+w],[35,69+w,44,65+w,50,60+w/2],[44,66+w,36,72+w,30,73+w],[28,73+w,28,71+w,30,68+w]]);
  ell("pink",23,49,4.3,2.2);
  ell("ink",29,41,7.8,9);
  ell("eye",29,41.3,6,7.2);
  ell("light",30,45.2,3.7,2.4);
  ell("white",26.9,38.1,2.6,2.6);
  if(style==="cartoon")ell("white",32.2,43.3,1.15,1.15);
  if(p.mouth){ell("ink",14.8,48,3.5,3);ell("pink",15.0,49.3,1.7,1.1)}
  else path("ink",[[12,47],[15,49,18,49,20,46],[19,50,14,51,12,47]]);
  if(style==="cartoon"){
   path("glow",[[35,34],[39,33,44,34,46,36],[41,35,38,36,35,36],[33,36,33,35,35,34]]);
   ell("light",54,41,2.1,1.3);ell("light",57,43,1.2,0.9);
  }else{ell("glow",40,35,2,1);ell("light",55,41,2,1.4)}
  return shapes.map(s=>({c:pal[s.c],p:s.p}));
 }
 function rgba(hex){return [parseInt(hex.slice(1,3),16),parseInt(hex.slice(3,5),16),parseInt(hex.slice(5,7),16),255]}
 function contains(poly,x,y){let on=false;for(let i=0,j=poly.length-1;i<poly.length;j=i++){const a=poly[i],b=poly[j];if((a[1]>y)!==(b[1]>y)&&x<(b[0]-a[0])*(y-a[1])/(b[1]-a[1])+a[0])on=!on}return on}
 function render(p,n,style){const ss=style==="pixel"?1:3,N=n*ss,hi=new Uint8Array(N*N*4),factor=N/96;for(const sh of geometry(p,style)){const pts=sh.p.map(([x,y])=>[x*factor,y*factor]),color=rgba(sh.c),xs=pts.map(p=>p[0]),ys=pts.map(p=>p[1]);const a=Math.max(0,Math.floor(Math.min(...xs))),b=Math.min(N-1,Math.ceil(Math.max(...xs))),c=Math.max(0,Math.floor(Math.min(...ys))),d=Math.min(N-1,Math.ceil(Math.max(...ys)));for(let y=c;y<=d;y++)for(let x=a;x<=b;x++)if(contains(pts,x+.5,y+.5))hi.set(color,(y*N+x)*4)}
 if(ss===1)return hi;const lo=new Uint8Array(n*n*4);for(let y=0;y<n;y++)for(let x=0;x<n;x++){let a=0,r=0,g=0,b=0;for(let j=0;j<ss;j++)for(let i=0;i<ss;i++){const k=((y*ss+j)*N+x*ss+i)*4;if(hi[k+3]){a++;r+=hi[k];g+=hi[k+1];b+=hi[k+2]}}if(a)lo.set([Math.round(r/a),Math.round(g/a),Math.round(b/a),Math.round(a*255/(ss*ss))],(y*n+x)*4)}return lo}
 const frames={pixel:poses.map(p=>render(p,48,"pixel")),cartoon:poses.map(p=>render(p,96,"cartoon"))};
 function assert(v,m){if(!v)throw Error(m)}
 const checks={};for(const [style,fs] of Object.entries(frames)){const n=style==="pixel"?48:96;checks[style]=fs.map((f,i)=>{let minX=n,minY=n,maxX=-1,maxY=-1,partial=0,opaque=0;for(let y=0;y<n;y++)for(let x=0;x<n;x++){const a=f[(y*n+x)*4+3];if(a){minX=Math.min(minX,x);minY=Math.min(minY,y);maxX=Math.max(maxX,x);maxY=Math.max(maxY,y);if(a===255)opaque++;else partial++}}assert(minX>=3&&minY>=3&&maxX<=n-4&&maxY<=n-4,style+" padding "+i);assert(opaque>0,style+" opaque");if(style==="pixel")assert(partial===0,"pixel partial alpha");else assert(partial>0,"cartoon no antialias");return{frame:i,bounds:[minX,minY,maxX,maxY],opaque,partial}});assert(fs[0].every((v,i)=>v===fs[5][i]),style+" returns to idle")}
 function u32(n){return [(n>>>24)&255,(n>>>16)&255,(n>>>8)&255,n&255]}
 function bytes(s){return Array.from(s,c=>c.charCodeAt(0))}
 function crc(a){let c=~0;for(const x of a){c^=x;for(let i=0;i<8;i++)c=c&1?(c>>>1)^0xedb88320:c>>>1}return (~c)>>>0}
 // Fixed Huffman DEFLATE with a simple backward-match dictionary.
 function deflate(a){const o=[0x78,0x01];let buf=0,bits=0;function put(x,n){buf|=x<<bits;bits+=n;while(bits>=8){o.push(buf&255);buf>>>=8;bits-=8}}function rev(x,n){let z=0;while(n--){z=z*2+(x&1);x>>>=1}return z}
 function lit(x){if(x<=143)put(rev(x+48,8),8);else if(x<=255)put(rev(x-144+400,9),9);else if(x<=279)put(rev(x-256,7),7);else put(rev(x-280+192,8),8)}
 const LB=[3,4,5,6,7,8,9,10,11,13,15,17,19,23,27,31,35,43,51,59,67,83,99,115,131,163,195,227,258],LE=[0,0,0,0,0,0,0,0,1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,4,5,5,5,5,0],DB=[1,2,3,4,5,7,9,13,17,25,33,49,65,97,129,193,257,385,513,769,1025,1537,2049,3073,4097,6145,8193,12289,16385,24577],DE=[0,0,0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13];
 function match(l,d){let i=LB.length-1;while(LB[i]>l)i--;lit(257+i);put(l-LB[i],LE[i]);let j=DB.length-1;while(DB[j]>d)j--;put(rev(j,5),5);put(d-DB[j],DE[j])}
 put(1,1);put(1,2);const map=new Map();const key=i=>(a[i]<<16)|(a[i+1]<<8)|a[i+2];let i=0;while(i<a.length){let l=0,d=0;if(i+2<a.length){const k=key(i),p=map.get(k);if(p!==undefined&&i-p<=32768){d=i-p;while(l<258&&i+l<a.length&&a[p+l]===a[i+l])l++}if(l<3)l=0}if(l){match(l,d);for(let j=0;j<l&&i+j+2<a.length;j++)map.set(key(i+j),i+j);i+=l}else{if(i+2<a.length)map.set(key(i),i);lit(a[i]);i++}}lit(256);if(bits)o.push(buf&255);let s1=1,s2=0;for(const x of a){s1=(s1+x)%65521;s2=(s2+s1)%65521}return [...o,...u32(((s2<<16)|s1)>>>0)]}
 function png(w,h,rgba){const a=new Uint8Array(h*(w*4+1));for(let y=0;y<h;y++)a.set(rgba.subarray(y*w*4,(y+1)*w*4),y*(w*4+1)+1);function chunk(t,v){const c=[...bytes(t),...v];return [...u32(v.length),...c,...u32(crc(c))]}return new Uint8Array([137,80,78,71,13,10,26,10,...chunk("IHDR",[...u32(w),...u32(h),8,6,0,0,0]),...chunk("IDAT",deflate(a)),...chunk("IEND",[])])}
 function strip(fs,n){const a=new Uint8Array(n*n*4*fs.length);for(let y=0;y<n;y++)for(let i=0;i<fs.length;i++)a.set(fs[i].subarray(y*n*4,(y+1)*n*4),(y*n*fs.length+i*n)*4);return png(n*fs.length,n,a)}
 function composite(){const W=576,H=240,a=new Uint8Array(W*H*4);for(let y=0;y<H;y++)for(let x=0;x<W;x++){const color=y<120?((Math.floor(x/12)+Math.floor(y/12))%2?[75,128,144,255]:[81,139,153,255]):((Math.floor(x/12)+Math.floor(y/12))%2?[99,114,153,255]:[107,122,160,255]);a.set(color,(y*W+x)*4)}
 for(const [row,style] of ["pixel","cartoon"].entries()){const n=style==="pixel"?48:96;for(let i=0;i<6;i++)for(let y=0;y<96;y++)for(let x=0;x<96;x++){const k=(Math.floor(y*n/96)*n+Math.floor(x*n/96))*4,f=frames[style][i],j=((row*120+12+y)*W+i*96+x)*4,alpha=f[k+3]/255;for(let c=0;c<3;c++)a[j+c]=Math.round(f[k+c]*alpha+a[j+c]*(1-alpha))}}
 return png(W,H,a)}
 return{files:{"blueberry-pixel.png":strip(frames.pixel,48),"blueberry-cartoon.png":strip(frames.cartoon,96),"frame-review.png":composite()},checks,palette:pal,poses};
}
const out=build();
for(const [name,data] of Object.entries(out.files))writeFileSync(new URL(name,import.meta.url),data);
console.log(JSON.stringify({checks:out.checks,palette:out.palette,poses:out.poses},null,2));
