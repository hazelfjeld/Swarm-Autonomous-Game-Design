extends RefCounted
## ARCH-002 city-facing persistence candidate. Copy alongside the exact
## gameplay city_model.gd and profile_commit.gd in the integration project.
## The browser shell must expose createGodotProfilePort(() => openProfileSession(...))
## as window.littleRayCityProfilePort before the Godot scene opens it.
## The visible snapshot and command result change only after durable readback.
## The gameplay view owns rendering, UI operation IDs, and monotonic time sampling.
const City = preload("res://city_model.gd")
const Commit = preload("res://profile_commit.gd")
var _port: Variant
var _boundary = Commit.new(_valid_city)
var _status := "new"
var _visible: Dictionary = {}
var _last_result: Dictionary = {}
var _pending_result: Dictionary = {}
var _pending_generation := 0

func _valid_city(raw: Dictionary) -> bool:
	return City.validate_snapshot(raw)

func status() -> String:
	return _status

func snapshot() -> Dictionary:
	return _visible.duplicate(true)

func last_result() -> Dictionary:
	return _last_result.duplicate(true)

func _valid_time(value: int) -> bool:
	return value >= 0 and value <= Commit.MAX_INTEGER

func start_web() -> bool:
	if not OS.has_feature("web"):
		return false
	return start(JavaScriptBridge.get_interface("littleRayCityProfilePort"))

## Port methods are synchronous; the actual browser operations are async.
## A native test can supply an ordinary object with the same three methods.
func start(port: Variant) -> bool:
	if _status != "new":
		return false
	if port == null:
		_fail()
		return false
	_port = port
	_status = "opening"
	if _port.begin_open() != true:
		_fail()
		return false
	return true

func _fail() -> void:
	if _status == "saving":
		_boundary.mark_unknown(_pending_generation)
	_pending_result = {}
	_last_result = {"ok": false, "message": "Save unavailable. Reload to reconcile."}
	_status = "unavailable"

## Call each frame while opening/saving. At open, observed_wall_ms is the
## current wall time, not a duration. A new or resumed city is staged before
## publishing any playable state, including its offline settlement.
func poll(observed_wall_ms: int) -> bool:
	if _status != "opening" and _status != "saving":
		return false
	var encoded: Variant = _port.take_result()
	if not encoded is String:
		_fail()
		return false
	if encoded.is_empty():
		return false
	var reply: Variant = JSON.parse_string(encoded)
	if not reply is Dictionary:
		_fail()
		return false
	if _status == "opening" and reply.get("kind") == "open" and reply.get("status") == "read-only":
		_status = "read-only"
		_last_result = {"ok": false, "message": "Another tab owns this city. Close it and reload."}
		return true
	if reply.get("ok") != true:
		_fail()
		return false
	if _status == "opening":
		if reply.get("kind") != "open" or not _valid_time(observed_wall_ms):
			_fail()
			return false
		var city = City.new()
		if reply.get("status") == "missing" and reply.has("active") and reply.active == null:
			if not _boundary.initialize(city.snapshot(), 0, observed_wall_ms):
				_fail()
				return false
		elif reply.get("status") == "ready" and reply.get("active") is String:
			if not _boundary.initialize_from_text(reply.active):
				_fail()
				return false
		else:
			_fail()
			return false
		var committed: Dictionary = _boundary.committed()
		if not city.restore_snapshot(committed.model):
			_fail()
			return false
		var budget: Dictionary = Commit.offline_budget(int(committed.wall_marker_ms), observed_wall_ms)
		if not budget.ok:
			_fail()
			return false
		city.advance(int(budget.elapsed_ms))
		return _stage(city.snapshot(), int(budget.wall_marker_ms), {"ok": true, "message": "City loaded."})
	var generation: Variant = reply.get("storage_revision")
	if reply.get("kind") != "write" or not (generation is int or generation is float) or generation != _pending_generation or not reply.get("observed_text") is String:
		_fail()
		return false
	if not _boundary.confirm(_pending_generation, reply.observed_text):
		_fail()
		return false
	_visible = _boundary.committed().model
	_last_result = _pending_result.duplicate(true)
	_pending_result = {}
	_status = "ready"
	return true

func _stage(candidate: Dictionary, wall_marker_ms: int, result: Dictionary) -> bool:
	var generation: int = int(_boundary.committed().storage_revision)
	var pending: Dictionary = _boundary.begin(candidate, generation, wall_marker_ms)
	if not pending.ok:
		_fail()
		return false
	_pending_generation = int(pending.storage_revision)
	_pending_result = result.duplicate(true)
	_last_result = {}
	_status = "saving"
	if _port.begin_write(pending.payload) != true:
		_fail()
		return false
	return true

## True means queued, never committed. While saving, reject further input.
## elapsed_ms is monotonic time since the last staged sample; the caller must
## retain elapsed time while saving and submit it on the next accepted call.
## The expected revision is from the visible state, not a detached city.
## A command can be rejected by the domain while independent elapsed-time
## effects still require a checkpoint; inspect last_result only after ready.
func stage_command(kind: String, argument: String, op_id: String, expected_revision: int, elapsed_ms: int, observed_wall_ms: int) -> bool:
	if _status != "ready" or not _valid_time(elapsed_ms) or not _valid_time(observed_wall_ms):
		return false
	var committed: Dictionary = _boundary.committed()
	var city = City.new()
	if not city.restore_snapshot(committed.model):
		_fail()
		return false
	var prior_revision: int = city.revision
	city.advance(elapsed_ms)
	# An automatic deadline may change the revision during this very command.
	# Only a revision matching the previously visible snapshot is rebased.
	var revision_for_command: int = city.revision if expected_revision == prior_revision else expected_revision
	# Do not allow a future revision supplied by a stale/invalid caller to
	# accidentally match a revision reached by this local time settlement.
	if expected_revision != prior_revision and revision_for_command == city.revision:
		revision_for_command = -1
	var result: Dictionary = city.command(kind, argument, op_id, revision_for_command)
	return _stage(city.snapshot(), maxi(int(committed.wall_marker_ms), observed_wall_ms), result)

## A timer-only checkpoint uses the same transaction and acknowledgement.
func stage_tick(elapsed_ms: int, observed_wall_ms: int) -> bool:
	if _status != "ready" or not _valid_time(elapsed_ms) or not _valid_time(observed_wall_ms):
		return false
	var committed: Dictionary = _boundary.committed()
	var city = City.new()
	if not city.restore_snapshot(committed.model):
		_fail()
		return false
	city.advance(elapsed_ms)
	return _stage(city.snapshot(), maxi(int(committed.wall_marker_ms), observed_wall_ms), {"ok": true, "message": "City checkpoint saved."})

## Portable data only, deliberately independent of local storage generation.
## Export a confirmed profile, never a pending or uncertain transaction.
const BACKUP_FORMAT := "little-ray-city-backup"
const BACKUP_VERSION := 1
const MAX_BACKUP_BYTES := 1048576

func export_backup() -> String:
	if _status != "ready":
		return ""
	var confirmed: Dictionary = _boundary.committed()
	var encoded := JSON.stringify({"format": BACKUP_FORMAT, "version": BACKUP_VERSION,
		"wall_marker_ms": confirmed.wall_marker_ms, "model": confirmed.model}, "", true, true)
	if encoded.to_utf8_buffer().size() > MAX_BACKUP_BYTES:
		return ""
	return encoded

## Read-only preview. Do not pass the backup directly to the normal write
## path: explicit replacement must reconcile local generations and preserve
## the previous-good recovery copy in its own transaction.
func preview_backup(encoded: String) -> Dictionary:
	if encoded.is_empty() or encoded.to_utf8_buffer().size() > MAX_BACKUP_BYTES:
		return {"ok": false, "reason": "Backup empty or too large."}
	var parser := JSON.new()
	if parser.parse(encoded) != OK:
		return {"ok": false, "reason": "Backup is not valid JSON."}
	var raw: Variant = parser.data
	if not raw is Dictionary or raw.size() != 4 or not raw.has_all(["format", "version", "wall_marker_ms", "model"]):
		return {"ok": false, "reason": "Unrecognized backup format."}
	if raw.format != BACKUP_FORMAT or not Commit._whole(raw.version) or int(raw.version) != BACKUP_VERSION:
		return {"ok": false, "reason": "Unsupported backup version."}
	if not Commit._whole(raw.wall_marker_ms):
		return {"ok": false, "reason": "Invalid backup time marker."}
	var candidate = City.new()
	if not raw.model is Dictionary or not candidate.restore_snapshot(raw.model):
		return {"ok": false, "reason": "Invalid or unsupported city data."}
	var normalized: Dictionary = candidate.snapshot()
	return {"ok": true, "gold": normalized.gold, "food": normalized.food, "xp": normalized.xp,
		"individual_count": normalized.individuals.size(), "domain_revision": normalized.revision,
		"wall_marker_ms": int(raw.wall_marker_ms)}
