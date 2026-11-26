// ARCH-002 production-profile transport candidate. Separate from diagnostic IDBFS.
// Supply an opened IndexedDB database with an out-of-line-key "profiles" store.
// Use only under a lifetime exclusive writer lock; no shell/Godot wiring yet.
// The caller must validate domain snapshots and mark_unknown on timeout/error.
// This module does not implement backup import or prove actual-host durability.

export function createProfileTransport(db) {
  const storeName = "profiles";
  let busy = false;
  let unavailable = false;
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
  // Resolve only on the transaction's complete event; requests succeeding
  // individually are not durability acknowledgements.
  function readPair() {
    return new Promise((resolve, reject) => {
      const tx = db.transaction(storeName, "readonly");
      const store = tx.objectStore(storeName);
      const active = store.get("active");
      const previous = store.get("previous");
      tx.oncomplete = () => resolve({active: active.result, previous: previous.result});
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
      if (pair.active === undefined && pair.previous === undefined)
        return {ok: true, status: "missing", active: null, previous: null};
      if (!envelope(pair.active) || (pair.previous !== undefined && !envelope(pair.previous)))
        return {...failure("Invalid or orphaned profile; preserve both records."), ...pair};
      return {ok: true, status: "ready", active: pair.active, previous: pair.previous ?? null};
    } catch (_) { return failure("Could not read profile."); }
    finally { busy = false; }
  }
  // Caller supplies the EXACT last validated active bytes (null ONLY for
  // verified empty storage) and the pending payload from profile_commit.gd.
  // Domain validation and writer lifetime are external prerequisites.
  async function commit(expected, payload) {
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
        tx.oncomplete = () => resolve(applied);
        tx.onabort = () => reject(new Error("write aborted"));
        tx.onerror = () => reject(new Error("write failed"));
        // Both reads are queued in this same transaction. The second success
        // callback can compare and enqueue both writes before auto-commit.
        previous.onsuccess = () => {
          const actual = active.result;
          if (expected === null ? actual !== undefined || previous.result !== undefined : actual !== expected) return;
          if (previous.result !== undefined && !envelope(previous.result)) return;
          try {
            if (expected !== null) store.put(expected, "previous");
            store.put(payload, "active");
            applied = true;
          } catch (_) { tx.abort(); }
        };
      });
      if (!changed) return failure("Storage conflict or invalid previous copy; reload to reconcile.");
      const observed = await readPair();
      if (observed.active !== payload ||
          observed.previous !== (expected === null ? undefined : expected))
        return failure("Committed bytes could not be confirmed; reload to reconcile.");
      return {ok: true, status: "saved", storage_revision: next.storage_revision, observed_text: observed.active};
    } catch (_) { return failure("Write outcome unknown; reload to reconcile."); }
    finally { busy = false; }
  }
  return {read, commit};
}
