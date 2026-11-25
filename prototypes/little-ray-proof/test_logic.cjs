const fs=require('fs'),vm=require('vm'),assert=require('assert');
const src=fs.readFileSync(__dirname+'/index.html','utf8').match(/<script>([\s\S]*?)<\/script>/)[1];
let current=1700000000000;const memory=new Map();
function start(){const elems={};function el(id){return elems[id]??(elems[id]={innerHTML:'',textContent:'',dataset:{},addEventListener(){},onclick:null,classList:{toggle(){}}})}
const win={},timers=[];class TestDate extends Date{static now(){return current}}
const context={Date:TestDate,document:{querySelector:el,querySelectorAll:()=>[]},window:win,localStorage:{getItem:k=>memory.get(k)??null,setItem:(k,v)=>memory.set(k,v)},setInterval:fn=>{timers.push(fn);return timers.length},structuredClone,console,Math,JSON,confirm:()=>true};vm.runInNewContext(src,context);return{debug:win.LittleRayDebug,tick:()=>timers.forEach(fn=>fn())}}
const {debug,tick}=start();const stat=()=>debug.getState();const advance=n=>{current+=n*1000;tick()};
assert.equal(stat().rays.length,2);
advance(3);const bank=Math.floor(stat().storedGold);assert.ok(bank>0);debug.action('collect');assert.equal(stat().gold,1200+bank);assert.equal(stat().goals.collect,true);
const g0=stat().gold;debug.action('plant',0);assert.equal(stat().gold,g0-40);advance(12.5);debug.action('harvest',0);assert.equal(stat().food,305);assert.equal(stat().crops[0],null);
for(const id of [1,2]){debug.action('feed',id);debug.action('feed',id)}assert.equal(stat().rays[0].lv,4);assert.equal(stat().rays[1].lv,4);
debug.action('breed');assert.ok(stat().breed);const g=stat().gold;debug.action('breed');assert.equal(stat().gold,g);
advance(19);debug.action('transfer');assert.equal(stat().breed,null);assert.ok(stat().hatch);
advance(15);debug.action('claim');assert.equal(stat().rays.length,3);assert.equal(stat().rays[2].kind,'pearlcloud');debug.action('claim');assert.equal(stat().rays.length,3);
debug.action('startBattle');for(let x=0;x<15&&!stat().battle.finished;x++)debug.action('special');assert.equal(stat().battle.finished,true);assert.equal(stat().battle.won,true);let gold=stat().gold;debug.action('special');assert.equal(stat().gold,gold);
debug.action('endBattle');debug.action('expand');assert.equal(stat().land,5);
const recovered=start();assert.equal(recovered.debug.getState().rays.length,3);assert.equal(recovered.debug.getState().land,5);
console.log(JSON.stringify({pass:true,checks:['two founders','resident gold bank','plant and harvest','feeding and level gate','breeding idempotence','separate egg transfer','hatch claim idempotence','3v3 victory','battle settlement idempotence','land expansion','save/reload persistence'],gold:stat().gold,rays:stat().rays.length,land:stat().land},null,2));
