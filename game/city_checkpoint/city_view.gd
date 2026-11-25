extends Control

const Model = preload("res://city_model.gd")
const Adapter = preload("res://checkpoint_adapter.gd")
var city = Model.new()
var adapter = Adapter.new()
var last_ms: int = 0
var op_count: int = 0
var status_label: Label
var wallet: Label
var ray_info: Label
var farm_info: Label
var collect_button: Button
var sample_button: Button
var plant_short: Button
var plant_long: Button
var harvest_button: Button
var feed_button: Button
var name_edit: LineEdit
var capture_mode: bool = false

func label_at(value: String, position_: Vector2, size_: Vector2, font_size: int = 20) -> Label:
	var item := Label.new()
	item.text = value
	item.position = position_
	item.size = size_
	item.add_theme_font_size_override("font_size", font_size)
	add_child(item)
	return item

func button_at(value: String, position_: Vector2, action: Callable) -> Button:
	var item := Button.new()
	item.text = value
	item.position = position_
	item.size = Vector2(310, 42)
	item.add_theme_font_size_override("font_size", 18)
	item.pressed.connect(action)
	add_child(item)
	return item

func _ready() -> void:
	last_ms = Time.get_ticks_msec()
	label_at("LITTLE RAY   /   BLUEBERRY REEF", Vector2(28, 15), Vector2(650, 40), 27)
	wallet = label_at("", Vector2(30, 66), Vector2(1040, 40), 23)
	label_at("STARTER ISLAND  ·  4 owned sectors / 8 × 8", Vector2(30, 112), Vector2(650, 32), 18)
	label_at("BLUEBERRY  /  TIDE · COMMON", Vector2(758, 116), Vector2(320, 30), 20)
	ray_info = label_at("", Vector2(758, 148), Vector2(320, 50), 16)
	name_edit = LineEdit.new()
	name_edit.position = Vector2(758, 205)
	name_edit.size = Vector2(310, 34)
	name_edit.max_length = 24
	name_edit.text = city.nickname
	name_edit.text_submitted.connect(func(value: String): act("name", value))
	add_child(name_edit)
	sample_button = button_at("Claim tutorial sample (+10 Gold)", Vector2(758, 246), func(): act("sample", ""))
	collect_button = button_at("Collect resident Gold", Vector2(758, 294), func(): act("collect", ""))
	feed_button = button_at("Feed Blueberry", Vector2(758, 342), func(): act("feed", ""))
	label_at("FARM  /  one active crop", Vector2(758, 398), Vector2(320, 28), 19)
	farm_info = label_at("", Vector2(758, 427), Vector2(320, 25), 16)
	plant_short = button_at("Sprout Kelp · 20 G · 40 F · 1m", Vector2(758, 459), func(): act("plant", "sprout"))
	plant_long = button_at("Ribbon Kelp · 100 G · 180 F · 5m", Vector2(758, 507), func(): act("plant", "ribbon"))
	harvest_button = button_at("Harvest crop", Vector2(758, 555), func(): act("harvest", ""))
	status_label = label_at("Choose a name, collect Gold, plant a crop or feed your ray.", Vector2(30, 573), Vector2(700, 54), 18)
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label_at("DEV CHECKPOINT  ·  Session only; save, shop, building and breeding not yet wired.", Vector2(30, 642), Vector2(1040, 24), 15)
	adapter.capture(city.snapshot())
	refresh()
	var args := OS.get_cmdline_user_args()
	if args.size() == 2 and args[0] == "--capture-city":
		capture_mode = true
		call_deferred("capture_fixture", args[1])

func _process(_delta: float) -> void:
	var now := Time.get_ticks_msec()
	city.advance(maxi(0, now - last_ms))
	last_ms = now
	refresh()

func act(kind: String, value: String) -> void:
	var now := Time.get_ticks_msec()
	city.advance(maxi(0, now - last_ms))
	last_ms = now
	op_count += 1
	var result: Dictionary = city.command(kind, value, "ui-%d" % op_count, city.revision)
	status_label.text = str(result["message"])
	if result["ok"]:
		adapter.capture(city.snapshot())
	refresh()

func refresh() -> void:
	wallet.text = "GOLD  %d     ·     FOOD  %d     ·     ACCOUNT LV %d  (%d XP)" % [city.gold, city.food, city.account_level(), city.xp]
	ray_info.text = "%s · Lv %d · %d/4 feed pips\n%.2f Gold/min · bin %d/500" % [city.nickname, city.level, city.pips, 2.0 * (1.0 + 0.25 * (city.level - 1)), city.stored_gold()]
	sample_button.disabled = city.sample_claimed
	collect_button.disabled = city.stored_gold() == 0
	collect_button.text = "Collect %d resident Gold" % city.stored_gold()
	var cost: int = city.feed_cost()
	feed_button.disabled = cost == 0 or city.food < cost
	feed_button.text = "Feed · %d Food" % cost if cost > 0 else "Level cap reached"
	var empty: bool = city.crop.is_empty()
	plant_short.disabled = not empty or city.gold < 20
	plant_long.disabled = not empty or city.gold < 100
	harvest_button.disabled = empty or city.remaining_seconds() > 0
	farm_info.text = "Empty · select a paid crop" if empty else ("Ready to harvest!" if city.remaining_seconds() == 0 else "%s · %ds remaining" % [Model.CROPS[city.crop["recipe"]]["name"], city.remaining_seconds()])
	queue_redraw()

func iso(x: float, y: float) -> Vector2:
	return Vector2(370 + (x - y) * 38, 186 + (x + y) * 20)

func tile(x: float, y: float, w: float, h: float, fill: Color) -> void:
	var points := PackedVector2Array([iso(x,y),iso(x+w,y),iso(x+w,y+h),iso(x,y+h)])
	draw_colored_polygon(points, fill)
	draw_polyline(PackedVector2Array([points[0],points[1],points[2],points[3],points[0]]), Color("#486e5f"), 1.1, true)

func ink(value: String, pos: Vector2, font_size: int, color: Color = Color("#eef9ef")) -> void:
	draw_string(ThemeDB.fallback_font, pos, value, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)

func _draw() -> void:
	draw_rect(Rect2(18, 109, 716, 456), Color("#12617a"))
	draw_circle(Vector2(370, 345), 220, Color("#197d8c"))
	draw_rect(Rect2(744, 109, 340, 508), Color("#183d4b"))
	for y in range(8):
		for x in range(8):
			tile(x, y, 1, 1, Color("#8bc879") if (x+y)%2 == 0 else Color("#81bd73"))
	for x in [0,4]:
		for y in [0,4]:
			var points := PackedVector2Array([iso(x,y),iso(x+4,y),iso(x+4,y+4),iso(x,y+4),iso(x,y)])
			draw_polyline(points, Color("#d9e4a2"), 2.4, true)
	# Prebuilt, nonoverlapping GDD footprint. Empty proposed placements remain land.
	tile(0,0,3,3,Color("#4cb9c6"))
	tile(3,3,2,2,Color("#e5c58d"))
	tile(5,3,2,2,Color("#927c53"))
	var pond := iso(1.5,1.5)
	draw_circle(pond, 45, Color("#226e91"))
	# Original simple placeholder, not approved mascot artwork.
	var ray := pond + Vector2(0,-7)
	draw_polyline(PackedVector2Array([ray+Vector2(18,8),ray+Vector2(34,19),ray+Vector2(42,13)]), Color("#72cbe0"), 4, true)
	draw_colored_polygon(PackedVector2Array([ray+Vector2(-4,0),ray+Vector2(-38,-9),ray+Vector2(-18,19),ray+Vector2(11,15),ray+Vector2(32,-6)]), Color("#6bbcdf"))
	draw_circle(ray + Vector2(-7,1), 18, Color("#9addec"))
	draw_circle(ray + Vector2(-15,8), 7, Color("#f5e3bc"))
	draw_circle(ray + Vector2(-14,-3), 5, Color("#233a52"))
	draw_circle(ray + Vector2(-15,-5), 2, Color.WHITE)
	ink("Tide habitat", pond + Vector2(-53,-52), 17)
	ink("%d G / 500" % city.stored_gold(), pond + Vector2(-45,58), 15)
	if city.stored_gold() > 0:
		draw_circle(pond + Vector2(41,-33), 14, Color("#ffce63"))
		ink("G", pond + Vector2(35,-28), 14, Color("#533e26"))
	var hatch := iso(4,4)
	draw_circle(hatch, 27, Color("#b89d72"))
	draw_circle(hatch + Vector2(0,-4), 15, Color("#eae2c8"))
	ink("Hatchery", hatch + Vector2(-36,38), 16)
	var farm := iso(6,4)
	for x in range(2):
		for y in range(2):
			var p := iso(5.25+x*0.75,3.25+y*0.75)
			draw_circle(p, 7 if city.crop.is_empty() else 13, Color("#bda579") if city.crop.is_empty() else Color("#56d492"))
	ink("Farm", farm + Vector2(-22,43), 16)
	ink("Locked expansion beyond starter land", Vector2(37, 542), 16)
	
func click_fixture(button: Button) -> void:
	var point := button.get_global_rect().get_center()
	var down := InputEventMouseButton.new()
	down.position = point
	down.global_position = point
	down.button_index = MOUSE_BUTTON_LEFT
	down.pressed = true
	Input.parse_input_event(down)
	await get_tree().process_frame
	var up := InputEventMouseButton.new()
	up.position = point
	up.global_position = point
	up.button_index = MOUSE_BUTTON_LEFT
	up.pressed = false
	Input.parse_input_event(up)
	await get_tree().process_frame
	await get_tree().process_frame

func capture_fixture(directory: String) -> void:
	# CI-only native GUI fixture; no acceleration in normal play.
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	if get_viewport().get_texture().get_image().save_png(directory + "/01-opening.png") != OK:
		get_tree().quit(1)
		return
	await click_fixture(sample_button)
	await click_fixture(plant_short)
	await click_fixture(feed_button)
	if city.gold != 1190 or city.food != 235 or city.xp != 100 or city.crop.is_empty() or city.pips != 1:
		push_error("GUI input fixture failed: " + str(city.snapshot()))
		get_tree().quit(1)
		return
	await RenderingServer.frame_post_draw
	if get_viewport().get_texture().get_image().save_png(directory + "/02-after-input.png") != OK:
		get_tree().quit(1)
		return
	print("CITY_GUI_INPUT_PASS: sample, paid planting, feed via native mouse events")
	get_tree().quit(0)
