extends SceneTree

const State = preload("res://probe_state.gd")
const Store = preload("res://probe_store.gd")
var failures: Array[String] = []

func _initialize() -> void:
	var root := "user://test_%s" % Time.get_ticks_usec()
	DirAccess.make_dir_recursive_absolute(root)
	var path := root + "/probe.json"
	var store = Store.new(path)
	var state := State.fresh()
	state.greetings = 42
	_check(store.save(state).ok, "save succeeds")
	_check(Store.new(path).load_state().get("state", {}) == state, "new store reloads exact individual and value")
	var backup: String = JSON.stringify(state)
	state.greetings = 43
	_check(store.save(state).ok, "second save succeeds")
	var imported: Dictionary = store.decode(backup)
	_check(imported.ok and store.save(imported.state).ok, "backup restore succeeds")
	_check(Store.new(path).load_state().get("state", {}).get("greetings") == 42, "backup restores original count")
	_check(store.decode(FileAccess.get_file_as_string(path + ".previous")).state.greetings == 43, "previous value retained")
	var before := FileAccess.get_file_as_string(path)
	for bad in ["{broken", backup.replace('"schema_version":1', '"schema_version":2'), backup.replace('"greetings":42', '"greetings":-1')]:
		_check(not store.decode(bad).ok, "invalid backup rejected")
	_check(FileAccess.get_file_as_string(path) == before, "rejected imports preserve active bytes")
	store.fail_writes = true
	_check(not store.save(state).ok and FileAccess.get_file_as_string(path) == before, "simulated failure preserves active bytes")
	_check(not Store.new(root + "/missing/probe.json").save(state).ok, "real missing-directory write failure is reported")
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(backup.replace('"schema_version":1', '"schema_version":2'))
	file.close()
	store.fail_writes = false
	_check(not store.load_state().ok and not store.save(state).ok, "unsupported existing save blocks overwrite")
	_check(FileAccess.get_file_as_string(path).contains('"schema_version":2'), "unsupported existing bytes preserved")
	for suffix in ["", ".tmp", ".previous"]:
		if FileAccess.file_exists(path + suffix):
			DirAccess.remove_absolute(path + suffix)
	DirAccess.remove_absolute(root)
	print(JSON.stringify({"probe_store_tests": "pass" if failures.is_empty() else "fail", "failures": failures}))
	quit(0 if failures.is_empty() else 1)

func _check(ok: bool, description: String) -> void:
	if not ok:
		failures.append(description)
