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
var ray_title: Label
var ray_choice: OptionButton
var habitat_choice: OptionButton
var shop_choice: OptionButton
var buy_button: Button
var place_egg_button: Button
var move_ray_button: Button
var upgrade_button: Button
var egg_info: Label
var collection_info: Label
var selected_ray: String = "ray-1"
var selected_habitat: String = "tide-1"
var roster_key: String = ""
var habitat_key: String = ""
var land_label: Label
var favorite_button: Button
var sell_button: Button
var sale_note: Label
var sale_dialog: ConfirmationDialog
var sale_target: String = ""

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
	land_label = label_at("STARTER ISLAND  ·  4 owned sectors / 8 × 8", Vector2(30, 112), Vector2(650, 32), 18)
	ray_title = label_at("BLUEBERRY  /  TIDE · COMMON", Vector2(758, 116), Vector2(320, 30), 20)
	ray_info = label_at("", Vector2(758, 148), Vector2(320, 50), 16)
	name_edit = LineEdit.new()
	name_edit.position = Vector2(758, 205)
	name_edit.size = Vector2(310, 34)
	name_edit.max_length = 24
	name_edit.text = city.nickname
	name_edit.text_submitted.connect(func(value: String): act("rename", selected_ray + ":" + value))
	add_child(name_edit)
	sample_button = button_at("Claim tutorial sample (+10 Gold)", Vector2(758, 246), func(): act("sample", ""))
	collect_button = button_at("Collect resident Gold", Vector2(758, 294), func(): act("collect", selected_habitat))
	feed_button = button_at("Feed Blueberry", Vector2(758, 342), func(): act("feed", selected_ray))
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
	label_at("DEV CHECKPOINT · Session only; random breeding, battle and production art not yet wired.", Vector2(30, 655), Vector2(1040, 22), 15)
	ray_choice = option_at(Vector2(30, 685), Vector2(275, 44))
	ray_choice.item_selected.connect(choose_ray)
	habitat_choice = option_at(Vector2(315, 685), Vector2(275, 44))
	habitat_choice.item_selected.connect(choose_habitat)
	move_ray_button = button_at("Move selected ray here", Vector2(600, 685), func(): act("move_ray", selected_ray + "," + selected_habitat))
	move_ray_button.size = Vector2(235, 44)
	move_ray_button.add_theme_font_size_override("font_size", 15)
	upgrade_button = button_at("Upgrade selected habitat", Vector2(843, 685), func(): act("upgrade_habitat", selected_habitat))
	upgrade_button.size = Vector2(225, 44)
	upgrade_button.add_theme_font_size_override("font_size", 13)
	shop_choice = option_at(Vector2(30, 737), Vector2(275, 44))
	for species_id in ["sunbeam", "blueberry", "mossdrop"]:
		shop_choice.add_item("%s egg · 100 G · Lv %d" % [Model.SPECIES[species_id]["name"], Model.FOUNDER_GATES[species_id]])
		shop_choice.set_item_metadata(shop_choice.item_count - 1, species_id)
	shop_choice.select(0)
	buy_button = button_at("Buy founder egg", Vector2(315, 737), func(): act("buy_founder", str(shop_choice.get_item_metadata(shop_choice.selected))))
	buy_button.size = Vector2(180, 44)
	buy_button.add_theme_font_size_override("font_size", 15)
	place_egg_button = button_at("Place ready egg", Vector2(505, 737), func(): act("place_founder", selected_habitat))
	place_egg_button.size = Vector2(180, 44)
	place_egg_button.add_theme_font_size_override("font_size", 15)
	egg_info = label_at("", Vector2(695, 737), Vector2(375, 44), 15)
	egg_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	collection_info = label_at("", Vector2(30, 788), Vector2(1040, 36), 15)
	favorite_button = button_at("Mark favorite", Vector2(30, 830), func(): act("set_favorite", selected_ray + (",0" if city.individuals[selected_ray].get("favorite", false) else ",1")))
	favorite_button.size = Vector2(210, 42)
	sell_button = button_at("Review sale", Vector2(250, 830), preview_sale)
	sell_button.size = Vector2(235, 42)
	sale_note = label_at("", Vector2(500, 830), Vector2(570, 42), 15)
	sale_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sale_dialog = ConfirmationDialog.new()
	sale_dialog.title = "Confirm permanent ray sale"
	sale_dialog.ok_button_text = "Sell this ray"
	sale_dialog.confirmed.connect(confirm_sale)
	add_child(sale_dialog)
	adapter.capture(city.snapshot())
	refresh()
	var args := OS.get_cmdline_user_args()
	if args.size() == 2 and args[0] == "--capture-city":
		capture_mode = true
		call_deferred("capture_fixture", args[1])

func option_at(at: Vector2, dimensions: Vector2) -> OptionButton:
	var control := OptionButton.new()
	control.position = at
	control.size = dimensions
	control.fit_to_longest_item = false
	control.clip_text = true
	control.add_theme_font_size_override("font_size", 15)
	add_child(control)
	return control

func choose_ray(index: int) -> void:
	selected_ray = str(ray_choice.get_item_metadata(index))
	name_edit.text = str(city.individuals[selected_ray]["nickname"])
	refresh()

func choose_habitat(index: int) -> void:
	selected_habitat = str(habitat_choice.get_item_metadata(index))
	refresh()

func preview_sale() -> void:
	var error: String = city.sale_error(selected_ray)
	if not error.is_empty():
		status_label.text = error
		return
	sale_target = selected_ray
	var ray: Dictionary = city.individuals[sale_target]
	sale_dialog.dialog_text = "Sell %s (%s, %s, Lv %d) for %d Gold?\nThe individual and its training are lost permanently. Discovery remains." % [ray["nickname"], sale_target, city.ray_species(sale_target)["name"], ray["level"], city.sale_value(sale_target)]
	sale_dialog.popup_centered(Vector2i(500, 180))

func confirm_sale() -> void:
	if not sale_target.is_empty():
		var target: String = sale_target
		sale_target = ""
		act("sell_ray", target)

func refresh_roster() -> void:
	if not city.individuals.has(selected_ray):
		selected_ray = str(city.individuals.keys()[0])
		name_edit.text = str(city.individuals[selected_ray]["nickname"])
	var key: String = str(city.individuals.keys())
	# Include names in the key, but not changing levels or income.
	for id in city.individuals:
		key += str(city.individuals[id]["nickname"])
	if key != roster_key:
		roster_key = key
		ray_choice.clear()
		for id in city.individuals:
			ray_choice.add_item("Ray: %s (%s)" % [city.individuals[id]["nickname"], id])
			ray_choice.set_item_metadata(ray_choice.item_count - 1, id)
			if id == selected_ray:
				ray_choice.select(ray_choice.item_count - 1)
	var homes: Array[String] = city.habitat_ids()
	if not homes.has(selected_habitat):
		selected_habitat = homes[0]
	key = str(homes) + str(city.buildings)
	if key != habitat_key:
		habitat_key = key
		habitat_choice.clear()
		for id in homes:
			var b: Dictionary = city.find_building(id)
			habitat_choice.add_item("%s (%d,%d)" % [b["kind"], b["x"], b["y"]])
			habitat_choice.set_item_metadata(habitat_choice.item_count - 1, id)
			if id == selected_habitat:
				habitat_choice.select(habitat_choice.item_count - 1)

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
		if ids.is_empty():
			selected_farm = ""
			farm_choice.disabled = true
		else:
			farm_choice.disabled = false
			if index < 0:
				index = 0
				selected_farm = ids[0]
			farm_choice.select(index)
	key = str(city.buildings) + str(city.stored_buildings) + str(city.owned_sectors) + str(city.starter_obstacle)
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
		for b in city.buildings:
			build_choice.add_item("Store %s (%d,%d)" % [b["kind"], b["x"], b["y"]])
			build_choice.set_item_metadata(build_choice.item_count - 1, "store_building:" + str(b["id"]))
		for b in city.stored_buildings:
			build_choice.add_item("Restore %s · free" % b["kind"])
			build_choice.set_item_metadata(build_choice.item_count - 1, "restore_building:" + str(b["id"]))
		for sx in range(4):
			for sy in range(4):
				if city.can_buy_sector(sx, sy):
					build_choice.add_item("Buy land (%d,%d) · 250 G" % [sx * 4, sy * 4])
					build_choice.set_item_metadata(build_choice.item_count - 1, "buy_sector:%d,%d" % [sx, sy])
		if not city.starter_obstacle.is_empty() and not city.starter_obstacle["cleared"]:
			build_choice.add_item("Clear obstacle · 50 G · 1m")
			build_choice.set_item_metadata(build_choice.item_count - 1, "clear_obstacle:starter-obstacle")
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
		if selection[0] in ["buy_sector", "clear_obstacle", "store_building"]:
			act(selection[0], selection[1])
		else:
			act(selection[0], "%s,%d,%d" % [selection[1], int(coordinate_x.value), int(coordinate_y.value)])

func _process(_delta: float) -> void:
	var now := Time.get_ticks_msec()
	var previous_revision: int = city.revision
	var previous_xp: int = city.xp
	city.advance(maxi(0, now - last_ms))
	last_ms = now
	if city.revision != previous_revision:
		adapter.capture(city.snapshot())
		status_label.text = "Builder job complete · +%d account XP" % (city.xp - previous_xp)
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
	refresh_roster()
	var ray: Dictionary = city.individuals[selected_ray]
	var species: Dictionary = city.ray_species(selected_ray)
	var stats: Dictionary = city.ray_stats(selected_ray)
	ray_title.text = "%s / %s" % [species["name"].to_upper(), species["rarity"]]
	ray_info.text = "Lv %d · %d/4 pips · %s\nHP %d · POW %d · SPD %d · %.2f G/min" % [ray["level"], ray["pips"], "/".join(PackedStringArray(species["elements"])), stats["health"], stats["power"], stats["speed"], city.ray_rate_ticks(selected_ray) / 4.0]
	sample_button.disabled = city.sample_claimed
	collect_button.disabled = city.stored_gold(selected_habitat) == 0
	collect_button.text = "Collect %d / %d Gold" % [city.stored_gold(selected_habitat), city.habitat_gold_cap(selected_habitat)]
	upgrade_button.disabled = not city.construction.is_empty() or city.habitat_capacity(selected_habitat) == Model.LARGE_CAPACITY or city.gold < Model.LARGE_COST or city.account_level() < Model.LARGE_GATE
	if city.upgrading(selected_habitat):
		upgrade_button.text = "Upgrading · %ds left" % city.construction_remaining()
	elif city.habitat_capacity(selected_habitat) == Model.LARGE_CAPACITY:
		upgrade_button.text = "Large · 4 rays / 5000 G"
	else:
		upgrade_button.text = "Large · 600 G · 5m\nLv 5 · income pauses"
	var cost: int = city.feed_cost(selected_ray)
	feed_button.disabled = cost == 0 or city.food < cost
	feed_button.text = "Feed · %d Food" % cost if cost > 0 else "Level cap reached"
	move_ray_button.disabled = ray["habitat_id"] == selected_habitat
	buy_button.disabled = city.find_building("hatchery-1").is_empty() or not city.founder_egg.is_empty() or city.gold < 100
	place_egg_button.disabled = city.founder_egg.is_empty() or city.founder_remaining() > 0
	if city.founder_egg.is_empty():
		egg_info.text = "Restore hatchery from storage" if city.find_building("hatchery-1").is_empty() else "Hatchery empty · buy a founder"
	else:
		var egg_name: String = str(Model.SPECIES[city.founder_egg["species"]]["name"])
		egg_info.text = "%s · %ds to hatch" % [egg_name, city.founder_remaining()] if city.founder_remaining() > 0 else "%s ready! Select compatible housing." % egg_name
	var entries: PackedStringArray = []
	for id in Model.SPECIES:
		entries.append(str(Model.SPECIES[id]["name"]) + (" ✓" if city.discoveries.has(id) else " · " + str(Model.SPECIES[id]["source"])))
	collection_info.text = "Collection %d/6  |  %s" % [city.discoveries.size(), "  |  ".join(entries)]
	var marked: bool = bool(ray.get("favorite", false))
	favorite_button.text = "Unmark favorite" if marked else "Mark favorite"
	var sale_error: String = city.sale_error(selected_ray)
	sell_button.disabled = not sale_error.is_empty()
	sell_button.text = "Review sale · %d G" % city.sale_value(selected_ray)
	sale_note.text = sale_error if not sale_error.is_empty() else "Sale needs confirmation · training lost; collection discovery retained."
	refresh_choices()
	land_label.text = "STARTER ISLAND · %d owned sectors / %d cells" % [city.owned_sectors.size(), city.owned_sectors.size() * 16]
	var max_x: int = 7
	var max_y: int = 7
	for key in city.owned_sectors:
		var parts: PackedStringArray = key.split(",")
		max_x = maxi(max_x, int(parts[0]) * 4 + 3)
		max_y = maxi(max_y, int(parts[1]) * 4 + 3)
	coordinate_x.max_value = max_x
	coordinate_y.max_value = max_y
	var selection: String = selected_placement()
	var land_action: bool = selection.begins_with("buy_sector:") or selection.begins_with("clear_obstacle:") or selection.begins_with("store_building:")
	coordinate_x.editable = not land_action
	coordinate_y.editable = not land_action
	build_button.text = "Buy land · 250 G" if selection.begins_with("buy_sector:") else ("Clear · 50 G" if selection.begins_with("clear_obstacle:") else "Confirm placement")
	if selection.begins_with("store_building:"):
		build_button.text = "Store · no refund"
	elif selection.begins_with("restore_building:"):
		build_button.text = "Restore · free"
	cancel_build_button.disabled = city.construction.is_empty()
	cancel_build_button.text = "Cancel job" if city.construction.get("kind", "build") == "clear" else ("Cancel upgrade" if city.construction.get("kind", "build") == "upgrade" else "Cancel build")
	var job: Dictionary = city.farm_crop(selected_farm)
	var empty: bool = job.is_empty()
	plant_short.disabled = selected_farm.is_empty() or not empty or city.gold < 20
	plant_long.disabled = selected_farm.is_empty() or not empty or city.gold < 100
	harvest_button.disabled = empty or city.remaining_seconds(selected_farm) > 0
	farm_info.text = "Empty · select a paid crop" if empty else ("Ready to harvest!" if city.remaining_seconds(selected_farm) == 0 else "%s · %ds remaining" % [Model.CROPS[job["recipe"]]["name"], city.remaining_seconds(selected_farm)])
	if selected_farm.is_empty():
		farm_info.text = "Restore a farm from storage to plant."
	queue_redraw()

func iso(x: float, y: float) -> Vector2:
	var zoom: float = 0.72 if city.owned_sectors.size() > 4 or selected_placement().begins_with("buy_sector:") else 1.0
	return Vector2(370 + (x - y) * 38 * zoom, 186 + (x + y) * 20 * zoom)

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
	for key in city.owned_sectors:
		var parts: PackedStringArray = key.split(",")
		var sx: int = int(parts[0]) * 4
		var sy: int = int(parts[1]) * 4
		for y in range(sy, sy + 4):
			for x in range(sx, sx + 4):
				tile(x, y, 1, 1, Color("#8bc879") if (x+y)%2 == 0 else Color("#81bd73"))
		var points := PackedVector2Array([iso(sx,sy),iso(sx+4,sy),iso(sx+4,sy+4),iso(sx,sy+4),iso(sx,sy)])
		draw_polyline(points, Color("#d9e4a2"), 2.4, true)
	if not city.starter_obstacle.is_empty() and not city.starter_obstacle["cleared"]:
		var ox: int = city.starter_obstacle["x"]
		var oy: int = city.starter_obstacle["y"]
		tile(ox, oy, 1, 1, Color("#9a8879"))
		var center := iso(ox + 0.5, oy + 0.5)
		draw_circle(center, 12, Color("#61564f"))
		ink("Clearing %ds" % city.clearance_remaining() if city.clearance_remaining() > 0 else "Rock · 50 G", center + Vector2(-43, -15), 14)
	for building in city.buildings:
		draw_building(building)
	var selection: PackedStringArray = selected_placement().split(":")
	if selection.size() == 2 and selection[0] == "buy_sector":
		var parts: PackedStringArray = selection[1].split(",")
		var sx: int = int(parts[0]) * 4
		var sy: int = int(parts[1]) * 4
		tile(sx, sy, 4, 4, Color("#628b86"))
		ink("LAND · 250 G", iso(sx + 2, sy + 2) + Vector2(-48, 0), 16)
	elif selection.size() == 2 and selection[0] in ["build", "move", "restore_building"]:
		var b: Dictionary = Model.BUILD_TYPES.get(selection[1], {}) if selection[0] == "build" else city.find_building(selection[1])
		if selection[0] == "restore_building":
			b = city.find_stored_building(selection[1])
		if not b.is_empty():
			var x: int = int(coordinate_x.value)
			var y: int = int(coordinate_y.value)
			var footprint: int = b["size"]
			var valid: bool = city.can_place(x, y, footprint, selection[1] if selection[0] == "move" else "")
			var points := PackedVector2Array([iso(x,y),iso(x+footprint,y),iso(x+footprint,y+footprint),iso(x,y+footprint),iso(x,y)])
			draw_polyline(points, Color("#f3ffe0") if valid else Color("#ffac75"), 3.0, true)
	ink("Placement: X ↘  Y ↙ · white = free / orange = blocked", Vector2(37, 542), 16)

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
			var residents: Array[String] = city.resident_ids(id)
			for i in range(residents.size()):
				var resident: Dictionary = city.individuals[residents[i]]
				var offset: Vector2 = Vector2.ZERO if residents.size() == 1 else (Vector2(-20.0 + i * 40.0, 0) if residents.size() == 2 else Vector2(-20.0 + (i % 2) * 40.0, -13.0 + floori(i / 2.0) * 25.0))
				draw_placeholder_ray(center + offset + Vector2(0,-7), str(resident["species"]), 1.0 if residents.size() == 1 else 0.62)
			if residents.is_empty():
				ink("Empty · 0 G/min", center + Vector2(-55,7), 14)
			ink("%d/%d · %d G" % [residents.size(), city.habitat_capacity(id), city.stored_gold(id)], center + Vector2(-44,58), 15)
			if city.upgrading(id):
				ink("Paused · %ds" % city.construction_remaining(), center + Vector2(-42,35), 14)
			if city.stored_gold(id) > 0:
				draw_circle(center + Vector2(41,-33), 14, Color("#ffce63"))
				ink("G", center + Vector2(35,-28), 14, Color("#533e26"))
			ink(("Large " if city.habitat_capacity(id) == Model.LARGE_CAPACITY else "") + str(b["kind"]), center + Vector2(-65,-47), 15)
		"hatchery":
			tile(x,y,footprint,footprint,Color("#e5c58d"))
			draw_circle(center, 27, Color("#b89d72"))
			draw_circle(center + Vector2(0,-4), 15, Color("#eae2c8"))
			ink("Hatchery", center + Vector2(-36,38), 16)
			if not city.founder_egg.is_empty():
				ink("Ready!" if city.founder_remaining() == 0 else "%ds" % city.founder_remaining(), center + Vector2(-20,-25), 14)
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

func draw_placeholder_ray(ray: Vector2, species_id: String, s: float) -> void:
	# Original temporary silhouette; final treatment remains art/audio-owned.
	var colors: Dictionary = {"blueberry": Color("#6bbcdf"), "sunbeam": Color("#edca68"), "mossdrop": Color("#8dc079"), "pearlcloud": Color("#e8dbef"), "kelpskip": Color("#77cfb3"), "rosefin": Color("#eaa4bf")}
	var fill: Color = colors[species_id]
	draw_polyline(PackedVector2Array([ray+Vector2(18,8)*s,ray+Vector2(34,19)*s,ray+Vector2(42,13)*s]), fill, 4*s, true)
	draw_colored_polygon(PackedVector2Array([ray+Vector2(-4,0)*s,ray+Vector2(-38,-9)*s,ray+Vector2(-18,19)*s,ray+Vector2(11,15)*s,ray+Vector2(32,-6)*s]), fill)
	draw_circle(ray + Vector2(-7,1)*s, 18*s, fill.lightened(0.28))
	draw_circle(ray + Vector2(-15,8)*s, 7*s, Color("#f5e3bc"))
	draw_circle(ray + Vector2(-14,-3)*s, 5*s, Color("#233a52"))
	draw_circle(ray + Vector2(-15,-5)*s, 2*s, Color.WHITE)

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
	var before_egg: int = city.gold
	await click_fixture(buy_button)
	if city.gold != before_egg - 100 or city.founder_egg.is_empty():
		push_error("GUI founder purchase failed")
		get_tree().quit(1)
		return
	await get_tree().create_timer(31.0).timeout
	# Selection is set programmatically; purchase and claim use native mouse events.
	habitat_choice.select(1)
	choose_habitat(1)
	await click_fixture(place_egg_button)
	if city.individuals.size() != 2 or city.individuals["ray-2"]["species"] != "sunbeam" or city.individuals["ray-2"]["habitat_id"] != "building-1" or city.xp != 355:
		push_error("GUI founder placement failed: " + str(city.snapshot()))
		get_tree().quit(1)
		return
	await RenderingServer.frame_post_draw
	if get_viewport().get_texture().get_image().save_png(directory + "/05-two-founders.png") != OK:
		get_tree().quit(1)
		return
	print("CITY_FOUNDER_GUI_PASS: paid Sunbeam egg, ordinary 30-second incubation, compatible placement and level-three account")
	# Menu selection is programmatic; the confirm button uses native mouse events.
	for i in range(build_choice.item_count):
		if build_choice.get_item_metadata(i) == "buy_sector:2,0":
			build_choice.select(i)
			break
	refresh()
	var before_land: int = city.gold
	await click_fixture(build_button)
	if city.gold != before_land - 250 or not city.owned_sectors.has("2,0") or city.starter_obstacle.is_empty():
		push_error("GUI sector purchase failed")
		get_tree().quit(1)
		return
	for i in range(build_choice.item_count):
		if build_choice.get_item_metadata(i) == "clear_obstacle:starter-obstacle":
			build_choice.select(i)
			break
	refresh()
	var before_clear: int = city.gold
	await click_fixture(build_button)
	if city.gold != before_clear - 50 or city.clearance_remaining() <= 0 or city.can_place(9,1,1):
		push_error("GUI obstacle start failed")
		get_tree().quit(1)
		return
	await get_tree().create_timer(61.0).timeout
	if not city.starter_obstacle["cleared"] or not city.can_place(9,1,1) or city.xp != 365:
		push_error("GUI clearance deadline failed")
		get_tree().quit(1)
		return
	await RenderingServer.frame_post_draw
	if get_viewport().get_texture().get_image().save_png(directory + "/06-expanded-land.png") != OK:
		get_tree().quit(1)
		return
	print("CITY_LAND_GUI_PASS: paid adjacent sector, paid obstacle clearance, ordinary 60-second timer, exact XP and usable land")
	var before_store: int = city.gold
	for i in range(build_choice.item_count):
		if build_choice.get_item_metadata(i) == "store_building:farm-1":
			build_choice.select(i)
			break
	refresh()
	await click_fixture(build_button)
	if city.farm_ids().size() != 0 or city.find_stored_building("farm-1").is_empty() or city.gold != before_store or not plant_short.disabled:
		push_error("GUI farm storage failed")
		get_tree().quit(1)
		return
	for i in range(build_choice.item_count):
		if build_choice.get_item_metadata(i) == "restore_building:farm-1":
			build_choice.select(i)
			break
	coordinate_x.value = 5
	coordinate_y.value = 3
	refresh()
	await click_fixture(build_button)
	if not city.farm_ids().has("farm-1") or city.gold != before_store or city.xp != 365:
		push_error("GUI farm restore failed")
		get_tree().quit(1)
		return
	await click_fixture(favorite_button)
	if not city.individuals[selected_ray]["favorite"] or not sell_button.disabled:
		push_error("GUI favorite protection failed")
		get_tree().quit(1)
		return
	await click_fixture(favorite_button)
	await click_fixture(sell_button)
	if not sale_dialog.visible or city.individuals.size() != 2 or city.gold != before_store:
		push_error("GUI sale preview changed ownership or failed to open")
		get_tree().quit(1)
		return
	# Cancel programmatically; a real click opened the confirmation, but
	# modal confirmation input is not asserted by this native fixture.
	sale_dialog.hide()
	await RenderingServer.frame_post_draw
	if get_viewport().get_texture().get_image().save_png(directory + "/07-storage-recovery.png") != OK:
		get_tree().quit(1)
		return
	print("CITY_SAFEGUARD_GUI_PASS: native store/restore and favorite clicks, sale preview without removal; modal canceled programmatically")
	get_tree().quit(0)
