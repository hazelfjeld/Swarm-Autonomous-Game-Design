// Executed by WebDriver on the ephemeral CI origin, not the intended Site.
// The first argument is the exact checked-out production candidate module.
const done = arguments[arguments.length - 1];
(async () => {
  const {create, openSession, createPort} = new Function(arguments[0].replace(/export (async )?function/g, "$1function") + "\nreturn {create: createProfileTransport, openSession: openProfileSession, createPort: createGodotProfilePort};")();
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
    check(!(await create(db).commit(b, c, payload(1, 999))).ok, "exact previous bytes conflict refused");
    pair = await read();
    check(pair.active === b && pair.previous === a, "previous conflict preserved both records");

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
              getKey: key => s.getKey(key),
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
      // get() alone cannot distinguish an absent key from stored undefined.
      // Corruption must not be mistaken for a fresh profile or repaired on write.
      for (const [label, entries, expected, next] of [
        ["undefined active", [["active", undefined]], null, a],
        ["undefined previous", [["previous", undefined]], null, a],
        ["both undefined", [["active", undefined], ["previous", undefined]], null, a],
        ["undefined predecessor", [["active", a], ["previous", undefined]], a, b]
      ]) {
        await new Promise((resolve, reject) => {
          const tx = reopened.transaction("profiles", "readwrite");
          const s = tx.objectStore("profiles");
          s.clear();
          for (const [key, value] of entries) s.put(value, key);
          tx.oncomplete = resolve;
          tx.onabort = tx.onerror = reject;
        });
        check(!(await create(reopened).read()).ok, label + ": read refused");
        check(!(await create(reopened).commit(expected, next)).ok, label + ": write refused");
        const observed = await new Promise((resolve, reject) => {
          const tx = reopened.transaction("profiles", "readonly");
          const s = tx.objectStore("profiles");
          const keys = s.getAllKeys(), active = s.get("active"), previous = s.get("previous");
          tx.oncomplete = () => resolve([keys.result, active.result, previous.result]);
          tx.onabort = tx.onerror = reject;
        });
        const wanted = new Map(entries);
        check(observed[0].length === wanted.size && observed[0].every(k => wanted.has(k)) &&
          observed[1] === wanted.get("active") && observed[2] === wanted.get("previous"),
          label + ": all existing keys/values preserved");
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

      // Recovery is an explicit separate operation with exact raw-pair CAS.
      const staleRecovery = create(reopened);
      const stalePair = await staleRecovery.read();
      await injectPair("changed damage", b);
      check(!(await staleRecovery.recoverPrevious(stalePair, b, 200)).ok,
        "recovery stale raw active refused");
      let raw = await rawPair();
      check(raw[0] === "changed damage" && raw[1] === b, "recovery conflict preserves raw pair");
      const recovery = create(reopened);
      const preview = await recovery.read();
      check(!(await recovery.recoverPrevious(preview, a, 200)).ok,
        "recovery rejects unvalidated selection bytes");
      const recovered = await recovery.recoverPrevious(preview, b, 200);
      check(recovered.ok && recovered.status === "recovered" &&
        JSON.parse(recovered.observed_text).model.food === 230 &&
        JSON.parse(recovered.observed_text).model.revision === 3 &&
        JSON.parse(recovered.observed_text).wall_marker_ms === 200,
        "recovery restores previous without offline credit");
      const readArchive = () => new Promise((resolve, reject) => {
        const tx = reopened.transaction("profiles", "readonly");
        const request = tx.objectStore("profiles").get("recovery-original");
        tx.oncomplete = () => resolve(request.result);
        tx.onabort = tx.onerror = reject;
      });
      const archive = await readArchive();
      check(JSON.parse(archive).active === "changed damage" &&
        JSON.parse(archive).previous === b && JSON.parse(archive).activePresent,
        "recovery preserves original bytes in immutable archive");
      const fresh = create(reopened);
      const restoredPair = await fresh.read();
      check(restoredPair.ok && restoredPair.active === recovered.observed_text && restoredPair.previous === b,
        "recovery pair is valid on fresh read");
      check((await fresh.commit(restoredPair.active, payload(4, 220, 200), b)).ok &&
        (await readArchive()) === archive, "ordinary save leaves recovery archive untouched");
      await injectPair("second damage", b);
      const repeat = create(reopened);
      const repeatPair = await repeat.read();
      check(!(await repeat.recoverPrevious(repeatPair, b, 300)).ok &&
        (await readArchive()) === archive && (await rawPair())[0] === "second damage",
        "second recovery cannot overwrite original archive");
    } finally { reopened.close(); }

    // Exercise the actual session wrapper with native Web Locks and IndexedDB.
    const sessionName = name + "-session";
    const firstSession = await openSession(sessionName);
    check(firstSession.status === "ready" && firstSession.initial.status === "missing", "session opens verified empty database");
    const follower = await openSession(sessionName);
    check(follower.status === "read-only", "second session cannot acquire writer");
    check(!(await follower.commit(a)).ok, "read-only session cannot write");
    check((await firstSession.commit(a)).observed_text === a, "session first commit acknowledges exact bytes");
    const pending = firstSession.commit(b);
    check(firstSession.status === "saving", "pending write reports saving");
    check(!(await firstSession.commit(c)).ok, "overlapping command refused");
    check(!(await firstSession.close()), "pending session cannot release writer");
    check((await pending).observed_text === b, "pending write confirms before publication");
    check(await firstSession.close(), "healthy owner explicitly closes");
    check(follower.status === "read-only", "follower does not automatically take over");
    await follower.close();
    const successor = await openSession(sessionName);
    check(successor.status === "ready" && successor.initial.active === b &&
      successor.initial.previous === a, "explicit reopen obtains latest pair");
    check((await successor.commit(c)).observed_text === c, "successor commits next generation");
    await successor.close();
    indexedDB.deleteDatabase(sessionName);

    // Inject only the never-completing open request, using a real writer lock.
    // This proves timeout and fencing, not a real disk failure.
    const timeoutName = name + "-timeout";
    let lateRequest;
    const stalled = await openSession(timeoutName, {
      timeoutMs: 100, dbFactory: {open() { lateRequest = {}; return lateRequest; }}
    });
    check(stalled.status === "unavailable" && !!lateRequest, "startup timeout fails closed");
    check(!(await stalled.commit(a)).ok && !(await stalled.close()), "uncertain session refuses write and release");
    const blocked = await openSession(timeoutName);
    check(blocked.status === "read-only", "timed out owner retains writer fence");
    let closedLate = false;
    lateRequest.result = {close() { closedLate = true; }};
    lateRequest.onsuccess();
    check(closedLate && stalled.status === "unavailable", "late open cannot revive timed-out session");
    await blocked.close();

    // Actual IndexedDB + Web Locks through the synchronous Godot mailbox.
    // This runs in Chromium; GDScript calls are covered separately by native CI.
    const mailboxName = name + "-mailbox";
    const mailbox = createPort(() => openSession(mailboxName));
    const awaitMessage = async port => {
      const deadline = performance.now() + 6000;
      while (performance.now() < deadline) {
        const encoded = port.take_result();
        if (encoded) return JSON.parse(encoded);
        await new Promise(resolve => setTimeout(resolve, 10));
      }
      throw new Error("mailbox result timed out");
    };
    check(mailbox.begin_open(), "mailbox queues startup");
    check(!mailbox.begin_open() && !mailbox.begin_write(a), "mailbox refuses overlap during open");
    const openedMailbox = await awaitMessage(mailbox);
    check(openedMailbox.ok && openedMailbox.status === "missing" && openedMailbox.active === null, "mailbox verified missing result");
    check(mailbox.take_result() === "", "mailbox result consumed once");
    check(mailbox.begin_write(a), "mailbox queues actual write");
    check(!mailbox.begin_write(b) && mailbox.take_result() === "", "mailbox prevents premature acknowledgement");
    const savedMailbox = await awaitMessage(mailbox);
    check(savedMailbox.ok && savedMailbox.storage_revision === 1 && savedMailbox.observed_text === a, "mailbox exact durable bytes");
    const otherMailbox = createPort(() => openSession(mailboxName));
    otherMailbox.begin_open();
    check((await awaitMessage(otherMailbox)).status === "read-only" && !otherMailbox.begin_write(b), "mailbox second writer refused");
    check(await mailbox.close(), "mailbox closes consumed owner");
    const reopenedMailbox = createPort(() => openSession(mailboxName));
    reopenedMailbox.begin_open();
    const loadedMailbox = await awaitMessage(reopenedMailbox);
    check(loadedMailbox.ok && loadedMailbox.active === a && loadedMailbox.previous === null, "mailbox reload observes exact bytes and absent predecessor");
    reopenedMailbox.begin_write(b);
    check((await awaitMessage(reopenedMailbox)).observed_text === b, "mailbox successor saves next generation");
    await reopenedMailbox.close();
    const pairMailbox = createPort(() => openSession(mailboxName));
    pairMailbox.begin_open();
    const loadedPair = await awaitMessage(pairMailbox);
    check(loadedPair.ok && loadedPair.active === b && loadedPair.previous === a, "mailbox forwards exact predecessor bytes");
    await pairMailbox.close();
    indexedDB.deleteDatabase(mailboxName);

    return {profile_transport: "pass", checks, actual_site_verified: false};
  } finally {
    other.close();
    db.close();
    indexedDB.deleteDatabase(name);
  }
})().then(done, error => done({profile_transport: "fail", error: String(error)}));
