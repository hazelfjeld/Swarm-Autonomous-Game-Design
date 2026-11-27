extends RefCounted
# Diagnostic-only state. Callers pass clocks explicitly; no I/O or rewards.
const MAX_ELAPSED_MS := 604800000 # Seven days, GDD v2 section 15.
const MAX_WALL_MS := 9007199254740991 # Exact JSON integer range.

static func fresh() -> Dictionary:
	return {"phase": "idle", "remaining_ms": 0, "wall_marker_ms": 0}

static func _whole(value: Variant, maximum: int) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and float(value) == floor(float(value)) and value >= 0 and value <= maximum

static func validate(value: Variant) -> String:
	if not value is Dictionary:
		return "Invalid diagnostic timer."
	var phase: Variant = value.get("phase")
	var remaining: Variant = value.get("remaining_ms")
	var marker: Variant = value.get("wall_marker_ms")
	if not _whole(remaining, MAX_ELAPSED_MS) or not _whole(marker, MAX_WALL_MS):
		return "Invalid diagnostic timer clock or duration."
	if phase == "idle" and remaining == 0 and marker == 0:
		return ""
	if phase == "running" and remaining > 0 and marker > 0:
		return ""
	if phase in ["ready", "claimed"] and remaining == 0 and marker > 0:
		return ""
	return "Invalid diagnostic timer phase."

static func normalized(value: Dictionary) -> Dictionary:
	return {"phase": value.phase, "remaining_ms": int(value.remaining_ms), "wall_marker_ms": int(value.wall_marker_ms)}

# A single-use diagnostic job; restarting cannot discard a committed outcome.
static func start(value: Dictionary, duration_ms: int, wall_ms: int) -> Dictionary:
	if not validate(value).is_empty() or value.phase != "idle" or duration_ms <= 0 or duration_ms > MAX_ELAPSED_MS or wall_ms <= 0 or wall_ms > MAX_WALL_MS:
		return value.duplicate(true)
	return {"phase": "running", "remaining_ms": duration_ms, "wall_marker_ms": wall_ms}

# Resume consumes eligible wall time once. A forward jump beyond the cap is
# discarded, not carried as debt that could be credited on the next reload.
static func resume(value: Dictionary, wall_ms: int) -> Dictionary:
	if not validate(value).is_empty() or value.phase != "running" or wall_ms < 0 or wall_ms > MAX_WALL_MS:
		return value.duplicate(true)
	var elapsed := clampi(wall_ms - int(value.wall_marker_ms), 0, MAX_ELAPSED_MS)
	return advance_active(value, elapsed, wall_ms)

# Active callers supply monotonic elapsed since the last committed checkpoint.
# The wall high-water mark never moves backwards, even on clock rollback.
static func advance_active(value: Dictionary, elapsed_ms: int, wall_ms: int) -> Dictionary:
	if not validate(value).is_empty() or value.phase != "running" or elapsed_ms < 0 or wall_ms < 0 or wall_ms > MAX_WALL_MS:
		return value.duplicate(true)
	var result := normalized(value)
	result.remaining_ms = maxi(0, int(result.remaining_ms) - mini(elapsed_ms, MAX_ELAPSED_MS))
	result.wall_marker_ms = maxi(int(result.wall_marker_ms), wall_ms)
	if result.remaining_ms == 0:
		result.phase = "ready"
	return result

static func claim(value: Dictionary) -> Dictionary:
	var result := value.duplicate(true)
	if validate(value).is_empty() and value.phase == "ready":
		result.phase = "claimed"
	return result
