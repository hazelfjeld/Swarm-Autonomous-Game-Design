extends RefCounted
## Candidate ARCH-002 profile commit boundary. No filesystem or browser I/O.
## The caller supplies a domain validator and actual observed durable readback.
## Do not publish staged gameplay effects until confirmation; unknown outcomes
## require a new instance initialized from independently reconciled storage.

const MAX_INTEGER := 9007199254740991
const MAX_OFFLINE_MS := 604800000
var _validator: Callable
var _committed: Dictionary = {}
var _pending: Dictionary = {}
var _pending_text: String = ""
var _status: String = "uninitialized"

func _init(validate_snapshot: Callable) -> void:
	_validator = validate_snapshot

static func _whole(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and float(value) == floor(float(value)) and value >= 0 and value <= MAX_INTEGER

## No credit is carried forward after a large clock jump. The returned marker
## must be committed atomically with the domain state after it consumes elapsed_ms.
static func offline_budget(marker_ms: int, observed_ms: int) -> Dictionary:
	if not _whole(marker_ms) or not _whole(observed_ms):
		return {"ok": false}
	return {"ok": true, "elapsed_ms": clampi(observed_ms - marker_ms, 0, MAX_OFFLINE_MS),
		"wall_marker_ms": maxi(marker_ms, observed_ms)}

func _valid_model(model: Variant) -> bool:
	if not model is Dictionary or not _whole(model.get("revision")) or not _validator.is_valid():
		return false
	# Do not allow the validator to mutate the caller's state.
	var accepted: Variant = _validator.call(model.duplicate(true))
	return accepted is bool and accepted

## Explicit initialization from a previously validated profile read, or from a
## deliberate fresh profile with generation zero. Unreadable disk is not fresh.
## Envelope is an internal staging contract, not an accepted migration schema.
func initialize(snapshot: Dictionary, storage_revision: int, wall_marker_ms: int) -> bool:
	if _status != "uninitialized" or not _whole(storage_revision) or not _whole(wall_marker_ms) or not _valid_model(snapshot):
		return false
	_committed = {"storage_revision": storage_revision, "wall_marker_ms": wall_marker_ms,
		"model": snapshot.duplicate(true)}
	_status = "ready"
	return true

## Restore only from actual persisted bytes read by the transport. Missing or
## unreadable storage must not be represented by empty text as a fresh profile.
## A failed read/validation permanently closes this instance to fresh writes;
## explicit recovery must use a new instance and independently reconciled bytes.
## This parses the provisional internal envelope, not a user backup migration.
func initialize_from_text(observed_text: String) -> bool:
	if _status != "uninitialized":
		return false
	var parser := JSON.new()
	if parser.parse(observed_text) != OK:
		_status = "unavailable"
		return false
	var raw: Variant = parser.data
	if not raw is Dictionary or raw.size() != 3 or not raw.has_all(["storage_revision", "wall_marker_ms", "model"]):
		_status = "unavailable"
		return false
	# Check JSON number types/ranges before conversion; never coerce text,
	# fractional values, negative markers or overflowing generations.
	if not _whole(raw.storage_revision) or not _whole(raw.wall_marker_ms):
		_status = "unavailable"
		return false
	if not raw.model is Dictionary or not initialize(raw.model, int(raw.storage_revision), int(raw.wall_marker_ms)):
		_status = "unavailable"
		return false
	return true

func status() -> String:
	return _status

func committed() -> Dictionary:
	return _committed.duplicate(true)

## Candidate is already staged in the domain layer, including receipts and
## offline settlement. A storage generation is distinct from domain revision;
## time-only checkpoints may legitimately keep the same domain revision.
func begin(candidate: Dictionary, expected_storage_revision: int, wall_marker_ms: int) -> Dictionary:
	if _status != "ready":
		return {"ok": false, "reason": "Not ready for writes."}
	if expected_storage_revision != int(_committed.storage_revision):
		return {"ok": false, "reason": "Storage generation conflict."}
	if expected_storage_revision >= MAX_INTEGER or not _whole(wall_marker_ms) or wall_marker_ms < int(_committed.wall_marker_ms):
		return {"ok": false, "reason": "Invalid generation or wall marker."}
	if not _valid_model(candidate) or int(candidate.revision) < int(_committed.model.revision):
		return {"ok": false, "reason": "Invalid or regressed domain state."}
	_pending = {"storage_revision": expected_storage_revision + 1, "wall_marker_ms": wall_marker_ms,
		"model": candidate.duplicate(true)}
	_pending_text = JSON.stringify(_pending, "", true, true)
	_status = "saving"
	return {"ok": true, "storage_revision": _pending.storage_revision, "payload": _pending_text}

## Call only after actual successful storage transaction and exact active-byte
## readback. A stale callback cannot confirm a different pending generation.
func confirm(storage_revision: int, observed_text: String) -> bool:
	if _status != "saving" or storage_revision != int(_pending.storage_revision):
		return false
	if observed_text != _pending_text:
		_status = "unavailable"
		return false
	_committed = _pending
	_pending = {}
	_pending_text = ""
	_status = "ready"
	return true

## Timeout, transaction failure, write refusal, or uncertain outcome. Preserve
## last confirmed state, but do not assume the attempted write did not happen.
func mark_unknown(storage_revision: int) -> bool:
	if _status != "saving" or storage_revision != int(_pending.storage_revision):
		return false
	_status = "unavailable"
	return true
