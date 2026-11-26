extends Control

const Model = preload("res://city_model.gd")
const Adapter = preload("res://checkpoint_adapter.gd")
# Keep the map header, playable projection and bottom hint in distinct bands.
const MAP_INPUT_RECT := Rect2(18, 198, 716, 336)
const MAP_ORIGIN := Vector2(370, 222)
const OPENING_MAP_ZOOM: float = 0.94
const EXPANDED_MAP_ZOOM: float = 0.72
const GOLD_MARKER_OFFSET := Vector2(41, -33)
const GOLD_MARKER_RADIUS: float = 14.0
var city = Model.new()
var adapter = Adapter.new()
# Optional architect-owned session, injected before this view enters the tree.
# The standalone developer scene remains explicitly memory-only.
var profile_session: Variant = null
var profile_confirmed: bool = false
var profile_view_invalid: bool = false
var profile_footer: Label
var profile_overlay: ColorRect
var profile_overlay_text: Label
var profile_pending_kind: String = ""
var profile_pending_placement: Vector2i = Vector2i.ZERO
const PROFILE_TICK_MS: int = 1000
# The elapsed sample and the next background-write deadline are distinct.
# A slow acknowledgement must not consume the next interactive ready window.
var profile_ready_since_ms: int = 0
var last_ms: int = 0
var op_count: int = 0
var status_label: Label
var wallet: Label
var goal_label: Label
var ray_info: Label
var farm_info: Label
var collect_button: Button
var sample_button: Button
var plant_short: Button
var plant_long: Button
var harvest_button: Button
var feed_button: Button
var level_button: Button
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
var collection_button: Button
var collection_dialog: AcceptDialog
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
var map_place_mode: bool = false
var map_mode_button: Button
var cancel_preview_button: Button
var map_dragging: bool = false
var preview_origin: Vector2i = Vector2i.ZERO
var drag_origin: Vector2i = Vector2i.ZERO

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

## The integration root starts the session (web or native test port) before
## adding the scene. Never silently fall back from an attached failed session.
func configure_profile_session(session: Variant) -> bool:
	if is_inside_tree() or session == null or profile_session != null:
		return false
	profile_session = session
	return true

func _ready() -> void:
	last_ms = Time.get_ticks_msec()
	label_at("LITTLE RAY   /   BLUEBERRY REEF", Vector2(28, 15), Vector2(650, 40), 27)
	wallet = label_at("", Vector2(30, 66), Vector2(1040, 40), 23)
	goal_label = label_at("", Vector2(650, 12), Vector2(418, 49), 16)
	goal_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	goal_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
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
	feed_button.size = Vector2(151, 44)
	feed_button.add_theme_font_size_override("font_size", 16)
	level_button = button_at("Level +1", Vector2(917, 342), func(): act("feed_level", selected_ray))
	level_button.size = Vector2(151, 44)
	level_button.add_theme_font_size_override("font_size", 15)
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
	map_mode_button = button_at("Map: tend / collect", Vector2(30, 145), toggle_map_mode)
	map_mode_button.size = Vector2(250, 44)
	map_mode_button.add_theme_font_size_override("font_size", 15)
	cancel_preview_button = button_at("Cancel preview", Vector2(290, 145), cancel_map_preview)
	cancel_preview_button.size = Vector2(175, 44)
	cancel_preview_button.add_theme_font_size_override("font_size", 15)
	cancel_preview_button.disabled = true
	status_label = label_at("Tap a habitat or farm to collect; switch map mode to choose a placement.", Vector2(30, 617), Vector2(700, 34), 16)
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	profile_footer = label_at("DEV CHECKPOINT · Session only; random breeding, battle and production art not yet wired.", Vector2(30, 655), Vector2(1040, 22), 15)
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
	collection_info = label_at("", Vector2(30, 788), Vector2(740, 36), 15)
	collection_button = button_at("Open Collection Book", Vector2(800, 784), open_collection)
	collection_button.size = Vector2(268, 44)
	collection_dialog = AcceptDialog.new()
	collection_dialog.title = "Collection Book · six-species slice"
	collection_dialog.ok_button_text = "Back to island"
	add_child(collection_dialog)
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
	refresh()
	if profile_session != null:
		setup_profile_overlay()
		update_profile_display()
	else:
		adapter.capture(city.snapshot())
	var args := OS.get_cmdline_user_args()
	if profile_session == null and args.size() == 2 and args[0] == "--capture-city":
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

# Read-only projection: discoveries survive sale; owned copies are counted separately.
func collection_text() -> String:
	var lines := PackedStringArray()
	lines.append("%d of %d species discovered · %d rays owned" % [city.discoveries.size(), Model.SPECIES.size(), city.individuals.size()])
	lines.append("")
	for id in Model.SPECIES:
		var species: Dictionary = Model.SPECIES[id]
		var copies: int = 0
		for individual in city.individuals.values():
			if individual["species"] == id:
				copies += 1
		var discovery: String = "Discovered" if city.discoveries.has(id) else "Undiscovered"
		var source_hint: String = str(species["source"])
		if Model.FOUNDER_GATES.has(id):
			source_hint += " · 100 Gold · account Lv %d" % int(Model.FOUNDER_GATES[id])
		else:
			source_hint += " · breeding not yet available"
		lines.append("%s · %s · %s" % [species["name"], species["rarity"], "/".join(PackedStringArray(species["elements"]))])
		lines.append("    %s · Owned: %d · %s" % [discovery, copies, source_hint])
	lines.append("")
	lines.append("Discovery is retained if you sell your last copy of a species.")
	return "\n".join(lines)

func open_collection() -> void:
	collection_dialog.dialog_text = collection_text()
	collection_dialog.popup_centered(Vector2i(760, 480))

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

func placement_coordinates() -> Vector2i:
	return Vector2i(int(coordinate_x.value), int(coordinate_y.value))

func set_placement_coordinates(cell: Vector2i) -> void:
	coordinate_x.value = cell.x
	coordinate_y.value = cell.y
	queue_redraw()

func cancel_map_preview() -> void:
	if not map_place_mode:
		return
	set_placement_coordinates(preview_origin)
	map_dragging = false
	map_place_mode = false
	map_mode_button.text = "Map: tend / collect"
	cancel_preview_button.disabled = true
	status_label.text = "Placement preview canceled. No city changes."

func toggle_map_mode() -> void:
	if map_place_mode:
		cancel_map_preview()
		return
	preview_origin = placement_coordinates()
	map_place_mode = true
	map_mode_button.text = "Map: choose placement"
	cancel_preview_button.disabled = false
	status_label.text = "Tap or drag a cell to preview. Confirm or cancel; no Gold spent yet."
	queue_redraw()

func map_cell(point: Vector2) -> Vector2i:
	# Invert the actual isometric projection, including its current zoom.
	var origin := iso(0, 0)
	var axis := iso(1, 0) - origin
	var delta := point - origin
	return Vector2i(floori((delta.x / axis.x + delta.y / axis.y) / 2.0), floori((delta.y / axis.y - delta.x / axis.x) / 2.0))

func previewable_selection() -> bool:
	var parts := selected_placement().split(":")
	return parts.size() == 2 and parts[0] in ["build", "move", "restore_building"]

func map_point_is_usable(point: Vector2) -> bool:
	if not MAP_INPUT_RECT.has_point(point):
		return false
	var cell := map_cell(point)
	return cell.x >= 0 and cell.y >= 0 and cell.x < Model.ISLAND_SIZE and cell.y < Model.ISLAND_SIZE

func preview_point(point: Vector2) -> bool:
	if not previewable_selection() or not map_point_is_usable(point):
		return false
	var cell := map_cell(point)
	if cell.x > coordinate_x.max_value or cell.y > coordinate_y.max_value:
		return false
	set_placement_coordinates(cell)
	status_label.text = "Preview cell (%d,%d) · confirm or cancel below." % [cell.x, cell.y]
	return true

# Gold markers live in screen space, not inside the inverse-projected tile.
func gold_marker_center(b: Dictionary) -> Vector2:
	var half: float = float(b["size"]) * 0.5
	return iso(float(b["x"]) + half, float(b["y"]) + half) + GOLD_MARKER_OFFSET

func gold_marker_at(point: Vector2) -> String:
	if not MAP_INPUT_RECT.has_point(point):
		return ""
	var target: String = ""
	var nearest: float = GOLD_MARKER_RADIUS * GOLD_MARKER_RADIUS
	for id in city.habitat_ids():
		if city.stored_gold(id) <= 0:
			continue
		var distance: float = point.distance_squared_to(gold_marker_center(city.find_building(id)))
		# Nearest visible marker wins; ties follow the last drawn marker.
		if distance <= nearest:
			nearest = distance
			target = id
	return target

func tend_habitat(id: String) -> void:
	for i in range(habitat_choice.item_count):
		if habitat_choice.get_item_metadata(i) == id:
			habitat_choice.select(i)
			choose_habitat(i)
			break
	if city.stored_gold(id) > 0:
		act("collect", id)
	else:
		status_label.text = "%s selected · no whole Gold ready." % city.find_building(id)["kind"]

func _gui_input(event: InputEvent) -> void:
	if profile_session != null and (profile_view_invalid or not profile_confirmed or profile_session.status() != "ready"):
		accept_event()
		return
	# In placement mode a drag only edits the preview. Release never commits.
	# Child controls retain their own GUI events; touch uses mouse emulation.
	if map_place_mode and event is InputEventMouseMotion:
		if map_dragging and (event.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0:
			preview_point(event.position)
			accept_event()
		return
	if not (event is InputEventMouseButton) or event.button_index != MOUSE_BUTTON_LEFT:
		return
	if map_place_mode:
		if event.pressed:
			if not map_point_is_usable(event.position):
				return
			accept_event()
			if not previewable_selection():
				status_label.text = "This action has its own target. Use the confirmation control below."
				return
			drag_origin = placement_coordinates()
			map_dragging = true
			preview_point(event.position)
		elif map_dragging:
			map_dragging = false
			accept_event()
			if not preview_point(event.position):
				set_placement_coordinates(drag_origin)
				status_label.text = "Outside placement area · previous preview restored."
		return
	if event.pressed:
		return
	var marker_id := gold_marker_at(event.position)
	if not marker_id.is_empty():
		accept_event()
		tend_habitat(marker_id)
		return
	if not map_point_is_usable(event.position):
		return
	var cell := map_cell(event.position)
	accept_event()
	for b in city.buildings:
		var footprint := Rect2i(int(b["x"]), int(b["y"]), int(b["size"]), int(b["size"]))
		if not footprint.has_point(cell):
			continue
		var id: String = str(b["id"])
		if city.pending(id):
			status_label.text = "Construction · %ds remaining" % city.construction_remaining()
			return
		if city.habitat_ids().has(id):
			tend_habitat(id)
		elif city.farm_ids().has(id):
			for i in range(farm_choice.item_count):
				if farm_choice.get_item_metadata(i) == id:
					farm_choice.select(i)
					choose_farm(i)
					break
			if not city.farm_crop(id).is_empty() and city.remaining_seconds(id) == 0:
				act("harvest", id)
			else:
				status_label.text = farm_info.text
		else:
			status_label.text = "%s selected · see its controls below." % b["kind"]
		return
	status_label.text = "Select a building, or switch map mode to preview a placement."

func setup_profile_overlay() -> void:
	profile_overlay = ColorRect.new()
	profile_overlay.color = Color("#183d4b")
	profile_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	profile_overlay.focus_mode = Control.FOCUS_ALL
	add_child(profile_overlay)
	profile_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	profile_overlay.hide()
	profile_overlay_text = Label.new()
	profile_overlay_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	profile_overlay_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	profile_overlay_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	profile_overlay_text.add_theme_font_size_override("font_size", 24)
	profile_overlay.add_child(profile_overlay_text)
	profile_overlay_text.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func update_profile_display() -> void:
	var state: String = "unavailable" if profile_view_invalid else profile_session.status()
	var terminal: bool = state in ["unavailable", "read-only", "new"]
	var text: String = "Opening saved city…"
	if state == "saving":
		text = "Saving… · city changes await confirmation"
	elif state == "ready" and profile_confirmed:
		text = "Saved · breeding, battle and production art not yet wired"
	elif terminal:
		text = "Save unavailable · invalid confirmed city. Reload." if profile_view_invalid else str(profile_session.last_result().get("message", "Save unavailable. Reload to reconcile."))
	profile_footer.text = text
	# Before the first acknowledged checkpoint, conceal the placeholder city.
	# On failure after acknowledgement, retain the last confirmed view beneath
	# a blocking overlay rather than grant access to a new unsaved city.
	var block_view: bool = not profile_confirmed or terminal
	if block_view:
		profile_overlay.color = Color(0.09, 0.24, 0.29, 0.86 if profile_confirmed else 1.0)
		profile_overlay_text.text = text
	if block_view and not profile_overlay.visible:
		profile_overlay.show()
		profile_overlay.grab_focus()
	elif not block_view and profile_overlay.visible:
		profile_overlay.hide()

func process_profile(now: int, wall_ms: int) -> void:
	if profile_view_invalid:
		return
	var before: String = profile_session.status()
	if before in ["opening", "saving"]:
		profile_session.poll(wall_ms)
		var after: String = profile_session.status()
		# Opening settles wall-clock offline time at this sample. Accumulate
		# subsequent monotonic time, including time spent awaiting writes.
		if before == "opening" and after == "saving":
			last_ms = now
		if after == "ready":
			var confirmed: Dictionary = profile_session.snapshot()
			if not city.restore_snapshot(confirmed):
				# A contract breach is never a license to show speculative effects.
				profile_view_invalid = true
				update_profile_display()
				return
			var first_confirmation: bool = not profile_confirmed
			profile_confirmed = true
			profile_ready_since_ms = now
			var result: Dictionary = profile_session.last_result()
			var rename_confirmed: bool = profile_pending_kind == "rename"
			if not profile_pending_kind.is_empty():
				status_label.text = str(result.get("message", ""))
				if result.get("ok", false) and map_place_mode and profile_pending_kind in ["build", "move", "restore_building"]:
					preview_origin = profile_pending_placement
				profile_pending_kind = ""
			refresh()
			if first_confirmation or rename_confirmed:
				name_edit.text = str(city.individuals[selected_ray]["nickname"])
		update_profile_display()
		return
	# Give ordinary controls a full ready interval after each confirmation.
	# Preserve the complete elapsed sample (including acknowledgement latency).
	if before == "ready" and profile_confirmed and now - profile_ready_since_ms >= PROFILE_TICK_MS and now - last_ms >= PROFILE_TICK_MS:
		if profile_session.stage_tick(maxi(0, now - last_ms), wall_ms):
			last_ms = now
	update_profile_display()

func _process(_delta: float) -> void:
	var now := Time.get_ticks_msec()
	if profile_session != null:
		process_profile(now, int(Time.get_unix_time_from_system() * 1000.0))
		return
	var previous_revision: int = city.revision
	var previous_xp: int = city.xp
	city.advance(maxi(0, now - last_ms))
	last_ms = now
	if city.revision != previous_revision:
		adapter.capture(city.snapshot())
		status_label.text = "Builder job complete · +%d account XP" % (city.xp - previous_xp)
	refresh()

# Reconstruct the high-water mark on restore. If a valid imported receipt is
# at the serial ceiling, walk unused IDs instead of overflowing or reusing it.
func next_ui_operation_id() -> String:
	var highest: int = op_count
	for key in city.receipts.keys():
		highest = maxi(highest, Model.ui_operation_serial(str(key)))
	if highest < Model.CHECKPOINT_MAX_INTEGER:
		op_count = highest + 1
	else:
		# There are fewer committed receipts than the serial space; each occupied
		# candidate is skipped, including after wrap. No receipt is removed.
		while true:
			op_count = 1 if op_count >= Model.CHECKPOINT_MAX_INTEGER else op_count + 1
			if not city.receipts.has("ui-%d" % op_count):
				break
	return "ui-%d" % op_count

func act(kind: String, value: String) -> void:
	var now := Time.get_ticks_msec()
	if profile_session != null:
		if profile_view_invalid or not profile_confirmed or profile_session.status() != "ready":
			status_label.text = "City not ready · wait for save confirmation or reload."
			return
		if profile_session.stage_command(kind, value, next_ui_operation_id(), city.revision, maxi(0, now - last_ms), int(Time.get_unix_time_from_system() * 1000.0)):
			last_ms = now
			profile_pending_kind = kind
			profile_pending_placement = placement_coordinates()
			status_label.text = "Saving action…"
		else:
			status_label.text = "Action not queued · check save status."
		update_profile_display()
		return
	var previous_revision: int = city.revision
	city.advance(maxi(0, now - last_ms))
	last_ms = now
	var result: Dictionary = city.command(kind, value, next_ui_operation_id(), city.revision)
	status_label.text = str(result["message"])
	# A builder deadline can commit XP/state before a now-invalid action.
	# Capture that independent transition even when the command is rejected.
	if result["ok"] or city.revision != previous_revision:
		adapter.capture(city.snapshot())
	if result["ok"]:
		if map_place_mode and kind in ["build", "move", "restore_building"]:
			preview_origin = placement_coordinates()
	refresh()

# Read-only projection of the same housing validator used by the command.
# Disabled previews never reserve a home, spend Gold, or consume the egg.
func refresh_founder_controls() -> void:
	var founder_id: String = str(shop_choice.get_item_metadata(shop_choice.selected))
	var gate: int = int(Model.FOUNDER_GATES[founder_id])
	var buy_reason: String = ""
	if city.find_building("hatchery-1").is_empty():
		buy_reason = "Restore hatchery"
	elif not city.founder_egg.is_empty():
		buy_reason = "Hatchery occupied"
	elif city.account_level() < gate:
		buy_reason = "Unlock at Lv %d" % gate
	elif city.gold < 100:
		buy_reason = "Need 100 Gold"
	buy_button.disabled = not buy_reason.is_empty()
	buy_button.text = buy_reason if buy_button.disabled else "Buy founder egg"
	buy_button.tooltip_text = buy_reason
	# Apply only the final availability state on each frame. Toggling a ready
	# button disabled then enabled cancels an in-flight mouse press.
	if city.founder_egg.is_empty():
		place_egg_button.disabled = true
		place_egg_button.tooltip_text = ""
		egg_info.text = "Restore hatchery from storage" if city.find_building("hatchery-1").is_empty() else "Hatchery empty · buy a founder"
		return
	var species_id: String = str(city.founder_egg["species"])
	var egg_name: String = str(Model.SPECIES[species_id]["name"])
	if city.founder_remaining() > 0:
		place_egg_button.disabled = true
		place_egg_button.tooltip_text = ""
		egg_info.text = "%s · %ds to hatch" % [egg_name, city.founder_remaining()]
		return
	var error: String = city.housing_error(species_id, selected_habitat)
	place_egg_button.disabled = not error.is_empty()
	place_egg_button.tooltip_text = error
	if error.is_empty():
		egg_info.text = "%s ready · Place in selected habitat." % egg_name
		return
	var elements: String = " or ".join(PackedStringArray(Model.SPECIES[species_id]["elements"]))
	for habitat_id in city.habitat_ids():
		if city.housing_error(species_id, habitat_id).is_empty():
			egg_info.text = "%s ready · Choose %s habitat with space." % [egg_name, elements]
			return
	egg_info.text = "%s ready · No free %s housing. Build, upgrade or move a resident." % [egg_name, elements]

# Read-only onboarding guidance from committed city state; no new rewards,
# progression gates, forced actions or breeding behavior are introduced.
func next_city_goal() -> String:
	if not city.sample_claimed:
		return "Claim the tutorial sample (+10 Gold, +100 XP)."
	if not city.founder_placed_milestone:
		if city.find_building("hatchery-1").is_empty():
			return "Restore the hatchery from storage."
		if city.founder_egg.is_empty():
			return "Buy Sunbeam's 100-Gold egg." if city.gold >= 100 else "Collect habitat Gold for Sunbeam's egg."
		var species_id: String = str(city.founder_egg["species"])
		var egg_name: String = str(Model.SPECIES[species_id]["name"])
		var compatible: bool = false
		for habitat_id in city.habitat_ids():
			if city.housing_error(species_id, habitat_id).is_empty():
				compatible = true
				break
		if not compatible:
			var elements: String = " or ".join(PackedStringArray(Model.SPECIES[species_id]["elements"]))
			return "Prepare %s housing with a free slot." % elements
		if city.founder_remaining() > 0:
			return "%s incubating · %ds remaining." % [egg_name, city.founder_remaining()]
		return "Select compatible housing and place %s." % egg_name
	if not city.trained_founders_milestone:
		for species_id in ["blueberry", "sunbeam"]:
			var best_id: String = ""
			for ray_id in city.individuals:
				var ray: Dictionary = city.individuals[ray_id]
				if ray["species"] != species_id:
					continue
				if best_id.is_empty() or int(ray["level"]) > int(city.individuals[best_id]["level"]):
					best_id = str(ray_id)
			var species_name: String = str(Model.SPECIES[species_id]["name"])
			if best_id.is_empty():
				return "Acquire another %s founder." % species_name
			if int(city.individuals[best_id]["level"]) < 4:
				if city.food < city.feed_level_cost(best_id):
					return "Grow Food to train %s to Lv 4." % species_name
				return "Train %s to Lv 4." % species_name
		for building in city.buildings:
			if building["type"] == "grotto" and city.pending(str(building["id"])):
				return "Wait for the breeding grotto to finish."
		return "Build or restore the breeding grotto."
	return "City tutorial ready · breeding is not yet wired."

func refresh() -> void:
	goal_label.text = "NEXT · " + next_city_goal()
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
	feed_button.text = "Feed · %d Food" % cost if cost > 0 else "Level cap"
	var next_cost: int = city.feed_level_cost(selected_ray)
	level_button.disabled = next_cost <= 0 or city.food < next_cost
	level_button.text = "Lv +1 · %d Food" % next_cost if next_cost > 0 else "Level cap"
	level_button.tooltip_text = "Complete %d remaining feed pips for %d Food." % [4 - int(ray["pips"]), next_cost] if next_cost > 0 else "Maximum trainable level in this slice."
	move_ray_button.disabled = ray["habitat_id"] == selected_habitat
	refresh_founder_controls()
	collection_info.text = "Collection %d/%d discovered · %d owned · inspect species and sources" % [city.discoveries.size(), Model.SPECIES.size(), city.individuals.size()]
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
	var zoom: float = EXPANDED_MAP_ZOOM if city.owned_sectors.size() > 4 or selected_placement().begins_with("buy_sector:") else OPENING_MAP_ZOOM
	return MAP_ORIGIN + Vector2((x - y) * 38 * zoom, (x + y) * 20 * zoom)

func tile(x: float, y: float, w: float, h: float, fill: Color) -> void:
	var points := PackedVector2Array([iso(x,y),iso(x+w,y),iso(x+w,y+h),iso(x,y+h)])
	draw_colored_polygon(points, fill)
	draw_polyline(PackedVector2Array([points[0],points[1],points[2],points[3],points[0]]), Color("#486e5f"), 1.1, true)

func ink(value: String, pos: Vector2, font_size: int, color: Color = Color("#eef9ef")) -> void:
	draw_string(ThemeDB.fallback_font, pos, value, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)

func _draw() -> void:
	draw_rect(Rect2(18, 109, 716, 456), Color("#12617a"))
	draw_circle(Vector2(370, 345), 220, Color("#197d8c"))
	# Paint a distinct noninteractive header behind the land title and map controls.
	draw_rect(Rect2(18, 109, 716, 89), Color("#183d4b"))
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
	# Draw collection markers last so a neighboring building cannot hide a live hit target.
	for id in city.habitat_ids():
		if city.stored_gold(id) > 0:
			var marker := gold_marker_center(city.find_building(id))
			draw_circle(marker, GOLD_MARKER_RADIUS, Color("#ffce63"))
			ink("G", marker + Vector2(-6, 5), 14, Color("#533e26"))
	ink("Tap a building to tend · map placement mode previews only" if not map_place_mode else "Tap or drag · white = free / orange = blocked · confirm / cancel", Vector2(37, 542), 15)

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
	await click_point_fixture(button.get_global_rect().get_center())

func click_point_fixture(point: Vector2) -> void:
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

func drag_point_fixture(start: Vector2, finish: Vector2) -> void:
	var down := InputEventMouseButton.new()
	down.position = start
	down.global_position = start
	down.button_index = MOUSE_BUTTON_LEFT
	down.pressed = true
	Input.parse_input_event(down)
	await get_tree().process_frame
	var motion := InputEventMouseMotion.new()
	motion.position = finish
	motion.global_position = finish
	motion.relative = finish - start
	motion.button_mask = MOUSE_BUTTON_MASK_LEFT
	Input.parse_input_event(motion)
	await get_tree().process_frame
	var up := InputEventMouseButton.new()
	up.position = finish
	up.global_position = finish
	up.button_index = MOUSE_BUTTON_LEFT
	up.pressed = false
	Input.parse_input_event(up)
	await get_tree().process_frame
	await get_tree().process_frame

func map_layout_fixture_ok() -> bool:
	# Test the actual control bounds and every owned cell center at the live zoom.
	for control in [map_mode_button, cancel_preview_button]:
		if control.get_rect().end.y > MAP_INPUT_RECT.position.y or control.size.y < 44 or map_point_is_usable(control.get_rect().get_center()):
			return false
	# At (0,0) the tallest current habitat title has the least clearance.
	if iso(1.5, 1.5).y - 47.0 - 15.0 < MAP_INPUT_RECT.position.y:
		return false
	for key in city.owned_sectors:
		var parts: PackedStringArray = key.split(",")
		var sx: int = int(parts[0]) * 4
		var sy: int = int(parts[1]) * 4
		for y in range(sy, sy + 4):
			for x in range(sx, sx + 4):
				var point := iso(x + 0.5, y + 0.5)
				if not map_point_is_usable(point) or map_cell(point) != Vector2i(x, y):
					return false
	return true

func capture_fixture(directory: String) -> void:
	# CI-only native GUI fixture; no acceleration in normal play.
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	if get_viewport().get_texture().get_image().save_png(directory + "/01-opening.png") != OK:
		get_tree().quit(1)
		return
	if not map_layout_fixture_ok():
		push_error("Opening map header or cell projection regression")
		get_tree().quit(1)
		return
	var initial_state: Dictionary = city.snapshot()
	if not goal_label.text.contains("Claim the tutorial sample") or next_city_goal() != "Claim the tutorial sample (+10 Gold, +100 XP)." or city.snapshot() != initial_state:
		push_error("Opening goal missing or mutated city state")
		get_tree().quit(1)
		return
	var opening_book: String = collection_text()
	if not opening_book.contains("1 of 6 species discovered · 1 rays owned") or not opening_book.contains("Undiscovered · Owned: 0 · Tide × Light · breeding not yet available"):
		push_error("Opening collection projection incorrect")
		get_tree().quit(1)
		return
	# A locked founder must be visibly unavailable and not debit the wallet.
	shop_choice.select(2)
	refresh()
	if not buy_button.disabled or buy_button.text != "Unlock at Lv 4" or city.gold != 1200 or city.revision != 0:
		push_error("Locked founder preview failed")
		get_tree().quit(1)
		return
	shop_choice.select(0)
	refresh()
	await click_fixture(sample_button)
	if not goal_label.text.contains("Buy Sunbeam"):
		push_error("Goal did not advance after sample claim")
		get_tree().quit(1)
		return
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
	await click_point_fixture(iso(1.5, 1.5))
	await click_point_fixture(iso(6.0, 4.0))
	if city.gold < 1192 or city.food != 275 or city.xp != 105 or not city.crop.is_empty() or city.pips != 1:
		push_error("GUI real-time harvest fixture failed: " + str(city.snapshot()))
		get_tree().quit(1)
		return
	await RenderingServer.frame_post_draw
	if get_viewport().get_texture().get_image().save_png(directory + "/03-earned-and-harvested.png") != OK:
		get_tree().quit(1)
		return
	print("CITY_GUI_INPUT_PASS: sample, paid planting, feed, real-time resident collect and crop harvest by native map clicks")
	var before_build: int = city.gold
	await click_fixture(map_mode_button)
	await click_point_fixture(iso(0.5, 0.5))
	if not map_place_mode or coordinate_x.value != 0 or coordinate_y.value != 0 or city.gold != before_build or not city.construction.is_empty():
		push_error("GUI occupied cell preview changed city or missed click")
		get_tree().quit(1)
		return
	await click_fixture(cancel_preview_button)
	if map_place_mode or placement_coordinates() != Vector2i(3, 0) or city.gold != before_build or not city.construction.is_empty():
		push_error("GUI cancel preview did not restore original coordinates")
		get_tree().quit(1)
		return
	await click_fixture(map_mode_button)
	await drag_point_fixture(iso(0.5, 0.5), iso(3.5, 0.5))
	if coordinate_x.value != 3 or coordinate_y.value != 0 or city.gold != before_build or not city.construction.is_empty():
		push_error("GUI drag preview missed target or charged before confirmation")
		get_tree().quit(1)
		return
	await click_fixture(build_button)
	await click_fixture(map_mode_button)
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
	print("CITY_BUILD_GUI_PASS: occupied preview, explicit cancel, native drag preview without spending, paid Light habitat confirmation and ordinary 30-second construction")
	var before_egg: int = city.gold
	await click_fixture(buy_button)
	if city.gold != before_egg - 100 or city.founder_egg.is_empty():
		push_error("GUI founder purchase failed")
		get_tree().quit(1)
		return
	if not goal_label.text.contains("Sunbeam incubating"):
		push_error("Goal did not identify active founder incubation")
		get_tree().quit(1)
		return
	await get_tree().create_timer(31.0).timeout
	if not goal_label.text.contains("place Sunbeam"):
		push_error("Goal did not identify ready founder")
		get_tree().quit(1)
		return
	# The starter Tide habitat cannot house a Light founder. A native click
	# on the disabled button must leave the ready egg and wallet untouched.
	habitat_choice.select(0)
	choose_habitat(0)
	refresh()
	var blocked_revision: int = city.revision
	var blocked_gold: int = city.gold
	var blocked_egg: Dictionary = city.founder_egg.duplicate(true)
	if not place_egg_button.disabled or not egg_info.text.contains("Choose Light habitat with space") or not place_egg_button.tooltip_text.contains("Element mismatch"):
		push_error("Ready founder housing guidance failed")
		get_tree().quit(1)
		return
	await click_fixture(place_egg_button)
	if city.revision != blocked_revision or city.gold != blocked_gold or city.founder_egg != blocked_egg or city.individuals.size() != 1:
		push_error("Disabled mismatched placement changed state")
		get_tree().quit(1)
		return
	# Selection is set programmatically; purchase and claim use native mouse events.
	habitat_choice.select(1)
	choose_habitat(1)
	refresh()
	if place_egg_button.disabled or not egg_info.text.contains("Place in selected habitat"):
		push_error("Compatible founder placement did not become available")
		get_tree().quit(1)
		return
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
	if not map_layout_fixture_ok():
		push_error("Expanded map header or cell projection regression")
		get_tree().quit(1)
		return
	print("CITY_MAP_LAYOUT_GUI_PASS: map controls outside input band, 44-unit button heights, all owned cell centers reachable at opening and expanded zoom")
	# Native regression: at expanded zoom the starter marker projects outside
	# the island; a moved Light marker projects inside the adjacent Tide home.
	# Existing real-time construction/clearance waits have accrued both bins.
	act("move", "building-1,0,3")
	var light_marker := gold_marker_center(city.find_building("building-1"))
	var tide_marker := gold_marker_center(city.find_building("tide-1"))
	var tide_footprint := Rect2i(0, 0, 3, 3)
	if not tide_footprint.has_point(map_cell(light_marker)) or map_point_is_usable(tide_marker) or gold_marker_at(light_marker) != "building-1" or gold_marker_at(tide_marker) != "tide-1":
		push_error("Gold marker regression fixture did not reproduce expanded geometry")
		get_tree().quit(1)
		return
	var marker_gold: int = city.gold
	var marker_revision: int = city.revision
	await click_fixture(map_mode_button)
	await click_point_fixture(light_marker)
	if not map_place_mode or city.gold != marker_gold or city.revision != marker_revision:
		push_error("Placement mode must not collect Gold markers")
		get_tree().quit(1)
		return
	await click_fixture(cancel_preview_button)
	var light_ready: int = city.stored_gold("building-1")
	var tide_ready: int = city.stored_gold("tide-1")
	await click_point_fixture(light_marker)
	if light_ready <= 0 or tide_ready <= 0 or selected_habitat != "building-1" or city.revision != marker_revision + 1 or city.gold - marker_gold < light_ready or city.gold - marker_gold > light_ready + 1 or city.stored_gold("building-1") != 0 or city.stored_gold("tide-1") < tide_ready:
		push_error("Expanded Light marker failed to collect its own bin exactly once")
		get_tree().quit(1)
		return
	marker_gold = city.gold
	tide_ready = city.stored_gold("tide-1")
	await click_point_fixture(tide_marker)
	if selected_habitat != "tide-1" or city.revision != marker_revision + 2 or city.gold - marker_gold < tide_ready or city.gold - marker_gold > tide_ready + 1 or city.stored_gold("tide-1") != 0 or gold_marker_at(tide_marker) != "":
		push_error("Expanded Tide marker outside footprint failed to collect")
		get_tree().quit(1)
		return
	marker_gold = city.gold
	await click_point_fixture(tide_marker)
	if city.gold != marker_gold or city.revision != marker_revision + 2:
		push_error("Empty marker location collected again")
		get_tree().quit(1)
		return
	act("move", "building-1,3,0")
	if int(city.find_building("building-1")["x"]) != 3 or int(city.find_building("building-1")["y"]) != 0:
		push_error("Gold marker fixture did not restore Light habitat")
		get_tree().quit(1)
		return
	print("CITY_GOLD_MARKER_GUI_PASS: expanded off-footprint and adjacent-footprint marker clicks, independent bins, no repeat credit, placement mode preserved")
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
	refresh()
	await click_fixture(map_mode_button)
	await click_point_fixture(iso(5.5, 3.5))
	if coordinate_x.value != 5 or coordinate_y.value != 3 or city.gold != before_store:
		push_error("GUI expanded zoom restore preview failed")
		get_tree().quit(1)
		return
	await click_fixture(build_button)
	await click_fixture(map_mode_button)
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
	await get_tree().process_frame
	var quote: int = city.feed_level_cost(selected_ray)
	var prior_food: int = city.food
	var prior_level: int = int(city.individuals[selected_ray]["level"])
	if quote <= 0 or level_button.disabled or not level_button.text.contains(str(quote)):
		push_error("GUI level-up quote missing")
		get_tree().quit(1)
		return
	await click_fixture(level_button)
	if city.food != prior_food - quote or int(city.individuals[selected_ray]["level"]) != prior_level + 1 or int(city.individuals[selected_ray]["pips"]) != 0:
		push_error("GUI level-up did not settle exactly once")
		get_tree().quit(1)
		return
	print("CITY_LEVEL_GUI_PASS: visible remaining-pip quote and native level-up action")
	var book_revision: int = city.revision
	var book_gold: int = city.gold
	var book_food: int = city.food
	await click_fixture(collection_button)
	var book: String = collection_dialog.dialog_text
	if not collection_dialog.visible or not book.contains("2 of 6 species discovered · 2 rays owned") or not book.contains("Sunbeam · Common · Light") or not book.contains("Discovered · Owned: 1 · Founder shop") or not book.contains("Mossdrop · Common · Bloom") or not book.contains("account Lv 4") or not book.contains("Rosefin · Rare · Bloom/Light") or city.revision != book_revision or city.gold != book_gold or city.food != book_food:
		push_error("Collection Book GUI fixture missing records or changed city state")
		get_tree().quit(1)
		return
	await RenderingServer.frame_post_draw
	if get_viewport().get_texture().get_image().save_png(directory + "/08-collection-book.png") != OK:
		get_tree().quit(1)
		return
	collection_dialog.hide()
	print("CITY_COLLECTION_GUI_PASS: native Collection Book open, six catalog records, discovered/owned distinctions, source hints and no wallet mutation")
	if not goal_label.text.contains("Lv 4"):
		push_error("Goal did not advance to founder training")
		get_tree().quit(1)
		return
	print("CITY_GOAL_GUI_PASS: read-only opening goal, sample, incubation, ready placement and training guidance")
	# Simulate a reconstructed view counter over a retained committed ledger.
	# This does not exercise disk restore, wall clocks or a second writer.
	var first_feed_revision: int = city.revision
	var first_feed: Dictionary = city.command("feed", "ray-1", "ui-1000", first_feed_revision)
	if not first_feed["ok"] or not city.receipts.has("ui-1000"):
		push_error("UI operation fixture could not seed sparse receipt")
		get_tree().quit(1)
		return
	op_count = 0
	var fresh_cost: int = city.feed_cost("ray-1")
	var fresh_food: int = city.food
	var fresh_revision: int = city.revision
	act("feed", "ray-1")
	if fresh_cost <= 0 or city.food != fresh_food - fresh_cost or city.revision != fresh_revision + 1 or not city.receipts.has("ui-1001") or op_count != 1001:
		push_error("Reconstructed UI reused an old operation or failed to apply a fresh feed")
		get_tree().quit(1)
		return
	var after_fresh: Dictionary = city.snapshot()
	var retried: Dictionary = city.command("feed", "ray-1", "ui-1000", first_feed_revision)
	var conflicting: Dictionary = city.command("feed", "ray-2", "ui-1000", city.revision)
	if not retried["ok"] or not str(retried["message"]).begins_with("Already applied:") or conflicting["ok"] or city.snapshot() != after_fresh:
		push_error("Old receipt retry or conflicting payload changed the city")
		get_tree().quit(1)
		return
	print("CITY_UI_OPERATION_PASS: retained sparse receipt, reset UI counter, fresh same-payload feed, old retry and conflicting payload")
	# Isolated deterministic clock-offset regression after all ordinary-time
	# screenshots and input checks. No production time acceleration.
	set_process(false)
	city = Model.new()
	adapter = Adapter.new()
	op_count = 0
	last_ms = Time.get_ticks_msec()
	adapter.capture(city.snapshot())
	act("build", "light,3,0")
	var timer_revision: int = city.revision
	var timer_gold: int = city.gold
	var pending_snapshot: Dictionary = adapter.last_snapshot.duplicate(true)
	if city.construction.is_empty() or timer_revision != 1 or timer_gold != 1000 or pending_snapshot != city.snapshot():
		push_error("Timer capture fixture failed to start construction")
		get_tree().quit(1)
		return
	# A rejected action without a deadline should not capture or add a receipt.
	act("build", "light,3,0")
	if status_label.text != "Builder busy; wait or cancel." or city.revision != timer_revision or adapter.last_snapshot != pending_snapshot or city.receipts.size() != 1:
		push_error("Rejected pre-deadline action changed checkpoint or receipts")
		get_tree().quit(1)
		return
	act("cancel_build", "")
	if not city.construction.is_empty() or city.gold != 1160 or city.xp != 0 or city.revision != timer_revision + 1 or adapter.last_snapshot != city.snapshot():
		push_error("Successful early cancel did not capture the refund")
		get_tree().quit(1)
		return
	act("build", "light,3,0")
	timer_revision = city.revision
	timer_gold = city.gold
	var timer_receipts: int = city.receipts.size()
	if city.construction.is_empty() or timer_receipts != 3:
		push_error("Timer capture fixture failed to restart construction")
		get_tree().quit(1)
		return
	# The action reaches the deadline first; cancellation must now fail,
	# but completion and XP must still reach the in-memory checkpoint.
	last_ms = Time.get_ticks_msec() - 30000
	act("cancel_build", "")
	if status_label.text != "No construction to cancel." or not city.construction.is_empty() or city.revision != timer_revision + 1 or city.xp != 50 or city.gold != timer_gold or city.receipts.size() != timer_receipts or city.find_building("building-2").is_empty() or adapter.last_snapshot != city.snapshot():
		push_error("Rejected deadline action lost committed builder state")
		get_tree().quit(1)
		return
	var completed_snapshot: Dictionary = adapter.last_snapshot.duplicate(true)
	_process(0.0)
	if city.revision != timer_revision + 1 or city.xp != 50 or adapter.last_snapshot != completed_snapshot:
		push_error("Next frame repeated or lost builder completion")
		get_tree().quit(1)
		return
	print("CITY_TIMER_CAPTURE_PASS: rejected pre-deadline action, successful cancel refund, rejected post-deadline cancel captures one completion, next frame no duplicate")
	if not profile_view_fixture():
		push_error("Acknowledged profile view fixture failed")
		get_tree().quit(1)
		return
	print("CITY_PROFILE_VIEW_PASS: startup hidden until acknowledgement, restored operation ID, no speculative feed or overlap, retained pending elapsed, slow acknowledgement leaves a ready interval, uncertain save freezes confirmed view")
	get_tree().quit(0)

# CI-only interface double: actual city model, controlled acknowledgement.
# This verifies the view contract, not browser storage or the architect's port.
class ProfileViewFixture:
	extends RefCounted
	const FixtureModel = preload("res://city_model.gd")
	var phase: String = "opening"
	var visible: Dictionary = {}
	var pending: Dictionary = {}
	var result: Dictionary = {}
	var pending_result: Dictionary = {}
	var allow_ack: bool = false
	var command_count: int = 0
	var elapsed_sample: int = 0

	func status() -> String:
		return phase

	func snapshot() -> Dictionary:
		return visible.duplicate(true)

	func last_result() -> Dictionary:
		return result.duplicate(true)

	func poll(_wall_ms: int) -> bool:
		if not allow_ack:
			return false
		allow_ack = false
		if phase == "opening":
			phase = "saving"
			return true
		if phase != "saving":
			return false
		visible = pending.duplicate(true)
		result = pending_result.duplicate(true)
		phase = "ready"
		return true

	func stage_command(kind: String, argument: String, op_id: String, revision: int, elapsed_ms: int, _wall_ms: int) -> bool:
		if phase != "ready":
			return false
		var candidate = FixtureModel.new()
		if not candidate.restore_snapshot(visible):
			return false
		var prior: int = candidate.revision
		candidate.advance(elapsed_ms)
		pending_result = candidate.command(kind, argument, op_id, candidate.revision if revision == prior else revision)
		pending = candidate.snapshot()
		command_count += 1
		elapsed_sample = elapsed_ms
		phase = "saving"
		return true

	func stage_tick(elapsed_ms: int, _wall_ms: int) -> bool:
		if phase != "ready":
			return false
		var candidate = FixtureModel.new()
		if not candidate.restore_snapshot(visible):
			return false
		candidate.advance(elapsed_ms)
		pending = candidate.snapshot()
		pending_result = {"ok": true, "message": "City checkpoint saved."}
		elapsed_sample = elapsed_ms
		phase = "saving"
		return true

func profile_view_fixture() -> bool:
	var seed = Model.new()
	var seeded: Dictionary = seed.command("sample", "", "ui-1000", seed.revision)
	if not seeded["ok"]:
		return false
	var session := ProfileViewFixture.new()
	session.pending = seed.snapshot()
	session.pending_result = {"ok": true, "message": "City loaded."}
	var view = get_script().new()
	view.size = size
	if not view.configure_profile_session(session):
		view.free()
		return false
	add_child(view)
	view.set_process(false)
	var wall: int = int(Time.get_unix_time_from_system() * 1000.0)
	var now: int = Time.get_ticks_msec()
	var good: bool = view.profile_overlay.visible and not view.profile_confirmed
	view.act("feed", "ray-1")
	good = good and session.command_count == 0
	session.allow_ack = true
	view.process_profile(now, wall)
	good = good and session.phase == "saving" and view.profile_overlay.visible and not view.profile_confirmed
	session.allow_ack = true
	view.process_profile(now + 1, wall + 1)
	good = good and view.profile_confirmed and not view.profile_overlay.visible and view.city.snapshot() == seed.snapshot()
	var before: Dictionary = view.city.snapshot()
	var cost: int = view.city.feed_cost("ray-1")
	var food_before: int = view.city.food
	view.act("feed", "ray-1")
	var staged_at: int = view.last_ms
	good = good and session.phase == "saving" and view.city.snapshot() == before and view.profile_footer.text.begins_with("Saving")
	view.act("feed", "ray-1")
	good = good and session.command_count == 1 and view.city.snapshot() == before
	view.process_profile(staged_at + 500, wall + 500)
	good = good and view.last_ms == staged_at and view.city.snapshot() == before
	session.allow_ack = true
	view.process_profile(staged_at + 1100, wall + 1100)
	good = good and view.city.food == food_before - cost and view.city.receipts.has("ui-1001") and view.profile_footer.text.begins_with("Saved")
	var acknowledged: Dictionary = view.city.snapshot()
	# A slow acknowledgement must not trigger an immediate background write.
	view.process_profile(staged_at + 1100, wall + 1100)
	good = good and session.phase == "ready" and view.city.snapshot() == acknowledged
	view.process_profile(staged_at + 2099, wall + 2099)
	good = good and session.phase == "ready" and view.last_ms == staged_at and view.city.snapshot() == acknowledged
	view.process_profile(staged_at + 2100, wall + 2100)
	good = good and session.phase == "saving" and session.elapsed_sample == 2100 and view.city.snapshot() == acknowledged
	# An uncertain write must retain the old acknowledged model and prevent
	# additional commands. The standalone memory adapter must remain unused.
	session.phase = "unavailable"
	session.result = {"ok": false, "message": "Save unavailable. Reload to reconcile."}
	view.process_profile(staged_at + 2200, wall + 2200)
	view.act("feed", "ray-1")
	good = good and view.profile_overlay.visible and view.city.snapshot() == acknowledged and session.command_count == 1 and view.adapter.last_snapshot.is_empty()
	view.free()
	return good
