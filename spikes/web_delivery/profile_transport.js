// ARCH-002 production-profile transport candidate. Separate from diagnostic IDBFS.
// Supply an opened IndexedDB database with an out-of-line-key "profiles" store.
// Use only under a lifetime exclusive writer lock; no shell/Godot wiring yet.
// The caller must validate domain snapshots and mark_unknown on timeout/error.
// This module does not implement backup import or prove actual-host durability.

export function createProfileTransport(db) {
  const storeName = "profiles";
  let busy = false;
  let unavailable = false;
  let recoveryPair = null;
  const recoveryKey = "recovery-original";
  function envelope(text) {
    if (typeof text !== "string") return null;
    try {
      const x = JSON.parse(text);
      if (!x || Array.isArray(x) || Object.keys(x).length !== 3 ||
          !Number.isSafeInteger(x.storage_revision) || x.storage_revision < 1 ||
          !Number.isSafeInteger(x.wall_marker_ms) || x.wall_marker_ms < 0 ||
          !x.model || typeof x.model !== "object" || Array.isArray(x.model) ||
          !Number.isSafeInteger(x.model.revision) || x.model.revision < 0) return null;
      return x;
    } catch (_) { return null; }
  }
  // Normal commits retain exactly the immediately preceding generation.
  // Inconsistent pairs are recovery-only; never repair by overwriting them.
  function validPair(active, previous) {
    const a = envelope(active);
    if (!a) return false;
    if (a.storage_revision === 1) return previous === undefined;
    const p = envelope(previous);
    return !!p && p.storage_revision === a.storage_revision - 1 &&
      p.wall_marker_ms <= a.wall_marker_ms &&
      p.model.revision <= a.model.revision;
  }
  // Resolve only on the transaction's complete event; requests succeeding
  // individually are not durability acknowledgements.
  function readPair(includeArchive = false) {
    return new Promise((resolve, reject) => {
      const tx = db.transaction(storeName, "readonly");
      const store = tx.objectStore(storeName);
      const active = store.get("active");
      const previous = store.get("previous");
      const activeKey = store.getKey("active");
      const previousKey = store.getKey("previous");
      const archive = includeArchive ? store.get(recoveryKey) : null;
      const archiveKey = includeArchive ? store.getKey(recoveryKey) : null;
      tx.oncomplete = () => resolve({
        active: active.result, previous: previous.result,
        activePresent: activeKey.result !== undefined,
        previousPresent: previousKey.result !== undefined,
        ...(includeArchive ? {archive: archive.result, archivePresent: archiveKey.result !== undefined} : {})
      });
      tx.onabort = () => reject(new Error("read aborted"));
      tx.onerror = () => reject(new Error("read failed"));
    });
  }
  function failure(reason) {
    unavailable = true;
    return {ok: false, status: "unavailable", reason};
  }
  async function read() {
    if (unavailable || busy) return {ok: false, status: "unavailable"};
    busy = true;
    try {
      const pair = await readPair();
      if (!pair.activePresent && !pair.previousPresent)
        return {ok: true, status: "missing", active: null, previous: null};
      if ((pair.activePresent && pair.active === undefined) ||
          (pair.previousPresent && pair.previous === undefined) ||
          !validPair(pair.active, pair.previous)) {
        // Only a definitive integrity failure (not ambiguous I/O) permits a
        // separate, explicitly confirmed recovery operation on this instance.
        recoveryPair = {...pair};
        return {...failure("Invalid or orphaned profile; preserve both records."), ...pair};
      }
      return {ok: true, status: "ready", active: pair.active, previous: pair.previous ?? null};
    } catch (_) { return failure("Could not read profile."); }
    finally { busy = false; }
  }
  // Caller supplies the EXACT last validated active bytes (null ONLY for
  // verified empty storage) and the pending payload from profile_commit.gd.
  // Domain validation and writer lifetime are external prerequisites.
  async function commit(expected, payload, expectedPrevious = undefined) {
    if (unavailable || busy) return {ok: false, status: "unavailable"};
    const before = expected === null ? null : envelope(expected);
    const next = envelope(payload);
    if ((expected !== null && !before) || !next ||
        next.storage_revision !== (before ? before.storage_revision + 1 : 1) ||
        (before && (next.wall_marker_ms < before.wall_marker_ms ||
                    next.model.revision < before.model.revision)))
      return failure("Invalid commit envelope or generation.");
    busy = true;
    try {
      const changed = await new Promise((resolve, reject) => {
        const tx = db.transaction(storeName, "readwrite");
        const store = tx.objectStore(storeName);
        let applied = false;
        const active = store.get("active");
        const previous = store.get("previous");
        const activeKey = store.getKey("active");
        const previousKey = store.getKey("previous");
        tx.oncomplete = () => resolve(applied);
        tx.onabort = () => reject(new Error("write aborted"));
        tx.onerror = () => reject(new Error("write failed"));
        // Values and key presence are read in the same transaction. The last
        // request callback compares and enqueues both writes before auto-commit.
        previousKey.onsuccess = () => {
          const actual = active.result;
          const activePresent = activeKey.result !== undefined;
          const previousPresent = previousKey.result !== undefined;
          if (expected === null ? activePresent || previousPresent : !activePresent || actual !== expected) return;
          // When a session supplied the validated predecessor, compare its exact bytes too.
          // null represents verified absence; undefined is the low-level legacy API.
          if (expectedPrevious !== undefined && (previousPresent !== (expectedPrevious !== null) ||
              (previousPresent && previous.result !== expectedPrevious))) return;
          if (expected !== null && ((previousPresent && previous.result === undefined) ||
              !validPair(actual, previous.result))) return;
          try {
            if (expected !== null) store.put(expected, "previous");
            store.put(payload, "active");
            applied = true;
          } catch (_) { tx.abort(); }
        };
      });
      if (!changed) return failure("Storage conflict or invalid previous copy; reload to reconcile.");
      const observed = await readPair();
      if (!observed.activePresent || observed.previousPresent !== (expected !== null) ||
          observed.active !== payload ||
          observed.previous !== (expected === null ? undefined : expected))
        return failure("Committed bytes could not be confirmed; reload to reconcile.");
      return {ok: true, status: "saved", storage_revision: next.storage_revision, observed_text: observed.active};
    } catch (_) { return failure("Write outcome unknown; reload to reconcile."); }
    finally { busy = false; }
  }
  // Narrow recovery primitive; NOT exposed to the live Godot mailbox yet.
  // Caller must hold the exclusive writer lock, validate the selected previous
  // snapshot against the domain schema, preview the lost progress, and obtain
  // explicit confirmation. Only missing or malformed-string active is handled;
  // envelope-valid but unsupported domain data and non-string records remain
  // fenced. One immutable raw archive is retained; no automatic eviction.
  async function recoverPrevious(expectedPair, validatedPrevious, observedWallMs) {
    if (busy || !unavailable || !recoveryPair || !expectedPair) return {ok: false, status: "unavailable"};
    const p = recoveryPair;
    const samePair = (x, y) => x.activePresent === y.activePresent &&
      x.previousPresent === y.previousPresent &&
      x.active === y.active && x.previous === y.previous;
    const before = envelope(p.previous);
    if (!samePair(p, expectedPair) || !p.previousPresent ||
        validatedPrevious !== p.previous || !before ||
        (p.activePresent ? typeof p.active !== "string" || !!envelope(p.active) : p.active !== undefined) ||
        !Number.isSafeInteger(observedWallMs) || observedWallMs < 0 ||
        before.storage_revision >= Number.MAX_SAFE_INTEGER ||
        before.model.revision >= Number.MAX_SAFE_INTEGER - 1)
      return {ok: false, status: "unavailable", reason: "Recovery selection invalid or unsupported."};
    const payload = JSON.stringify({
      storage_revision: before.storage_revision + 1,
      wall_marker_ms: Math.max(before.wall_marker_ms, observedWallMs),
      model: {...before.model, revision: before.model.revision + 1}
    });
    const archive = JSON.stringify({
      version: 1, activePresent: p.activePresent, previousPresent: p.previousPresent,
      active: p.activePresent ? p.active : null, previous: p.previous
    });
    busy = true;
    recoveryPair = null; // One attempt; reload/re-preview even on CAS conflict.
    try {
      const applied = await new Promise((resolve, reject) => {
        const tx = db.transaction(storeName, "readwrite");
        const store = tx.objectStore(storeName);
        const active = store.get("active"), previous = store.get("previous");
        const activeKey = store.getKey("active"), previousKey = store.getKey("previous");
        const archiveKey = store.getKey(recoveryKey);
        let changed = false;
        tx.oncomplete = () => resolve(changed);
        tx.onabort = () => reject(new Error("recovery aborted"));
        tx.onerror = () => reject(new Error("recovery failed"));
        archiveKey.onsuccess = () => {
          const actual = {active: active.result, previous: previous.result,
            activePresent: activeKey.result !== undefined, previousPresent: previousKey.result !== undefined};
          if (archiveKey.result !== undefined || !samePair(p, actual)) return;
          try {
            store.add(archive, recoveryKey);
            store.put(p.previous, "previous");
            store.put(payload, "active");
            changed = true;
          } catch (_) { tx.abort(); }
        };
      });
      if (!applied) return failure("Recovery conflict or archive already exists; preserve all records.");
      const observed = await readPair(true);
      if (!observed.activePresent || !observed.previousPresent || !observed.archivePresent ||
          observed.active !== payload || observed.previous !== p.previous || observed.archive !== archive)
        return failure("Recovery outcome unknown; reload to reconcile.");
      // Keep this transport fenced. Only a fresh, domain-validated session may
      // publish the recovered city or resume ordinary saves.
      return {ok: true, status: "recovered", observed_text: observed.active,
        storage_revision: before.storage_revision + 1};
    } catch (_) { return failure("Recovery outcome unknown; reload to reconcile."); }
    finally { busy = false; }
  }
  return {read, commit, recoverPrevious};
}

// Lifetime browser owner for one profile DB. The game must still validate the
// domain snapshot before using initial.active, and publish effects only after
// commit returns the exact acknowledged bytes. This is not the Godot UI seam.
// On ambiguous I/O the session stays fenced until document destruction/reload.
export async function openProfileSession(name, {
  timeoutMs = 5000, locks = globalThis.navigator?.locks,
  dbFactory = globalThis.indexedDB
} = {}) {
  let state = "opening", db = null, transport = null, expected = null, expectedPrevious = null;
  let initial = null, releaseLock, ownerTask;
  const unavailable = reason => ({ok: false, status: "unavailable", reason});
  const held = new Promise(resolve => { releaseLock = resolve; });
  function deadline(promise) {
    let timer;
    return Promise.race([promise, new Promise((_, reject) => {
      timer = setTimeout(() => reject(new Error("Storage deadline exceeded.")), timeoutMs);
    })]).finally(() => clearTimeout(timer));
  }
  function fail(reason) {
    state = "unavailable";
    return unavailable(reason);
  }
  function openDb() {
    return new Promise((resolve, reject) => {
      const request = dbFactory.open(name, 1);
      request.onupgradeneeded = event => {
        if (state !== "opening" || event.oldVersion !== 0) {
          request.transaction.abort();
          return;
        }
        request.result.createObjectStore("profiles");
      };
      request.onerror = () => reject(new Error("Profile database open failed."));
      request.onblocked = () => reject(new Error("Profile database open blocked."));
      request.onsuccess = () => {
        const opened = request.result;
        if (state !== "opening") {
          opened.close();
          reject(new Error("Late database open ignored."));
          return;
        }
        resolve(opened);
      };
    });
  }
  const session = {
    get status() { return state; },
    get initial() { return initial; },
    async commit(payload) {
      if (state !== "ready") return {ok: false, status: state};
      state = "saving";
      try {
        const result = await deadline(transport.commit(expected, payload, expectedPrevious));
        if (state !== "saving") return unavailable("Session invalidated; reload to reconcile.");
        if (!result.ok || result.observed_text !== payload)
          return fail(result.reason || "Write could not be confirmed; reload to reconcile.");
        expectedPrevious = expected;
        expected = result.observed_text;
        state = "ready";
        return result;
      } catch (_) { return fail("Write outcome unknown; reload to reconcile."); }
    },
    async close() {
      if (state === "closed") return true;
      // Do not release a writer while an operation may still commit.
      if (state !== "ready" && state !== "read-only") return false;
      state = "closed";
      if (db) db.close();
      releaseLock();
      if (ownerTask) await ownerTask;
      return true;
    }
  };
  if (typeof name !== "string" || !name || !Number.isFinite(timeoutMs) ||
      timeoutMs <= 0 || !locks || !dbFactory) {
    fail("Browser writer lock or storage unavailable.");
    return session;
  }
  let ready;
  const started = new Promise(resolve => { ready = resolve; });
  try {
    ownerTask = locks.request("little-ray-profile:" + name,
      {mode: "exclusive", ifAvailable: true}, async lock => {
        // A late acquisition after the startup deadline cannot open storage.
        if (state !== "opening") return;
        if (!lock) {
          state = "read-only";
          ready();
          return;
        }
        try {
          db = await openDb();
          if (state !== "opening") { db.close(); return; }
          db.onversionchange = () => {
            fail("Profile database changed; reload to reconcile.");
            db.close();
          };
          transport = createProfileTransport(db);
          const result = await transport.read();
          if (state !== "opening") return;
          initial = result;
          if (result.ok) {
            expected = result.active;
            expectedPrevious = result.previous;
            state = "ready";
          } else fail(result.reason || "Profile read failed.");
        } catch (_) { fail("Profile database unavailable."); }
        finally { ready(); }
        // Even after a failed read/write, preserve ownership until reload.
        await held;
      }).catch(() => {
        if (state !== "closed") fail("Writer lock unavailable.");
        ready();
      });
    await deadline(started);
  } catch (_) { fail("Profile session startup deadline exceeded."); }
  return session;
}


// One-message mailbox for Godot's synchronous JavaScriptBridge calls.
// A caller must consume the open/write result before submitting another
// operation. A positive write result contains the actual durable readback,
// not the submitted payload. No JS callback lifetime or eval is required.
// The city shell supplies () => openProfileSession(itsProfileDatabase).
export function createGodotProfilePort(openSession) {
  let state = "new", session = null, message = "", nextState = "";
  function finish(result, after) {
    message = JSON.stringify(result);
    nextState = after;
    state = "result";
  }
  function fail(kind, status = "unavailable") {
    finish({kind, ok: false, status}, "unavailable");
  }
  return {
    begin_open() {
      if (state !== "new") return false;
      state = "opening";
      Promise.resolve().then(openSession).then(opened => {
        session = opened;
        const initial = session?.initial;
        if (session?.status !== "ready" || !initial?.ok ||
            !((initial.status === "missing" && initial.active === null) ||
              (initial.status === "ready" && typeof initial.active === "string"))) {
          fail("open", session?.status === "read-only" ? "read-only" : "unavailable");
          return;
        }
        finish({kind: "open", ok: true, status: initial.status,
                active: initial.active, previous: initial.previous}, "ready");
      }).catch(() => fail("open"));
      return true;
    },
    begin_write(payload) {
      if (state !== "ready" || session?.status !== "ready" ||
          typeof payload !== "string") return false;
      state = "saving";
      Promise.resolve().then(() => session.commit(payload)).then(result => {
        if (!result?.ok || result.observed_text !== payload ||
            !Number.isSafeInteger(result.storage_revision)) {
          fail("write");
          return;
        }
        finish({kind: "write", ok: true, storage_revision: result.storage_revision,
                observed_text: result.observed_text}, "ready");
      }).catch(() => fail("write"));
      return true;
    },
    take_result() {
      if (state !== "result") return "";
      const value = message;
      message = "";
      state = nextState;
      return value;
    },
    // Only healthy, consumed states may release a writer. Faulted sessions
    // intentionally retain their fence until the page is reloaded.
    async close() {
      if (state !== "ready" || !session) return false;
      state = "closing";
      try {
        if (!(await session.close())) {
          state = "unavailable";
          return false;
        }
        state = "closed";
        return true;
      } catch (_) {
        state = "unavailable";
        return false;
      }
    }
  };
}
