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
	_check(checks == 37, "all native session scenarios reached")
	print(JSON.stringify({"city_profile_session": "pass" if failures.is_empty() else "fail", "checks": checks, "failures": failures}))
	quit(0 if failures.is_empty() else 1)

func _run() -> void:
	var marker := 1700000000000
	var p := FakePort.new()
	var session = Session.new()
	_check(session.start(p) and session.status() == "opening", "open queued")
	_check(session.snapshot().is_empty() and not session.poll(marker), "no city before read")
	p.deliver({"kind": "open", "ok": true, "status": "missing", "active": null})
	_check(session.poll(marker) and session.status() == "saving" and p.writes == 1, "verified missing stages first save")
	_check(session.snapshot().is_empty(), "fresh city hidden until durable ack")
	p.ack()
	if not session.poll(marker):
		_check(false, "first save ack")
		return
	_check(session.status() == "ready" and session.snapshot() == City.new().snapshot(), "fresh city published after ack")
	var baseline: Dictionary = session.snapshot()
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
	q.deliver({"kind": "open", "ok": true, "status": "ready", "active": bytes})
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
	refused.deliver({"kind": "open", "ok": true, "status": "missing", "active": null})
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

