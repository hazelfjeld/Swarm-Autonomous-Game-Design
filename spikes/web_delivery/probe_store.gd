extends RefCounted

const State = preload("res://probe_state.gd")
const TimerState = preload("res://probe_timer.gd")
var path: String
var fail_writes := false

func _init(save_path: String = "user://delivery_probe.json") -> void:
	path = save_path

func decode(text: String) -> Dictionary:
	if text.length() > 16384:
		return {"ok": false, "reason": "Probe backup is too large."}
	var parser := JSON.new()
	if parser.parse(text) != OK:
		return {"ok": false, "reason": "Invalid JSON; current save unchanged."}
	var error := State.validate(parser.data)
	if not error.is_empty():
		return {"ok": false, "reason": error}
	var decoded: Dictionary = parser.data.duplicate(true)
	decoded.schema_version = 1
	decoded.greetings = int(decoded.greetings)
	decoded.timer = TimerState.normalized(decoded.timer) if decoded.has("timer") else TimerState.fresh()
	return {"ok": true, "state": decoded}

func load_state() -> Dictionary:
	if not FileAccess.file_exists(path):
		return {"ok": true, "state": State.fresh(), "reason": "Not saved yet."}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"ok": false, "reason": "Save unavailable: existing file cannot be read."}
	var result := decode(file.get_as_text())
	file.close()
	result["reason"] = "Loaded probe save." if result.ok else "Save unavailable: " + result.reason
	return result

func save(candidate: Dictionary) -> Dictionary:
	var validation := State.validate(candidate)
	if not validation.is_empty():
		return {"ok": false, "reason": validation}
	if fail_writes:
		return {"ok": false, "reason": "Save unavailable (simulated); value unchanged."}
	# Never overwrite a malformed/newer existing save with a fresh profile.
	if FileAccess.file_exists(path) and not load_state().ok:
		return {"ok": false, "reason": "Save unavailable: existing file preserved for recovery."}
	var encoded := JSON.stringify(candidate)
	var error := _write(path + ".tmp", encoded)
	if error != OK:
		return {"ok": false, "reason": "Save unavailable: temporary write failed (%s)." % error}
	if not decode(FileAccess.get_file_as_string(path + ".tmp")).get("ok", false):
		return {"ok": false, "reason": "Save unavailable: temporary verification failed."}
	if FileAccess.file_exists(path):
		error = _write(path + ".previous", FileAccess.get_file_as_string(path))
		if error != OK:
			return {"ok": false, "reason": "Save unavailable: recovery copy failed."}
	error = DirAccess.rename_absolute(path + ".tmp", path)
	if error != OK:
		return {"ok": false, "reason": "Save unavailable: replace failed (%s)." % error}
	return {"ok": true, "reason": "Written — reload to verify persistence." if OS.has_feature("web") else "Saved locally."}

func _write(target: String, text: String) -> Error:
	var file := FileAccess.open(target, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(text)
	file.flush()
	var error := file.get_error()
	file.close()
	return error
