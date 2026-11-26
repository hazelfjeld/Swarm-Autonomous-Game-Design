// Executed by WebDriver on the ephemeral CI origin, not the intended Site.
// The first argument is the exact checked-out production candidate module.
const done = arguments[arguments.length - 1];
(async () => {
  const create = new Function(arguments[0].replace("export function", "function") + "\nreturn createProfileTransport;")();
  const name = "arch002-profile-transport-fixture-" + crypto.randomUUID();
  const open = () => new Promise((resolve, reject) => {
    const request = indexedDB.open(name, 1);
    request.onupgradeneeded = () => request.result.createObjectStore("profiles");
    request.onsuccess = () => resolve(request.result);
    request.onerror = () => reject(request.error);
    request.onblocked = () => reject(new Error("fixture open blocked"));
  });
  const db = await open();
  const other = await open();
  const checks = [];
  const check = (condition, label) => {
    if (!condition) throw new Error(label);
    checks.push(label);
  };
  const payload = (n, food, time = 100) => JSON.stringify({
    storage_revision: n, wall_marker_ms: time, model: {revision: n, food}
  });
  const a = payload(1, 240), b = payload(2, 230);
  const c = payload(3, 220), d = payload(3, 210);
  const read = () => create(db).read();
  try {
    const first = create(db);
    check((await first.read()).status === "missing", "verified missing pair");
    check((await first.commit(null, a)).observed_text === a, "first write exact readback");
    check((await first.commit(a, b)).storage_revision === 2, "second write committed");
    let pair = await read();
    check(pair.active === b && pair.previous === a, "active and previous persisted");
    const stale = create(other);
    check(!(await stale.commit(a, b)).ok, "stale expected bytes refused");
    check(!(await stale.commit(b, c)).ok, "conflicting instance fails closed");
    pair = await read();
    check(pair.active === b && pair.previous === a, "stale write preserved both records");

    // Abort a genuine readwrite transaction after the active put succeeded,
    // before transaction completion. Only the fixture facade is instrumented.
    let abortedAfterPut = false;
    const aborting = {
      transaction(storeName, mode) {
        const tx = db.transaction(storeName, mode);
        if (mode !== "readwrite") return tx;
        return {
          objectStore(name) {
            const s = tx.objectStore(name);
            return {
              get: key => s.get(key),
              put(value, key) {
                const request = s.put(value, key);
                if (key === "active") request.addEventListener("success", () => {
                  abortedAfterPut = true;
                  tx.abort();
                }, {once: true});
                return request;
              }
            };
          },
          set oncomplete(fn) { tx.oncomplete = fn; },
          set onabort(fn) { tx.onabort = fn; },
          set onerror(fn) { tx.onerror = fn; },
          abort() { tx.abort(); }
        };
      }
    };
    const fault = create(aborting);
    check(!(await fault.commit(b, c)).ok && abortedAfterPut, "real abort after active put");
    pair = await read();
    check(pair.active === b && pair.previous === a, "transaction rollback preserved both records");
    check(!(await fault.commit(b, c)).ok, "aborted instance fails closed");

    // Intentionally omit the future lifetime writer-lock layer in this test:
    // the storage CAS itself must serialize competing same-generation writes.
    const outcomes = await Promise.all([create(db).commit(b, c), create(other).commit(b, d)]);
    check(outcomes.filter(x => x.ok).length === 1, "concurrent stale generation accepts one writer");
    const winner = outcomes.find(x => x.ok).observed_text;
    pair = await read();
    check(pair.active === winner && pair.previous === b, "winning active and previous readback");
    other.close();
    db.close();
    const reopened = await open();
    try {
      pair = await create(reopened).read();
      check(pair.active === winner && pair.previous === b, "reopened database retains committed pair");
      // Inject individually valid but inconsistent records. Check both read
      // and direct commit on separate instances, then inspect raw bytes.
      const injectPair = (active, previous) => new Promise((resolve, reject) => {
        const tx = reopened.transaction("profiles", "readwrite");
        const s = tx.objectStore("profiles");
        s.put(active, "active");
        if (previous === undefined) s.delete("previous");
        else s.put(previous, "previous");
        tx.oncomplete = resolve;
        tx.onabort = tx.onerror = () => reject(new Error("pair injection failed"));
      });
      const rawPair = () => new Promise((resolve, reject) => {
        const tx = reopened.transaction("profiles", "readonly");
        const s = tx.objectStore("profiles");
        const active = s.get("active"), previous = s.get("previous");
        tx.oncomplete = () => resolve([active.result, previous.result]);
        tx.onabort = tx.onerror = () => reject(new Error("pair readback failed"));
      });
      const domainAhead = JSON.stringify({
        storage_revision: 1, wall_marker_ms: 100, model: {revision: 9, food: 240}
      });
      for (const [label, active, previous, next] of [
        ["missing predecessor", b, undefined, c],
        ["newer predecessor", b, c, d],
        ["generation gap", c, a, payload(4, 200)],
        ["unexpected first predecessor", a, b, payload(2, 230)],
        ["wall marker regression", b, payload(1, 240, 101), c],
        ["domain revision regression", b, domainAhead, c]
      ]) {
        await injectPair(active, previous);
        const rejected = await create(reopened).read();
        check(!rejected.ok, label + ": read refused");
        check(!(await create(reopened).commit(active, next)).ok,
          label + ": direct write refused");
        const raw = await rawPair();
        check(raw[0] === active && raw[1] === previous,
          label + ": both records preserved");
      }
      await injectPair(winner, b);
      // Corrupt the active record deliberately in the test database only.
      await new Promise((resolve, reject) => {
        const tx = reopened.transaction("profiles", "readwrite");
        tx.objectStore("profiles").put("damaged", "active");
        tx.oncomplete = resolve;
        tx.onabort = tx.onerror = () => reject(new Error("fault fixture failed"));
      });
      const invalid = create(reopened);
      pair = await invalid.read();
      check(!pair.ok && pair.active === "damaged" && pair.previous === b, "corrupt active preserved for recovery");
      check(!(await invalid.commit(null, a)).ok, "corrupt profile cannot initialize blank");
    } finally { reopened.close(); }
    return {profile_transport: "pass", checks, actual_site_verified: false};
  } finally {
    other.close();
    db.close();
    indexedDB.deleteDatabase(name);
  }
})().then(done, error => done({profile_transport: "fail", error: String(error)}));
