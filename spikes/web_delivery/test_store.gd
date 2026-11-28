extends SceneTree

const State = preload("res://probe_state.gd")
const Store = preload("res://probe_store.gd")
const TimerState = preload("res://probe_timer.gd")
const ProfileCommit = preload("res://profile_commit.gd")
var failures: Array[String] = []

func _initialize() -> void:
	_profile_commit_tests()
	_profile_read_tests()
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

## Domain fixture only; the real city owns its complete validator and restore.
func _valid_profile_fixture(value: Dictionary) -> bool:
	var gold: Variant = value.get("gold")
	return (gold is int or gold is float) and is_finite(float(gold)) and float(gold) == floor(float(gold)) and gold >= 0 and value.get("receipts") is Dictionary

func _profile_commit_tests() -> void:
	var marker := 1700000000000
	var snapshot := {"revision": 7, "gold": 1200, "receipts": {"ui-1": "collect"}}
	var commit := ProfileCommit.new(_valid_profile_fixture)
	_check(not commit.begin(snapshot, 0, marker).ok, "uninitialized profile refuses writes")
	_check(not commit.initialize({"revision": 7, "gold": -1}, 0, marker), "invalid initial model refused")
	_check(commit.initialize(snapshot, 12, marker), "validated profile initialized")
	_check(not commit.initialize(snapshot, 0, marker), "cannot reinitialize live commit boundary")
	snapshot.gold = 1
	_check(commit.committed().model.gold == 1200, "initial snapshot copied")
	var detached := commit.committed()
	detached.model.receipts.clear()
	_check(commit.committed().model.receipts.has("ui-1"), "read projection detached")
	var rollback := ProfileCommit.offline_budget(marker, marker - 1000)
	_check(rollback.ok and rollback.elapsed_ms == 0 and rollback.wall_marker_ms == marker, "clock rollback retains high-water marker")
	var twelve := ProfileCommit.offline_budget(marker, marker + 43200000)
	_check(twelve.ok and twelve.elapsed_ms == 43200000, "twelve-hour offline gap supported")
	var capped := ProfileCommit.offline_budget(marker, marker + 1209600000)
	_check(capped.ok and capped.elapsed_ms == 604800000 and capped.wall_marker_ms == marker + 1209600000, "seven-day gap cap discards excess")
	_check(ProfileCommit.offline_budget(capped.wall_marker_ms, capped.wall_marker_ms).elapsed_ms == 0, "same resume cannot credit elapsed twice")
	_check(not ProfileCommit.offline_budget(-1, marker).ok, "invalid clock rejected")
	var candidate: Dictionary = commit.committed().model
	candidate.gold = 1210
	_check(not commit.begin(candidate, 11, marker).ok, "stale storage revision refused")
	_check(not commit.begin(candidate, 12, marker - 1).ok, "wall marker cannot regress")
	candidate.revision = 6
	_check(not commit.begin(candidate, 12, marker).ok, "domain revision cannot regress")
	candidate.revision = 7
	candidate.gold = -1
	_check(not commit.begin(candidate, 12, marker).ok, "invalid candidate refused")
	candidate.gold = 1210
	var first := commit.begin(candidate, 12, marker + 1000)
	_check(first.ok and first.storage_revision == 13 and commit.status() == "saving", "time-only checkpoint has separate storage generation")
	_check(commit.committed().model.gold == 1200, "pending candidate not published")
	candidate.gold = 999
	_check(not commit.begin(candidate, 12, marker + 1000).ok, "concurrent stage refused")
	_check(not commit.confirm(12, first.payload) and commit.status() == "saving", "stale confirmation ignored")
	_check(not commit.mark_unknown(12) and commit.status() == "saving", "stale failure ignored")
	_check(commit.confirm(13, first.payload) and commit.status() == "ready", "exact observed payload confirms")
	_check(commit.committed().model.gold == 1210 and commit.committed().model.revision == 7 and commit.committed().wall_marker_ms == marker + 1000, "confirmed snapshot and clock published atomically")
	_check(not commit.confirm(13, first.payload), "duplicate confirmation ignored")
	candidate = commit.committed().model
	candidate.revision = 8
	candidate.gold = 1190
	var second := commit.begin(candidate, 13, marker + 2000)
	_check(second.ok and not commit.confirm(14, first.payload) and commit.status() == "unavailable", "mismatched active bytes fail closed")
	_check(commit.committed().storage_revision == 13 and commit.committed().model.gold == 1210, "unknown write retains last confirmed projection")
	_check(not commit.begin(candidate, 13, marker + 2000).ok and not commit.confirm(14, second.payload), "unknown outcome requires explicit reconciliation")
	var recovered := ProfileCommit.new(_valid_profile_fixture)
	_check(recovered.initialize(candidate, 14, marker + 2000), "explicit reconciled read starts new boundary")
	var third := recovered.begin(candidate, 14, marker + 3000)
	_check(third.ok and recovered.mark_unknown(15) and recovered.status() == "unavailable", "timeout/refusal locks further writes")
	_check(recovered.committed().storage_revision == 14, "timeout does not claim new generation committed")

## Reconcile actual serialized bytes, not trusted caller-provided counters.
func _profile_read_tests() -> void:
	var marker := 1700000000000
	var snapshot := {"revision": 7, "gold": 1200, "receipts": {"ui-1000": "collect"}}
	var original := ProfileCommit.new(_valid_profile_fixture)
	_check(original.initialize(snapshot, 12, marker), "recovery fixture initialized")
	var next := original.begin(snapshot, 12, marker + 1000)
	_check(next.ok, "serialized envelope prepared")
	var loaded := ProfileCommit.new(_valid_profile_fixture)
	_check(loaded.initialize_from_text(next.payload) and loaded.status() == "ready", "valid serialized envelope read")
	_check(loaded.committed().storage_revision == 13 and loaded.committed().wall_marker_ms == marker + 1000, "loaded generation and marker exact")
	_check(loaded.committed().model.gold == 1200 and loaded.committed().model.receipts.has("ui-1000"), "domain state and receipt survive JSON")
	_check(not loaded.initialize_from_text(next.payload) and loaded.status() == "ready", "live state cannot be reinitialized from text")
	var continued := loaded.begin(snapshot, 13, marker + 2000)
	_check(continued.ok and continued.storage_revision == 14, "loaded generation is next write authority")
	var bad_inputs: Array[String] = ["", "{broken", "null", "[]", "{}"]
	var valid: Dictionary = JSON.parse_string(next.payload)
	for field in ["storage_revision", "wall_marker_ms", "model"]:
		var missing := valid.duplicate(true)
		missing.erase(field)
		bad_inputs.append(JSON.stringify(missing))
	for field in ["storage_revision", "wall_marker_ms"]:
		for invalid in [-1, 0.5, "13", true, null, 9007199254740992]:
			var malformed := valid.duplicate(true)
			malformed[field] = invalid
			bad_inputs.append(JSON.stringify(malformed))
	var extra := valid.duplicate(true)
	extra["unexpected"] = 1
	bad_inputs.append(JSON.stringify(extra))
	var bad_model := valid.duplicate(true)
	bad_model.model.gold = -1
	bad_inputs.append(JSON.stringify(bad_model))
	bad_model = valid.duplicate(true)
	bad_model.model.revision = "7"
	bad_inputs.append(JSON.stringify(bad_model))
	bad_model = valid.duplicate(true)
	bad_model.model = []
	bad_inputs.append(JSON.stringify(bad_model))
	for index in range(bad_inputs.size()):
		var blocked := ProfileCommit.new(_valid_profile_fixture)
		_check(not blocked.initialize_from_text(bad_inputs[index]) and blocked.status() == "unavailable", "malformed persisted envelope blocked %s" % index)
		_check(blocked.committed().is_empty() and not blocked.initialize(snapshot, 0, marker) and not blocked.begin(snapshot, 0, marker).ok, "malformed storage cannot become blank writable profile %s" % index)
		_check(not blocked.initialize_from_text(next.payload), "failed reader requires explicit new recovery instance %s" % index)
	var recovered := ProfileCommit.new(_valid_profile_fixture)
	_check(recovered.initialize_from_text(next.payload), "explicit fresh recovery reader accepts valid reconciled bytes")
