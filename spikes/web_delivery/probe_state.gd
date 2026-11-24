extends RefCounted

const Content = preload("res://content.gd")
const TimerState = preload("res://probe_timer.gd")
const FORMAT := "little_rays.arch002-probe"

static func fresh() -> Dictionary:
	return {"format": FORMAT, "schema_version": 1,
		"content_version": Content.CONTENT_VERSION, "greetings": 0,
		"timer": TimerState.fresh(),
		"individual": {"ray_id": "probe_ray_001", "breed_id": Content.BREED_ID,
			"nickname": Content.DISPLAY_NAME}}

static func validate(value: Variant) -> String:
	if not value is Dictionary:
		return "Backup must be a JSON object."
	if value.get("format") != FORMAT or value.get("schema_version") != 1:
		return "Unsupported backup format or version; current save unchanged."
	if value.get("content_version") != Content.CONTENT_VERSION:
		return "Unsupported probe content version; current save unchanged."
	if value.get("individual") != fresh().individual:
		return "Unrecognized probe individual; current save unchanged."
	var count: Variant = value.get("greetings")
	if not (count is int or count is float):
		return "Greeting count must be an integer."
	if not is_finite(float(count)) or float(count) != floor(float(count)) or count < 0 or count > 1000000:
		return "Greeting count must be between 0 and 1000000."
	# Historical schema-1 greeting-only backups are compatible, not destructive migrations.
	if value.has("timer"):
		return TimerState.validate(value.timer)
	return ""
