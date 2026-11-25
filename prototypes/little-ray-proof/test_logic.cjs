const fs=require('fs'),vm=require('vm'),assert=require('assert');
const src=fs.readFileSync(__dirname+'/index.html','utf8').match(/<script>([\s\S]*?)<\/script>/)[1];
let current=1700000000000;const memory=new Map();
function start(rng=0.99){const elems={};function el(id){return elems[id]??(elems[id]={innerHTML:'',textContent:'',dataset:{},addEventListener(){},onclick:null,classList:{toggle(){}}})}
const win={},timers=[];class TestDate extends Date{static now(){return current}}
const fixedMath=Object.create(Math);fixedMath.random=()=>rng;
const context={Date:TestDate,document:{querySelector:el,querySelectorAll:()=>[]},window:win,localStorage:{getItem:k=>memory.get(k)??null,setItem:(k,v)=>memory.set(k,v)},setInterval:fn=>{timers.push(fn);return timers.length},structuredClone,console,Math:fixedMath,JSON,confirm:()=>true};vm.runInNewContext(src,context);return{debug:win.LittleRayDebug,tick:()=>timers.forEach(fn=>fn())}}
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

// Regression QA-FIX-001: spending the guided exception cannot wait for hatch claim.
memory.clear();
let run=start(), api=run.debug, state=()=>api.getState();
const elapsed=n=>{current+=n*1000;run.tick()};
const reload=()=>{run=start();api=run.debug};
let before=state().gold;
api.action('breed');assert.equal(state().gold,before);assert.equal(state().firstPearl,false);
for(const i of [1,2]){api.action('feed',i);api.action('feed',i)}
api.action('breed');assert.equal(state().firstPearl,true);assert.equal(state().breed.kind,'pearlcloud');assert.equal(state().gold,before-100);
api.action('breed');assert.equal(state().gold,before-100);
reload();assert.equal(state().firstPearl,true);assert.equal(state().breed.kind,'pearlcloud');
elapsed(19);api.action('transfer');assert.equal(state().hatch.kind,'pearlcloud');assert.equal(state().breed,null);
api.action('breed');assert.equal(state().breed.kind,'sunbeam');assert.equal(state().gold,before-200);
api.action('breed');assert.equal(state().gold,before-200);
reload();assert.equal(state().firstPearl,true);assert.equal(state().breed.kind,'sunbeam');assert.equal(state().hatch.kind,'pearlcloud');
elapsed(15);api.action('claim');api.action('claim');assert.equal(state().rays.length,3);assert.equal(state().rays[2].kind,'pearlcloud');
elapsed(4);api.action('transfer');elapsed(15);api.action('claim');api.action('claim');
assert.equal(state().rays.length,4);assert.equal(state().rays[3].kind,'sunbeam');assert.equal(state().rays.filter(r=>r.kind==='pearlcloud').length,1);
// Compatibility: an older in-flight guided egg can exist with firstPearl=false.
memory.clear();run=start();api=run.debug;
for(const i of [1,2]){api.action('feed',i);api.action('feed',i)}
api.action('breed');elapsed(19);api.action('transfer');
const saved=JSON.parse(memory.get('little-ray-proof-v01'));saved.firstPearl=false;
memory.set('little-ray-proof-v01',JSON.stringify(saved));reload();
assert.equal(state().firstPearl,true);assert.equal(state().hatch.kind,'pearlcloud');
api.action('breed');assert.equal(state().breed.kind,'sunbeam');
console.log(JSON.stringify({pass:true,regressions:['invalid start does not consume entitlement','paid first job consumes entitlement once','reload preserves committed first egg','overlapping second job uses ordinary fixed RNG','reload preserves both separate jobs','duplicate debit and claim rejected','legacy in-flight egg consumes entitlement on load']},null,2));


// Feeding at the opening level-ten cap must never consume Food or hidden XP.
memory.clear();run=start();api=run.debug;
api.action('plant',0);api.action('plant',1);elapsed(13);
api.action('harvest',0);api.action('harvest',1);
for(let k=0;k<14;k++)api.action('feed',1);
assert.equal(state().rays[0].lv,10);
assert.equal(state().rays[0].xp,0);
const foodAtCap=state().food;
api.action('feed',1);
assert.equal(state().food,foodAtCap);
assert.equal(state().rays[0].xp,0);
console.log(JSON.stringify({pass:true,regressions:['feeding a capped level-ten ray is a no-op with no Food cost or XP change']},null,2));
