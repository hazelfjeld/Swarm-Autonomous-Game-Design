const fs=require('fs'),vm=require('vm'),assert=require('assert');
const src=fs.readFileSync(__dirname+'/index.html','utf8').match(/<script>([\s\S]*?)<\/script>/)[1];
let current=1700000000000;const memory=new Map();
function start(rng=0.99,storage={}){const elems={};function el(id){return elems[id]??(elems[id]={innerHTML:'',textContent:'',dataset:{},addEventListener(){},onclick:null,classList:{toggle(){}}})}
const win={},timers=[];class TestDate extends Date{static now(){return current}}
const fixedMath=Object.create(Math);fixedMath.random=()=>rng;
const context={Date:TestDate,document:{querySelector:el,querySelectorAll:()=>[]},window:win,localStorage:{getItem:k=>{if(storage.failRead)throw Error('Read denied');return memory.get(k)??null},setItem:(k,v)=>{if(storage.failWrite)throw Error('Write denied');memory.set(k,v)}},setInterval:fn=>{timers.push(fn);return timers.length},structuredClone,console,Math:fixedMath,JSON,confirm:()=>storage.confirmReset!==false};vm.runInNewContext(src,context);return{debug:win.LittleRayDebug,tick:()=>timers.forEach(fn=>fn()),el}}
const {debug,tick}=start();const stat=()=>debug.getState();const advance=n=>{current+=n*1000;tick()};
assert.equal(stat().rays.length,2);
advance(3);const bank=Math.floor(stat().storedGold);assert.ok(bank>0);debug.action('collect');assert.equal(stat().gold,1200+bank);assert.equal(stat().goals.collect,true);
const g0=stat().gold;debug.action('plant',0);assert.equal(stat().gold,g0-40);advance(12.5);debug.action('harvest',0);assert.equal(stat().food,305);assert.equal(stat().crops[0],null);
for(const id of [1,2]){debug.action('feed',id);debug.action('feed',id)}assert.equal(stat().rays[0].lv,4);assert.equal(stat().rays[1].lv,4);
debug.action('breed');assert.ok(stat().breed);const g=stat().gold;debug.action('breed');assert.equal(stat().gold,g);
advance(19);debug.action('transfer');assert.equal(stat().breed,null);assert.ok(stat().hatch);
advance(15);debug.action('claim');assert.equal(stat().rays.length,3);assert.equal(stat().rays[2].kind,'pearlcloud');debug.action('claim');assert.equal(stat().rays.length,3);
debug.action('startBattle');for(let x=0;x<20&&!stat().battle.finished;x++){const b=stat().battle,living=b.allies.filter(r=>r.hp>0),actor=living[b.turn%living.length];debug.action(actor.signatureCooldown?'attack':'special');}assert.equal(stat().battle.finished,true);assert.equal(stat().battle.won,true);let gold=stat().gold;debug.action('special');assert.equal(stat().gold,gold);
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

// Each ray's signature recovers on its own subsequent completed turn, not an ally's.
memory.clear();run=start();api=run.debug;
for(const i of [1,2]){api.action('feed',i);api.action('feed',i)}
api.action('breed');elapsed(19);api.action('transfer');elapsed(15);api.action('claim');
api.action('startBattle');
assert.deepEqual(state().battle.allies.map(a=>a.signatureCooldown),[0,0,0]);
api.action('special');assert.deepEqual(state().battle.allies.map(a=>a.signatureCooldown),[1,0,0]);
api.action('special');api.action('special');assert.deepEqual(state().battle.allies.map(a=>a.signatureCooldown),[1,1,1]);
const cooling=state().battle;api.action('special');assert.deepEqual(state().battle,cooling);
reload();assert.deepEqual(state().battle,cooling);api.action('special');assert.deepEqual(state().battle,cooling);
api.action('attack');assert.equal(state().battle.allies[0].signatureCooldown,0);assert.equal(state().battle.allies[1].signatureCooldown,1);
api.action('guard');assert.equal(state().battle.allies[1].signatureCooldown,0);assert.equal(state().battle.allies[2].signatureCooldown,1);
api.action('attack');assert.equal(state().battle.allies[2].signatureCooldown,0);
// Older battle saves have no cooldown field; the next legal signature initializes it.
const prior=JSON.parse(memory.get('little-ray-proof-v01'));prior.battle.allies.forEach(a=>delete a.signatureCooldown);memory.set('little-ray-proof-v01',JSON.stringify(prior));reload();
const beforeOld=state().battle.turn;api.action('special');assert.ok(state().battle.finished||state().battle.turn===beforeOld+1);assert.ok(state().battle.allies.some(a=>a.signatureCooldown===1));
console.log(JSON.stringify({pass:true,regressions:['personal signature cooldown','cooldown rejects repeated action without consuming a turn','cooldown persists after reload','basic and guard recover only the acting ray','older active battle remains playable']}));

// Save-loss regression: preserve unknown or externally changed profile bytes.
const saveKey='little-ray-proof-v01';
memory.clear();run=start();api=run.debug;api.action('plant',0);
const originalSave=memory.get(saveKey);
const denied={failRead:true,confirmReset:false};run=start(.99,denied);api=run.debug;
assert.equal(memory.get(saveKey),originalSave);
assert.ok(run.el('#saveStatus').textContent.includes('could not be read'));
denied.failRead=false;api.action('feed',1);elapsed(11);
assert.equal(memory.get(saveKey),originalSave);
run.el('#reset').onclick();assert.equal(memory.get(saveKey),originalSave);
reload();assert.equal(state().gold,1160);assert.ok(state().crops[0]);
for(const bad of ['{','null','{}','{"v":1,"rays":[]}']){
  memory.clear();memory.set(saveKey,bad);run=start();api=run.debug;elapsed(11);
  assert.equal(memory.get(saveKey),bad);
  assert.ok(run.el('#saveStatus').textContent.includes('could not be read'));
  run.el('#reset').onclick();assert.equal(JSON.parse(memory.get(saveKey)).gold,1200);
}
memory.clear();const stale=start(),writer=start();writer.debug.action('feed',1);
const newerSave=memory.get(saveKey);
stale.debug.action('plant',0);current+=11000;stale.tick();
assert.equal(memory.get(saveKey),newerSave);
assert.equal(JSON.parse(memory.get(saveKey)).food,220);
assert.ok(stale.el('#saveStatus').textContent.includes('another window'));
stale.el('#reset').onclick();assert.equal(JSON.parse(memory.get(saveKey)).food,240);
memory.clear();run=start(.99,{failWrite:true});
assert.equal(memory.size,0);assert.ok(run.el('#saveStatus').textContent.includes('Save unavailable'));
console.log(JSON.stringify({pass:true,regressions:['read denial never overwrites existing profile','invalid JSON/profile preserved until explicit reset','cancelled reset preserves save','stale sequential window cannot overwrite changed profile','write failure warning']}));
