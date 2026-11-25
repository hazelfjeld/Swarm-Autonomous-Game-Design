extends SceneTree

const State = preload("res://probe_state.gd")
const Store = preload("res://probe_store.gd")
const TimerState = preload("res://probe_timer.gd")
var failures: Array[String] = []

func _initialize() -> void:
	var root := "user://test_%s" % Time.get_ticks_usec()
	DirAccess.make_dir_recursive_absolute(root)
	var path := root + "/probe.json"
	var store = Store.new(path)
	var state := State.fresh()
	state.greetings = 42
	var first: Dictionary = store.save(state, 0)
	_check(first.ok and first.get("state", {}).get("revision") == 1, "first save assigns revision one")
	_check(Store.new(path).load_state().get("state", {}) == first.get("state", {}), "new store reloads exact individual and value")
	var backup: String = JSON.stringify(first.get("state", {}))
	state.greetings = 43
	var second: Dictionary = store.save(state, 1)
	_check(second.ok and second.get("state", {}).get("revision") == 2, "second save increments revision")
	var active_bytes := FileAccess.get_file_as_string(path)
	var previous_bytes := FileAccess.get_file_as_string(path + ".previous")
	var stale: Dictionary = Store.new(path).save(state, 1)
	_check(not stale.ok and FileAccess.get_file_as_string(path) == active_bytes and FileAccess.get_file_as_string(path + ".previous") == previous_bytes, "stale revision rejects without changing either file")
	var imported: Dictionary = store.decode(backup)
	var restored: Dictionary = store.save(imported.state, 2) if imported.ok else {"ok": false}
	_check(restored.ok and restored.get("state", {}).get("revision") == 3, "backup restore increments rather than rewinds revision")
	_check(Store.new(path).load_state().get("state", {}).get("greetings") == 42, "backup restores original count")
	_check(store.decode(FileAccess.get_file_as_string(path + ".previous")).state.greetings == 43, "previous value retained")
	# A real 12-hour deadline, with injected clocks (no waiting).
	var wall := 1700000000000
	var duration := 12 * 60 * 60 * 1000
	var timed := State.fresh()
	timed.timer = TimerState.start(timed.timer, duration, wall)
	_check(timed.timer.phase == "running", "timer starts")
	_check(_save_current(store, timed).ok, "running timer saved")
	var loaded_timer: Dictionary = Store.new(path).load_state().state.timer
	_check(loaded_timer == timed.timer, "running timer reload exact")
	var halfway := TimerState.resume(loaded_timer, wall + duration / 2)
	_check(halfway.remaining_ms == duration / 2, "offline partial elapsed")
	_check(TimerState.resume(halfway, wall + duration / 2) == halfway, "same resume cannot credit again")
	_check(TimerState.resume(halfway, wall) == halfway, "clock rollback cannot credit or regress")
	var active := TimerState.advance_active(halfway, 1000, wall + duration / 2 + 1000)
	_check(active.remaining_ms == duration / 2 - 1000, "injected active monotonic elapsed")
	var ready := TimerState.resume(active, wall + duration)
	_check(ready.phase == "ready" and ready.remaining_ms == 0, "12-hour deadline completes")
	_check(TimerState.resume(ready, wall + duration * 2) == ready, "ready timer stays ready")
	var capped := TimerState.start(TimerState.fresh(), TimerState.MAX_ELAPSED_MS, wall)
	capped = TimerState.resume(capped, wall + TimerState.MAX_ELAPSED_MS * 2)
	_check(capped.phase == "ready" and capped.wall_marker_ms == wall + TimerState.MAX_ELAPSED_MS * 2, "large gap settles once and discards excess")
	timed.timer = TimerState.claim(ready)
	_check(timed.timer.phase == "claimed" and TimerState.claim(timed.timer) == timed.timer, "claim is one transition")
	_check(_save_current(store, timed).ok and Store.new(path).load_state().state.timer == timed.timer, "claimed timer persists")
	_check(TimerState.start(timed.timer, duration, wall) == timed.timer, "cannot restart claimed diagnostic")
	var legacy := State.fresh()
	legacy.erase("timer")
	legacy.erase("revision")
	_check(store.decode(JSON.stringify(legacy)).state.revision == 0, "old schema-1 probe defaults to revision zero")
	for bad_revision in [-1, 1.5, "1", State.MAX_REVISION + 1]:
		var invalid_revision := legacy.duplicate(true)
		invalid_revision.revision = bad_revision
		_check(not store.decode(JSON.stringify(invalid_revision)).ok, "invalid revision rejected")
	_check(store.decode(JSON.stringify(legacy)).state.timer == TimerState.fresh(), "old schema-1 probe defaults to idle")
	var malformed := timed.duplicate(true)
	malformed.timer.remaining_ms = -1
	_check(not store.decode(JSON.stringify(malformed)).ok, "invalid timer backup rejected")
	_check(_save_current(store, state).ok, "restore greeting fixture for existing failure checks")
	var before := FileAccess.get_file_as_string(path)
	for bad in ["{broken", backup.replace('"schema_version":1', '"schema_version":2'), backup.replace('"greetings":42', '"greetings":-1')]:
		_check(not store.decode(bad).ok, "invalid backup rejected")
	_check(FileAccess.get_file_as_string(path) == before, "rejected imports preserve active bytes")
	store.fail_writes = true
	_check(not _save_current(store, state).ok and FileAccess.get_file_as_string(path) == before, "simulated failure preserves active bytes")
	_check(not Store.new(root + "/missing/probe.json").save(state, 0).ok, "real missing-directory write failure is reported")
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(backup.replace('"schema_version":1', '"schema_version":2'))
	file.close()
	store.fail_writes = false
	_check(not store.load_state().ok and not _save_current(store, state).ok, "unsupported existing save blocks overwrite")
	_check(FileAccess.get_file_as_string(path).contains('"schema_version":2'), "unsupported existing bytes preserved")
	for suffix in ["", ".tmp", ".previous"]:
		if FileAccess.file_exists(path + suffix):
			DirAccess.remove_absolute(path + suffix)
	DirAccess.remove_absolute(root)
	print(JSON.stringify({"probe_store_tests": "pass" if failures.is_empty() else "fail", "failures": failures}))
	quit(0 if failures.is_empty() else 1)

func _save_current(store: Store, candidate: Dictionary) -> Dictionary:
	var loaded: Dictionary = store.load_state()
	return store.save(candidate, int(loaded.state.revision) if loaded.ok else -1)

func _check(ok: bool, description: String) -> void:
	if not ok:
		failures.append(description)
