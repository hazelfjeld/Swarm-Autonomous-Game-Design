extends SceneTree
const Session = preload("res://city_profile_session.gd")
const City = preload("res://city_model.gd")
var checks := 0
var failures: Array[String] = []

# Test double for the synchronous mailbox only. These acknowledgements are
# simulated; the independent Chromium fixture executes the real JS mailbox.
class FakePort:
	var message := ""
	var payload := ""
	var writes := 0
	var allow_write := true
	var recoveries := 0
	var recovery_payload := ""
	var recovery_wall := 0
	var allow_recovery := true
	func begin_recovery(value: String, wall: int) -> bool:
		recoveries += 1
		recovery_payload = value
		recovery_wall = wall
		return allow_recovery
	func begin_open() -> bool:
		return true
	func begin_write(value: String) -> bool:
		writes += 1
		payload = value
		return allow_write
	func take_result() -> String:
		var value := message
		message = ""
		return value
	func deliver(value: Dictionary) -> void:
		message = JSON.stringify(value)
	func ack() -> void:
		var envelope: Dictionary = JSON.parse_string(payload)
		deliver({"kind": "write", "ok": true, "storage_revision": envelope.storage_revision, "observed_text": payload})

func _check(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures.append(label)

func _initialize() -> void:
	_run()
	_run_import_clock()
	_run_previous_validation()
	_run_distinct_revision_rollback()
	_run_recovery_choice()
	_check(checks == 131, "all native session scenarios reached")
	print(JSON.stringify({"city_profile_session": "pass" if failures.is_empty() else "fail", "checks": checks, "failures": failures}))
	quit(0 if failures.is_empty() else 1)

func _run() -> void:
	var marker := 1700000000000
	var p := FakePort.new()
	var session = Session.new()
	_check(session.start(p) and session.status() == "opening", "open queued")
	_check(session.snapshot().is_empty() and not session.poll(marker), "no city before read")
	p.deliver({"kind": "open", "ok": true, "status": "missing", "active": null, "previous": null})
	_check(session.poll(marker) and session.status() == "saving" and p.writes == 1, "verified missing stages first save")
	_check(session.snapshot().is_empty(), "fresh city hidden until durable ack")
	p.ack()
	if not session.poll(marker):
		_check(false, "first save ack")
		return
	_check(session.status() == "ready" and session.snapshot() == City.new().snapshot(), "fresh city published after ack")
	var baseline: Dictionary = session.snapshot()
	var first_bytes := p.payload
	var cost: int = City.new().feed_cost("ray-1")
	_check(session.stage_command("feed", "ray-1", "ui-1", int(baseline.revision), 0, marker), "real feed staged")
	_check(session.status() == "saving" and session.snapshot() == baseline and session.last_result().is_empty(), "no early debit or success")
	_check(not session.stage_command("feed", "ray-1", "ui-2", int(baseline.revision), 0, marker), "overlap refused")
	var envelope: Dictionary = JSON.parse_string(p.payload)
	_check(int(envelope.model.food) == int(baseline.food) - cost and p.writes == 2, "actual feed payload debits once")
	p.ack()
	_check(session.poll(marker) and session.status() == "ready" and session.last_result().ok, "feed acknowledged")
	var saved: Dictionary = session.snapshot()
	_check(saved.food == int(baseline.food) - cost, "ack publishes debit")
	var bytes := p.payload
	var q := FakePort.new()
	var reopened = Session.new()
	_check(reopened.start(q), "reopen queued")
	q.deliver({"kind": "open", "ok": true, "status": "ready", "active": bytes, "previous": first_bytes})
	_check(reopened.poll(marker + 60000) and reopened.status() == "saving" and q.writes == 1, "resume stages offline settlement")
	_check(reopened.snapshot().is_empty(), "resumed state waits for ack")
	q.ack()
	_check(reopened.poll(marker + 60000) and reopened.status() == "ready", "resume confirmed")
	var resumed: Dictionary = reopened.snapshot()
	_check(resumed.food == saved.food and resumed.elapsed_ms == int(saved.elapsed_ms) + 60000, "restored food and eligible time")
	_check(reopened.stage_command("feed", "ray-1", "ui-1", int(baseline.revision), 0, marker + 60000), "same operation replay staged")
	q.ack()
	_check(reopened.poll(marker + 60000) and reopened.snapshot() == resumed, "replay did not debit again")
	_check(reopened.stage_tick(1000, marker + 61000), "timer-only checkpoint staged")
	var wrong: Dictionary = JSON.parse_string(q.payload)
	q.deliver({"kind": "write", "ok": true, "storage_revision": wrong.storage_revision, "observed_text": "wrong"})
	_check(not reopened.poll(marker + 61000) and reopened.status() == "unavailable", "wrong readback fails closed")
	_check(reopened.snapshot() == resumed and not reopened.stage_tick(1000, marker + 62000), "last good state retained; no retry")
	var bad := FakePort.new()
	var invalid = Session.new()
	invalid.start(bad)
	bad.deliver({"kind": "open", "ok": true, "status": "ready", "active": "damaged"})
	_check(not invalid.poll(marker) and invalid.status() == "unavailable" and bad.writes == 0, "corrupt active cannot initialize")
	var follower := FakePort.new()
	var readonly_session = Session.new()
	readonly_session.start(follower)
	follower.deliver({"kind": "open", "ok": false, "status": "read-only"})
	_check(readonly_session.poll(marker) and readonly_session.status() == "read-only" and follower.writes == 0, "second tab refuses writes")
	var refused := FakePort.new()
	refused.allow_write = false
	var failed = Session.new()
	failed.start(refused)
	refused.deliver({"kind": "open", "ok": true, "status": "missing", "active": null, "previous": null})
	_check(not failed.poll(marker) and failed.status() == "unavailable", "synchronous write refusal fails closed")
	_check(failed.snapshot().is_empty() and not failed.stage_tick(1, marker), "no blank city after refusal")
	_check(not session.start(p) and session.snapshot() == saved, "open cannot reset a live city")

	# Portable data contains the last confirmed city, not a browser-local generation.
	var backup: String = session.export_backup()
	var decoded: Dictionary = JSON.parse_string(backup)
	_check(decoded.size() == 4 and not decoded.has("storage_revision") and decoded.model.food == saved.food, "portable confirmed backup")
	var preview: Dictionary = session.preview_backup(backup)
	_check(preview.ok and preview.food == saved.food and preview.gold == saved.gold and preview.individual_count == saved.individuals.size(), "validated backup preview")
	var invalid_backup: Dictionary = decoded.duplicate(true)
	invalid_backup.version = 2
	_check(not session.preview_backup(JSON.stringify(invalid_backup)).ok, "newer backup version refused")
	invalid_backup = decoded.duplicate(true)
	invalid_backup.wall_marker_ms = -1
	_check(not session.preview_backup(JSON.stringify(invalid_backup)).ok, "negative backup marker refused")
	invalid_backup = decoded.duplicate(true)
	invalid_backup.model.food = -1
	_check(not session.preview_backup(JSON.stringify(invalid_backup)).ok, "invalid city data refused")
	invalid_backup = decoded.duplicate(true)
	invalid_backup.storage_revision = 99
	_check(not session.preview_backup(JSON.stringify(invalid_backup)).ok, "local generation injection refused")
	_check(not session.preview_backup("{").ok and not session.preview_backup("x".repeat(1048577)).ok, "malformed and oversized backups refused")
	_check(session.snapshot() == saved and p.writes == 2, "preview is side-effect free")
	_check(reopened.export_backup().is_empty() and failed.export_backup().is_empty() and readonly_session.export_backup().is_empty(), "unconfirmed sessions cannot export")
	_check(session.stage_tick(1, marker + 1) and session.export_backup().is_empty(), "in-flight checkpoint cannot export")
	p.ack()
	_check(session.poll(marker + 1) and not session.export_backup().is_empty(), "export resumes after ack")


	# Explicit restoration is separate from preview and from ordinary writes.
	var latest: Dictionary = session.snapshot()
	_check(not session.stage_restore(backup, preview.confirmation, marker + 2) and p.writes == 3, "intervening save invalidates preview")
	var restore_preview: Dictionary = session.preview_backup(backup)
	_check(not restore_preview.confirmation.is_empty(), "ready preview binds generation and bytes")
	_check(not session.stage_restore(backup + " ", restore_preview.confirmation, marker + 2), "changed bytes refused")
	_check(not session.stage_restore(backup, "", marker + 2), "missing confirmation refused")
	_check(not session.stage_restore(backup, restore_preview.confirmation, -1), "invalid restore clock refused")
	_check(not readonly_session.stage_restore(backup, restore_preview.confirmation, marker + 2), "second writer cannot restore")
	_check(session.snapshot() == latest and p.writes == 3, "rejected restores did not stage")
	_check(session.stage_restore(backup, restore_preview.confirmation, marker + 2), "confirmed restore queued")
	_check(session.status() == "saving" and session.snapshot() == latest and session.last_result().is_empty(), "restore hidden until acknowledgement")
	_check(not session.stage_restore(backup, restore_preview.confirmation, marker + 2), "overlapping restore refused")
	var restored_payload: Dictionary = JSON.parse_string(p.payload)
	_check(int(restored_payload.storage_revision) == 4 and int(restored_payload.model.revision) > int(latest.revision), "restore advances local generation and domain revision")
	_check(restored_payload.wall_marker_ms == marker + 2 and restored_payload.model.elapsed_ms == saved.elapsed_ms and restored_payload.model.food == saved.food, "restore exact domain timeline without extra income")
	p.ack()
	_check(session.poll(marker + 2) and session.status() == "ready" and session.last_result().ok, "restore acknowledged")
	_check(session.snapshot().food == saved.food and session.snapshot().elapsed_ms == saved.elapsed_ms and session.snapshot().receipts == saved.receipts, "restore publishes saved city and receipts")
	_check(not session.stage_restore(backup, restore_preview.confirmation, marker + 2), "used preview no longer valid")
	var restore_after: Dictionary = session.preview_backup(backup)
	var confirmed_restored: Dictionary = session.snapshot()
	_check(session.stage_restore(backup, restore_after.confirmation, marker + 3), "second explicit restore queued for fault test")
	var uncertain: Dictionary = JSON.parse_string(p.payload)
	p.deliver({"kind": "write", "ok": true, "storage_revision": uncertain.storage_revision, "observed_text": "wrong"})
	_check(not session.poll(marker + 3) and session.status() == "unavailable", "restore wrong readback fails closed")
	_check(session.snapshot() == confirmed_restored and session.export_backup().is_empty(), "uncertain restore preserves confirmed view and refuses export")

# A foreign device's wall-clock marker is metadata, not local offline credit.
# Include a local clock rollback to keep the existing high-water invariant.
func _run_import_clock() -> void:
	var marker := 1700000000000
	for fixture in [[marker + 86400000, marker], [9007199254740991, marker], [marker + 86400000, marker - 30000]]:
		var restore_wall: int = fixture[1]
		var port := FakePort.new()
		var session = Session.new()
		if not session.start(port):
			_check(false, "foreign clock: open failed")
			return
		port.deliver({"kind":"open", "ok":true, "status":"missing", "active":null, "previous":null})
		var opened: bool = session.poll(marker)
		_check(opened, "foreign clock: fresh checkpoint staged")
		if not opened:
			return
		port.ack()
		var ready: bool = session.poll(marker) and session.status() == "ready"
		_check(ready, "foreign clock: fresh checkpoint confirmed")
		if not ready:
			return
		var original: Dictionary = session.snapshot()
		var first_bytes := port.payload
		var backup: Dictionary = JSON.parse_string(session.export_backup())
		backup.wall_marker_ms = fixture[0]
		var encoded := JSON.stringify(backup, "", true, true)
		var preview: Dictionary = session.preview_backup(encoded)
		_check(preview.ok and not preview.confirmation.is_empty(), "foreign clock: preview valid")
		if not preview.ok:
			return
		var staged: bool = session.stage_restore(encoded, preview.confirmation, restore_wall)
		_check(staged, "foreign clock: explicit restore staged")
		if not staged:
			return
		var payload: Dictionary = JSON.parse_string(port.payload)
		_check(int(payload.wall_marker_ms) == marker, "foreign clock: local marker retained")
		_check(int(payload.model.elapsed_ms) == int(original.elapsed_ms), "foreign clock: no import bonus")
		port.ack()
		var confirmed: bool = session.poll(restore_wall) and session.status() == "ready"
		_check(confirmed, "foreign clock: restore confirmed")
		if not confirmed:
			return
		var second := FakePort.new()
		var reopened = Session.new()
		if not reopened.start(second):
			_check(false, "foreign clock: reopen failed")
			return
		second.deliver({"kind":"open", "ok":true, "status":"ready", "active":port.payload, "previous":first_bytes})
		var resumed: bool = reopened.poll(marker + 60000)
		_check(resumed, "foreign clock: local resume staged")
		if not resumed:
			return
		second.ack()
		var resumed_ready: bool = reopened.poll(marker + 60000) and reopened.status() == "ready"
		_check(resumed_ready and int(reopened.snapshot().get("elapsed_ms", -1)) == int(original.elapsed_ms) + 60000,
			"foreign clock: one minute local absence settled")

# A structurally valid envelope can still contain an unsupported city schema.
func _run_previous_validation() -> void:
	var marker := 1700000000000
	var model: Dictionary = City.new().snapshot()
	var active := JSON.stringify({"storage_revision": 2, "wall_marker_ms": marker, "model": model})
	var future: Dictionary = model.duplicate(true)
	future.checkpoint_schema = 3
	var invalid := JSON.stringify({"storage_revision": 1, "wall_marker_ms": marker, "model": future})
	for raw in [invalid, "damaged", null]:
		var port := FakePort.new()
		var session = Session.new()
		session.start(port)
		port.deliver({"kind":"open", "ok":true, "status":"ready", "active":active, "previous":raw})
		_check(not session.poll(marker) and session.status() == "unavailable" and port.writes == 0, "unsupported/missing predecessor refuses startup write")
		_check(session.snapshot().is_empty() and not session.stage_tick(1, marker + 1), "unsupported predecessor does not publish or allow retry")

# Restore a truly older domain revision, not just an older storage checkpoint.
# A paid action and a reward are rolled back together with their receipts.
# Reopening must keep the rebased revision and reject an abandoned command.
func _run_distinct_revision_rollback() -> void:
	var marker := 1700000000000
	var port := FakePort.new()
	var session = Session.new()
	_check(session.start(port), "rollback: open queued")
	port.deliver({"kind":"open", "ok":true, "status":"missing", "active":null, "previous":null})
	_check(session.poll(marker), "rollback: first write staged")
	port.ack()
	_check(session.poll(marker) and session.status() == "ready", "rollback: first write confirmed")
	var original: Dictionary = session.snapshot()
	var backup: String = session.export_backup()
	_check(not backup.is_empty(), "rollback: older backup exported")
	_check(session.stage_command("feed", "ray-1", "ui-1", int(original.revision), 0, marker), "rollback: later paid feed staged")
	port.ack()
	_check(session.poll(marker) and session.last_result().ok, "rollback: paid feed confirmed")
	var fed: Dictionary = session.snapshot()
	_check(int(fed.revision) > int(original.revision) and int(fed.food) < int(original.food), "rollback: feed advanced domain revision")
	_check(session.stage_command("sample", "", "ui-2", int(fed.revision), 0, marker), "rollback: later tutorial reward staged")
	port.ack()
	_check(session.poll(marker) and session.last_result().ok, "rollback: later reward confirmed")
	var later: Dictionary = session.snapshot()
	var later_bytes: String = port.payload
	_check(int(later.revision) > int(fed.revision) and int(later.gold) > int(original.gold) and later.receipts.has("ui-2"), "rollback: distinct newer revision and receipt")
	var preview: Dictionary = session.preview_backup(backup)
	_check(preview.ok and int(preview.domain_revision) < int(later.revision), "rollback: preview shows strictly older domain revision")
	_check(session.stage_restore(backup, preview.confirmation, marker), "rollback: explicit restore staged")
	var restored_bytes: String = port.payload
	var restored: Dictionary = JSON.parse_string(restored_bytes)
	var expected: Dictionary = original.duplicate(true)
	expected.revision = int(later.revision) + 1
	_check(int(restored.storage_revision) == int(JSON.parse_string(later_bytes).storage_revision) + 1 and int(restored.model.revision) == int(expected.revision), "rollback: both revisions advance over newer state")
	_check(session.snapshot() == later and session.status() == "saving", "rollback: newer state remains visible before ack")
	port.ack()
	_check(session.poll(marker) and session.snapshot() == expected and not session.snapshot().receipts.has("ui-2"), "rollback: exact earlier state and receipts restored with new revision")
	var next_port := FakePort.new()
	var reopened = Session.new()
	_check(reopened.start(next_port), "rollback: reopen queued")
	next_port.deliver({"kind":"open", "ok":true, "status":"ready", "active":restored_bytes, "previous":later_bytes})
	_check(reopened.poll(marker) and reopened.status() == "saving", "rollback: restored pair passes predecessor validation")
	next_port.ack()
	_check(reopened.poll(marker) and reopened.snapshot() == expected, "rollback: reload retains rebased state without reward replay")
	_check(reopened.stage_command("sample", "", "ui-2", int(later.revision), 0, marker), "rollback: stale abandoned command evaluated")
	next_port.ack()
	_check(reopened.poll(marker) and not reopened.last_result().ok and reopened.snapshot() == expected, "rollback: stale abandoned reward cannot replay")
	_check(reopened.stage_command("feed", "ray-1", "ui-3", int(expected.revision), 0, marker), "rollback: fresh command at rebased revision staged")
	next_port.ack()
	_check(reopened.poll(marker) and reopened.last_result().ok and int(reopened.snapshot().food) < int(expected.food), "rollback: fresh command succeeds after reload")
	var final_state: Dictionary = reopened.snapshot()
	_check(reopened.stage_command("feed", "ray-1", "ui-3", int(expected.revision), 0, marker), "rollback: replay of newly committed operation evaluated")
	next_port.ack()
	_check(reopened.poll(marker) and reopened.last_result().ok and reopened.snapshot() == final_state, "rollback: newly committed operation is idempotent")

func _run_recovery_choice() -> void:
	var marker := 1700000000000
	var seed: Dictionary = City.new().snapshot()
	var prior := JSON.stringify({"storage_revision": 2, "wall_marker_ms": marker, "model": seed})
	var port := FakePort.new()
	var session = Session.new()
	_check(session.start(port), "recovery opens writer")
	port.deliver({"kind":"open","ok":false,"status":"recovery-required","previous":prior})
	_check(session.poll(marker) and session.status() == "recovery-required", "validated previous offered")
	var preview: Dictionary = session.preview_recovery()
	_check(preview.get("ok", false) and preview.get("gold") == seed.gold and preview.get("food") == seed.food and preview.get("domain_revision") == seed.revision, "recovery preview matches selected city")
	_check(session.snapshot().is_empty() and port.writes == 0 and port.recoveries == 0, "preview does not publish or write")
	_check(not session.stage_tick(1, marker) and not session.stage_command("feed","ray-1","ui-1",0,0,marker), "ordinary writes fenced")
	_check(not session.stage_recovery("wrong", marker) and port.recoveries == 0, "incorrect confirmation refused")
	_check(session.stage_recovery(str(preview.get("confirmation", "")), marker + 1000), "explicit recovery queued")
	_check(session.status() == "recovering" and port.recovery_payload == prior and port.recovery_wall == marker + 1000, "exact predecessor bytes and sampled wall sent")
	_check(not session.stage_recovery(str(preview.get("confirmation", "")), marker) and port.recoveries == 1 and session.snapshot().is_empty(), "pending recovery cannot repeat or publish")
	var model: Dictionary = seed.duplicate(true)
	model.revision = int(model.revision) + 1
	var observed := JSON.stringify({"storage_revision": 3, "wall_marker_ms": marker + 1000, "model": model})
	port.deliver({"kind":"recovery","ok":true,"status":"recovered","storage_revision":3,"observed_text":observed})
	_check(session.poll(marker + 1000) and session.status() == "recovered" and session.last_result().ok, "exact recovery acknowledged")
	_check(session.snapshot().is_empty() and not session.stage_tick(1, marker) and session.export_backup().is_empty(), "recovered session requires reload")
	var reopen_port := FakePort.new()
	var reopened = Session.new()
	_check(reopened.start(reopen_port), "fresh recovery reload opens")
	reopen_port.deliver({"kind":"open","ok":true,"status":"ready","active":observed,"previous":prior})
	_check(reopened.poll(marker + 1000) and reopened.status() == "saving", "recovered pair validates for startup")
	reopen_port.ack()
	_check(reopened.poll(marker + 1000) and reopened.snapshot() == model, "reopen confirms selected city with rebased revision")
	var future: Dictionary = seed.duplicate(true)
	future.checkpoint_schema = 3
	var invalid := JSON.stringify({"storage_revision":2,"wall_marker_ms":marker,"model":future})
	var invalid_port := FakePort.new()
	var invalid_session = Session.new()
	invalid_session.start(invalid_port)
	invalid_port.deliver({"kind":"open","ok":false,"status":"recovery-required","previous":invalid})
	_check(not invalid_session.poll(marker) and invalid_session.status() == "unavailable" and invalid_port.recoveries == 0 and not invalid_session.preview_recovery().ok, "future domain predecessor never offered")
	var bad_port := FakePort.new()
	var bad_session = Session.new()
	bad_session.start(bad_port)
	bad_port.deliver({"kind":"open","ok":false,"status":"recovery-required","previous":prior})
	bad_session.poll(marker)
	var bad_preview: Dictionary = bad_session.preview_recovery()
	bad_session.stage_recovery(str(bad_preview.get("confirmation","")), marker + 1000)
	bad_port.deliver({"kind":"recovery","ok":true,"status":"recovered","storage_revision":3,"observed_text":JSON.stringify({"storage_revision":3,"wall_marker_ms":marker + 1001,"model":model})})
	_check(not bad_session.poll(marker) and bad_session.status() == "unavailable" and bad_session.snapshot().is_empty(), "unexpected readback fails closed")
	# A valid but different city with identical generation and marker must
	# still fail readback. This guards against weakening the equality check.
	var wrong_model: Dictionary = model.duplicate(true)
	wrong_model.gold = int(wrong_model.gold) + 1
	var wrong_port := FakePort.new()
	var wrong_session = Session.new()
	wrong_session.start(wrong_port)
	wrong_port.deliver({"kind":"open","ok":false,"status":"recovery-required","previous":prior})
	wrong_session.poll(marker)
	var wrong_preview: Dictionary = wrong_session.preview_recovery()
	_check(City.validate_snapshot(wrong_model) and wrong_session.stage_recovery(str(wrong_preview.get("confirmation","")), marker + 1000), "valid wrong-model readback fixture staged")
	wrong_port.deliver({"kind":"recovery","ok":true,"status":"recovered","storage_revision":3,"observed_text":JSON.stringify({"storage_revision":3,"wall_marker_ms":marker + 1000,"model":wrong_model})})
	_check(not wrong_session.poll(marker) and wrong_session.status() == "unavailable" and wrong_session.snapshot().is_empty(), "same-generation changed city rejected")
	var refused_port := FakePort.new()
	refused_port.allow_recovery = false
	var refused = Session.new()
	refused.start(refused_port)
	refused_port.deliver({"kind":"open","ok":false,"status":"recovery-required","previous":prior})
	refused.poll(marker)
	var refused_preview: Dictionary = refused.preview_recovery()
	_check(not refused.stage_recovery(str(refused_preview.get("confirmation","")), marker) and refused.status() == "unavailable", "queue refusal fences session")
