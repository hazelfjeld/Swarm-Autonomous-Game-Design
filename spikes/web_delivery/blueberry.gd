extends Control

# Original procedural vector placeholder. No third-party artwork or selected art style.
func _draw() -> void:
	var p := size * Vector2(0.5, 0.46)
	draw_line(p + Vector2(35, 15), p + Vector2(155, 70), Color("8f9de8"), 5, true)
	draw_colored_polygon(PackedVector2Array([p + Vector2(-25, -20), p + Vector2(-160, -50),
		p + Vector2(-130, 28), p + Vector2(-25, 38)]), Color("7c8bd4"))
	draw_colored_polygon(PackedVector2Array([p + Vector2(15, -25), p + Vector2(122, -61),
		p + Vector2(103, 30), p + Vector2(18, 38)]), Color("8f9de8"))
	draw_circle(p, 56, Color("a5afea"))
	draw_circle(p + Vector2(-10, 25), 34, Color("f4efdc"))
	draw_circle(p + Vector2(-26, -9), 14, Color("1b2846"))
	draw_circle(p + Vector2(-30, -13), 5, Color.WHITE)
	draw_arc(p + Vector2(-27, 16), 12, 0.1, 1.8, 16, Color("4b557a"), 3, true)
