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
var build_choice: OptionButton
var farm_choice: OptionButton
var build_button: Button
var cancel_build_button: Button
var coordinate_x: SpinBox
var coordinate_y: SpinBox
var build_choice_key: String = ""
var farm_choice_key: String = ""
var selected_farm: String = "farm-1"

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
	farm_choice = OptionButton.new()
	farm_choice.position = Vector2(758, 398)
	farm_choice.size = Vector2(310, 28)
	farm_choice.item_selected.connect(choose_farm)
	add_child(farm_choice)
	farm_info = label_at("", Vector2(758, 427), Vector2(320, 25), 16)
	plant_short = button_at("Sprout Kelp · 20 G · 40 F · 1m", Vector2(758, 459), func(): act("plant", selected_farm + ":sprout"))
	plant_long = button_at("Ribbon Kelp · 100 G · 180 F · 5m", Vector2(758, 507), func(): act("plant", selected_farm + ":ribbon"))
	harvest_button = button_at("Harvest crop", Vector2(758, 555), func(): act("harvest", selected_farm))
	build_choice = OptionButton.new()
	build_choice.position = Vector2(30, 570)
	build_choice.fit_to_longest_item = false
	build_choice.clip_text = true
	build_choice.size = Vector2(215, 42)
	add_child(build_choice)
	coordinate_x = coordinate_at(Vector2(250, 570), "X ", 3)
	coordinate_y = coordinate_at(Vector2(330, 570), "Y ", 0)
	build_button = button_at("Confirm placement", Vector2(410, 570), place_selected)
	build_button.size = Vector2(174, 42)
	build_button.add_theme_font_size_override("font_size", 15)
	cancel_build_button = button_at("Cancel build", Vector2(590, 570), func(): act("cancel_build", ""))
	cancel_build_button.size = Vector2(142, 42)
	cancel_build_button.add_theme_font_size_override("font_size", 15)
	status_label = label_at("Choose a building and coordinates, or tend Blueberry and your farm.", Vector2(30, 617), Vector2(700, 34), 16)
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label_at("DEV CHECKPOINT  ·  Session only; founder shop, breeding jobs and expansion not yet wired.", Vector2(30, 655), Vector2(1040, 22), 15)
	adapter.capture(city.snapshot())
	refresh()
	var args := OS.get_cmdline_user_args()
	if args.size() == 2 and args[0] == "--capture-city":
		capture_mode = true
		call_deferred("capture_fixture", args[1])

func coordinate_at(at: Vector2, prefix_text: String, initial: int) -> SpinBox:
	var field := SpinBox.new()
	field.position = at
	field.size = Vector2(76, 42)
	field.min_value = 0
	field.max_value = 7
	field.step = 1
	field.prefix = prefix_text
	field.value = initial
	add_child(field)
	return field

func choose_farm(index: int) -> void:
	selected_farm = str(farm_choice.get_item_metadata(index))
	refresh()

func refresh_choices() -> void:
	var ids: Array[String] = city.farm_ids()
	var key: String = str(ids)
	if key != farm_choice_key:
		farm_choice_key = key
		farm_choice.clear()
		for id in ids:
			farm_choice.add_item("FARM %d · select slot" % (farm_choice.item_count + 1))
			farm_choice.set_item_metadata(farm_choice.item_count - 1, id)
		var index: int = ids.find(selected_farm)
		if index < 0:
			index = 0
			selected_farm = ids[0]
		farm_choice.select(index)
	key = str(city.buildings)
	if key != build_choice_key:
		build_choice_key = key
		var previous: String = selected_placement()
		build_choice.clear()
		for kind in ["light", "tide", "bloom", "grotto", "farm"]:
			var spec: Dictionary = Model.BUILD_TYPES[kind]
			build_choice.add_item("%s · %d G · Lv %d" % [spec["kind"], spec["gold"], spec["gate"]])
			build_choice.set_item_metadata(build_choice.item_count - 1, "build:" + kind)
		for b in city.buildings:
			build_choice.add_item("Move %s (%d,%d)" % [b["kind"], b["x"], b["y"]])
			build_choice.set_item_metadata(build_choice.item_count - 1, "move:" + str(b["id"]))
		for i in range(build_choice.item_count):
			if str(build_choice.get_item_metadata(i)) == previous:
				build_choice.select(i)
				return
		build_choice.select(0)

func selected_placement() -> String:
	if build_choice == null or build_choice.selected < 0:
		return ""
	return str(build_choice.get_item_metadata(build_choice.selected))

func place_selected() -> void:
	var selection: PackedStringArray = selected_placement().split(":")
	if selection.size() == 2:
		act(selection[0], "%s,%d,%d" % [selection[1], int(coordinate_x.value), int(coordinate_y.value)])

func _process(_delta: float) -> void:
	var now := Time.get_ticks_msec()
	var previous_revision: int = city.revision
	city.advance(maxi(0, now - last_ms))
	last_ms = now
	if city.revision != previous_revision:
		adapter.capture(city.snapshot())
		status_label.text = "Construction complete · +50 account XP"
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
	refresh_choices()
	cancel_build_button.disabled = city.construction.is_empty()
	var job: Dictionary = city.farm_crop(selected_farm)
	var empty: bool = job.is_empty()
	plant_short.disabled = not empty or city.gold < 20
	plant_long.disabled = not empty or city.gold < 100
	harvest_button.disabled = empty or city.remaining_seconds(selected_farm) > 0
	farm_info.text = "Empty · select a paid crop" if empty else ("Ready to harvest!" if city.remaining_seconds(selected_farm) == 0 else "%s · %ds remaining" % [Model.CROPS[job["recipe"]]["name"], city.remaining_seconds(selected_farm)])
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
	for building in city.buildings:
		draw_building(building)
	var selection: PackedStringArray = selected_placement().split(":")
	if selection.size() == 2:
		var b: Dictionary = Model.BUILD_TYPES.get(selection[1], {}) if selection[0] == "build" else city.find_building(selection[1])
		if not b.is_empty():
			var x: int = int(coordinate_x.value)
			var y: int = int(coordinate_y.value)
			var footprint: int = b["size"]
			var valid: bool = city.can_place(x, y, footprint, selection[1] if selection[0] == "move" else "")
			var points := PackedVector2Array([iso(x,y),iso(x+footprint,y),iso(x+footprint,y+footprint),iso(x,y+footprint),iso(x,y)])
			draw_polyline(points, Color("#f3ffe0") if valid else Color("#ffac75"), 3.0, true)
	ink("Placement: X ↘  Y ↙ · white = free / orange = blocked · 8 × 8 land", Vector2(37, 542), 16)

func draw_building(b: Dictionary) -> void:
	var x: float = float(b["x"])
	var y: float = float(b["y"])
	var footprint: float = float(b["size"])
	var center := iso(x + footprint * 0.5, y + footprint * 0.5)
	var id: String = str(b["id"])
	var kind: String = str(b["type"])
	if city.pending(id):
		tile(x,y,footprint,footprint,Color("#d4b878"))
		ink(str(b["kind"]), center + Vector2(-60,-12), 15)
		ink("Building %ds" % city.construction_remaining(), center + Vector2(-47,12), 15)
		return
	match kind:
		"tide", "light", "bloom":
			var fill: Color = Color("#4cb9c6") if kind == "tide" else (Color("#e5cf8f") if kind == "light" else Color("#9fbd76"))
			tile(x,y,footprint,footprint,fill)
			draw_circle(center, 43, fill.darkened(0.30))
			if id == "tide-1":
				# Same original temporary mascot; stable habitat ID owns its location.
				var ray := center + Vector2(0,-7)
				draw_polyline(PackedVector2Array([ray+Vector2(18,8),ray+Vector2(34,19),ray+Vector2(42,13)]), Color("#72cbe0"), 4, true)
				draw_colored_polygon(PackedVector2Array([ray+Vector2(-4,0),ray+Vector2(-38,-9),ray+Vector2(-18,19),ray+Vector2(11,15),ray+Vector2(32,-6)]), Color("#6bbcdf"))
				draw_circle(ray + Vector2(-7,1), 18, Color("#9addec"))
				draw_circle(ray + Vector2(-15,8), 7, Color("#f5e3bc"))
				draw_circle(ray + Vector2(-14,-3), 5, Color("#233a52"))
				draw_circle(ray + Vector2(-15,-5), 2, Color.WHITE)
				ink("%d G / 500" % city.stored_gold(), center + Vector2(-45,58), 15)
				if city.stored_gold() > 0:
					draw_circle(center + Vector2(41,-33), 14, Color("#ffce63"))
					ink("G", center + Vector2(35,-28), 14, Color("#533e26"))
			else:
				ink("Empty · 0 G/min", center + Vector2(-55,7), 14)
			ink(str(b["kind"]), center + Vector2(-53,-47), 16)
		"hatchery":
			tile(x,y,footprint,footprint,Color("#e5c58d"))
			draw_circle(center, 27, Color("#b89d72"))
			draw_circle(center + Vector2(0,-4), 15, Color("#eae2c8"))
			ink("Hatchery", center + Vector2(-36,38), 16)
		"farm":
			tile(x,y,footprint,footprint,Color("#927c53"))
			var job: Dictionary = city.farm_crop(id)
			for i in range(2):
				for j in range(2):
					var p := iso(x+0.25+i*0.75,y+0.25+j*0.75)
					draw_circle(p, 7 if job.is_empty() else 13, Color("#bda579") if job.is_empty() else Color("#56d492"))
			ink("Farm" if job.is_empty() else ("Ready!" if city.remaining_seconds(id) == 0 else "%ds" % city.remaining_seconds(id)), center + Vector2(-22,43), 16)
		"grotto":
			tile(x,y,footprint,footprint,Color("#a99bd3"))
			draw_circle(center, 34, Color("#726d9a"))
			ink("Grotto", center + Vector2(-27,5), 16)
			ink("Breeding not wired", center + Vector2(-63,40), 13)

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
	# Wait for the real 60-second crop on the normal clock, not a debug grant.
	await get_tree().create_timer(61.0).timeout
	await click_fixture(collect_button)
	await click_fixture(harvest_button)
	if city.gold < 1192 or city.food != 275 or city.xp != 105 or not city.crop.is_empty() or city.pips != 1:
		push_error("GUI real-time harvest fixture failed: " + str(city.snapshot()))
		get_tree().quit(1)
		return
	await RenderingServer.frame_post_draw
	if get_viewport().get_texture().get_image().save_png(directory + "/03-earned-and-harvested.png") != OK:
		get_tree().quit(1)
		return
	print("CITY_GUI_INPUT_PASS: sample, paid planting, feed, real-time resident collect and crop harvest via native mouse events")
	var before_build: int = city.gold
	await click_fixture(build_button)
	if city.gold != before_build - 200 or city.construction.is_empty() or city.find_building("building-1").is_empty():
		push_error("GUI placement fixture failed: " + str(city.snapshot()))
		get_tree().quit(1)
		return
	await get_tree().create_timer(31.0).timeout
	if not city.construction.is_empty() or city.xp != 155:
		push_error("GUI construction timer fixture failed: " + str(city.snapshot()))
		get_tree().quit(1)
		return
	await RenderingServer.frame_post_draw
	if get_viewport().get_texture().get_image().save_png(directory + "/04-built-light-habitat.png") != OK:
		get_tree().quit(1)
		return
	print("CITY_BUILD_GUI_PASS: paid Light habitat placement and ordinary 30-second construction")
	get_tree().quit(0)
