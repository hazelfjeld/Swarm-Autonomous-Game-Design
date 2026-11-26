extends SceneTree
## Diagnostic integration test. The CI runner copies these two exact-source
## scripts into a temporary project; neither role's checkout is edited.
const City = preload("res://city_model.gd")
const Commit = preload("res://profile_commit.gd")
var checks := 0
var failures: Array[String] = []

func _check(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures.append(label)

func _valid_city(raw: Dictionary) -> bool:
	return City.validate_snapshot(raw)

func _initialize() -> void:
	_run()
	print(JSON.stringify({"city_profile_bridge": "pass" if failures.is_empty() else "fail", "checks": checks, "failures": failures}))
	quit(0 if failures.is_empty() else 1)

func _run() -> void:
	var city := City.new()
	var marker := 1700000000000
	var baseline: Dictionary = city.snapshot()
	var boundary := Commit.new(_valid_city)
	var initialized: bool = boundary.initialize(baseline, 0, marker)
	_check(initialized, "real fresh city validates")
	if not initialized:
		return
	# A paid feed is prepared on a detached domain instance.
	var staged := City.new()
	var restored: bool = staged.restore_snapshot(boundary.committed().model)
	_check(restored, "committed city restores")
	if not restored:
		return
	var cost: int = staged.feed_cost("ray-1")
	var feed: Dictionary = staged.command("feed", "ray-1", "ui-1", int(baseline.revision))
	_check(feed.ok and cost > 0 and staged.food == int(baseline.food) - cost, "paid feed on staged city")
	var pending: Dictionary = boundary.begin(staged.snapshot(), 0, marker)
	_check(pending.ok, "real candidate stages")
	if not pending.ok:
		return
	_check(city.snapshot() == baseline and boundary.committed().model == baseline, "no publication before confirmation")
	# Actual local file I/O for the round-trip fixture only. This is not
	# the browser transaction implementation or a power-loss durability test.
	var path := "user://arch002-city-bridge-%s.json" % Time.get_ticks_usec()
	var file := FileAccess.open(path, FileAccess.WRITE)
	_check(file != null, "fixture file opens")
	if file == null:
		return
	file.store_string(pending.payload)
	file.flush()
	var write_ok := file.get_error() == OK
	file.close()
	var observed := FileAccess.get_file_as_string(path)
	DirAccess.remove_absolute(path)
	_check(write_ok and observed == pending.payload, "actual fixture bytes match")
	_check(not boundary.confirm(0, observed) and boundary.status() == "saving", "stale confirmation ignored")
	var confirmed: bool = boundary.confirm(1, observed)
	_check(confirmed, "matching generation confirms")
	var loaded := Commit.new(_valid_city)
	var read_ok: bool = loaded.initialize_from_text(observed)
	_check(read_ok, "actual city envelope reload validates")
	if not read_ok:
		return
	var resumed := City.new()
	var resume_ok: bool = resumed.restore_snapshot(loaded.committed().model)
	_check(resume_ok, "JSON-normalized city restores")
	if not resume_ok:
		return
	_check(resumed.snapshot() == staged.snapshot(), "complete city snapshot roundtrip")
	var before_replay: Dictionary = resumed.snapshot()
	var replay: Dictionary = resumed.command("feed", "ray-1", "ui-1", int(baseline.revision))
	_check(replay.ok and resumed.snapshot() == before_replay, "replayed operation does not debit twice")
	var gap: Dictionary = Commit.offline_budget(int(loaded.committed().wall_marker_ms), marker + 60000)
	_check(gap.ok and gap.elapsed_ms == 60000, "offline budget derived from persisted marker")
	resumed.advance(int(gap.elapsed_ms))
	_check(int(resumed.snapshot().elapsed_ms) == int(before_replay.elapsed_ms) + 60000, "real city consumes offline budget")
	var tick: Dictionary = loaded.begin(resumed.snapshot(), 1, int(gap.wall_marker_ms))
	_check(tick.ok, "offline city checkpoint stages")
	if not tick.ok:
		return
	# Simulated acknowledgement, expressly not a second file transaction.
	_check(loaded.confirm(2, tick.payload), "offline checkpoint confirmation contract")
	var again: Dictionary = Commit.offline_budget(int(loaded.committed().wall_marker_ms), marker + 60000)
	_check(again.ok and again.elapsed_ms == 0, "same resume cannot repeat credit")
	var malformed: Dictionary = JSON.parse_string(tick.payload)
	malformed.model.food = -1
	var rejected := Commit.new(_valid_city)
	_check(not rejected.initialize_from_text(JSON.stringify(malformed)) and rejected.status() == "unavailable", "domain-invalid envelope fails closed")
	_check(not rejected.initialize(baseline, 0, marker), "failed recovery cannot silently reset")
