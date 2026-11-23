extends SceneTree


func _initialize() -> void:
	var payload: Dictionary = {"probe_id": "GAMEPLAY-001", "value": 6 * 7}
	var restored: Variant = JSON.parse_string(JSON.stringify(payload))
	if not restored is Dictionary or restored.get("value") != 42:
		push_error("GAMEPLAY-001 generic JSON round trip failed")
		quit(1)
		return
	print(JSON.stringify({
		"capability_smoke": "ok",
		"engine": Engine.get_version_info()["string"],
		"probe_id": restored["probe_id"],
		"value": restored["value"],
	}))
	quit(0)
