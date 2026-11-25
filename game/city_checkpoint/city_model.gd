extends RefCounted
## Isolated domain checkpoint, not the accepted production save schema.
## Time is an explicitly supplied monotonic delta; UI never awards resources.

const TICKS_PER_GOLD = 240
const SMALL_CAP = 500
const FEED_COSTS = [5, 8, 12, 17, 26, 38, 57, 86, 129]
const CROPS = {
	"sprout": {"name": "Sprout Kelp", "seconds": 60, "gold": 20, "food": 40, "xp": 5},
	"ribbon": {"name": "Ribbon Kelp", "seconds": 300, "gold": 100, "food": 180, "xp": 15}
}
const BUILD_TYPES = {
	"light": {"kind": "Light habitat", "size": 3, "gold": 200, "seconds": 30, "gate": 1},
	"tide": {"kind": "Tide habitat", "size": 3, "gold": 200, "seconds": 30, "gate": 1},
	"bloom": {"kind": "Bloom habitat", "size": 3, "gold": 200, "seconds": 30, "gate": 4},
	"grotto": {"kind": "Breeding grotto", "size": 3, "gold": 400, "seconds": 60, "gate": 2},
	"farm": {"kind": "Farm", "size": 2, "gold": 200, "seconds": 30, "gate": 3}
}
const BUILDINGS = [
	{"id": "tide-1", "type": "tide", "kind": "Tide habitat", "x": 0, "y": 0, "size": 3},
	{"id": "hatchery-1", "type": "hatchery", "kind": "Hatchery", "x": 3, "y": 3, "size": 2},
	{"id": "farm-1", "type": "farm", "kind": "Farm", "x": 5, "y": 3, "size": 2}
]
var gold: int = 1200
var food: int = 240
var xp: int = 0
var revision: int = 0
var level: int = 1
var pips: int = 0
var income_ticks: int = 0
var elapsed_ms: int = 0
var income_subticks: int = 0
var sample_claimed: bool = false
var nickname: String = "Blueberry"
var buildings: Array = BUILDINGS.duplicate(true)
var construction: Dictionary = {}
var next_building_serial: int = 1
var farm_crops: Dictionary = {}
# First-farm convenience accessor retained for the opening fixture.
var crop: Dictionary:
	get:
		return farm_crop("farm-1")
var receipts: Dictionary = {}

func advance(delta_ms: int) -> void:
	if delta_ms <= 0:
		return
	elapsed_ms += delta_ms
	# Fixed-point thousandths of a tick preserve production before a mid-second feed.
	var total: int = income_subticks + delta_ms * 2 * (level + 3)
	income_ticks = mini(SMALL_CAP * TICKS_PER_GOLD, income_ticks + floori(total / 1000.0))
	income_subticks = 0 if income_ticks == SMALL_CAP * TICKS_PER_GOLD else total % 1000
	if not construction.is_empty() and elapsed_ms >= int(construction["deadline_ms"]):
		xp += 50
		construction = {}
		revision += 1

func stored_gold() -> int:
	return floori(income_ticks / float(TICKS_PER_GOLD))

func feed_cost() -> int:
	if level >= 10:
		return 0
	return FEED_COSTS[level - 1]

func account_level() -> int:
	var result: int = 1
	while xp >= 50 * (result + 1) * result:
		result += 1
	return result

func find_building(id: String) -> Dictionary:
	for building in buildings:
		if building["id"] == id:
			return building
	return {}

func pending(id: String) -> bool:
	return not construction.is_empty() and construction["building_id"] == id

func construction_remaining() -> int:
	if construction.is_empty():
		return 0
	return ceili(maxi(0, int(construction["deadline_ms"]) - elapsed_ms) / 1000.0)

func count_type(kind: String) -> int:
	var count: int = 0
	for building in buildings:
		if building["type"] == kind:
			count += 1
	return count

func farm_ids() -> Array[String]:
	var ids: Array[String] = []
	for building in buildings:
		if building["type"] == "farm" and not pending(str(building["id"])):
			ids.append(str(building["id"]))
	return ids

func farm_crop(farm_id: String) -> Dictionary:
	return farm_crops.get(farm_id, {})

func remaining_seconds(farm_id: String = "farm-1") -> int:
	var job: Dictionary = farm_crop(farm_id)
	if job.is_empty():
		return 0
	return ceili(maxi(0, int(job["deadline_ms"]) - elapsed_ms) / 1000.0)

func can_place(x: int, y: int, footprint: int, ignore_id: String = "") -> bool:
	if footprint <= 0 or x < 0 or y < 0 or x + footprint > 8 or y + footprint > 8:
		return false
	for b in buildings:
		if b["id"] == ignore_id:
			continue
		var bx: int = b["x"]
		var by: int = b["y"]
		var bs: int = b["size"]
		if x < bx + bs and x + footprint > bx and y < by + bs and y + footprint > by:
			return false
	return true

func command(kind: String, argument: String, op_id: String, expected_revision: int) -> Dictionary:
	# Same operation id never applies twice; conflicting reuse is rejected.
	if op_id.is_empty():
		return {"ok": false, "message": "Missing operation ID."}
	if receipts.has(op_id):
		var previous: Dictionary = receipts[op_id]
		if previous["kind"] != kind or previous["argument"] != argument:
			return {"ok": false, "message": "Operation ID conflict."}
		return {"ok": true, "message": "Already applied: " + str(previous["message"])}
	if expected_revision != revision:
		return {"ok": false, "message": "Stale city revision. Retry from current state."}
	var message: String = ""
	match kind:
		"name":
			var clean: String = argument.strip_edges()
			if clean.is_empty() or clean.length() > 24:
				return {"ok": false, "message": "Choose a name of 1–24 characters."}
			nickname = clean
			message = "Named " + nickname + "."
		"sample":
			if sample_claimed:
				return {"ok": false, "message": "Tutorial sample already claimed."}
			sample_claimed = true
			gold += 10
			xp += 100
			message = "+10 tutorial Gold · +100 account XP"
		"collect":
			var amount: int = stored_gold()
			if amount <= 0:
				return {"ok": false, "message": "No whole Gold ready yet."}
			gold += amount
			income_ticks -= amount * TICKS_PER_GOLD
			message = "+%d resident Gold" % amount
		"plant":
			var parts: PackedStringArray = argument.split(":")
			if parts.size() > 2:
				return {"ok": false, "message": "Invalid crop selection."}
			var farm_id: String = "farm-1" if parts.size() == 1 else parts[0]
			var recipe_id: String = parts[parts.size() - 1]
			if not farm_ids().has(farm_id) or not farm_crop(farm_id).is_empty() or not CROPS.has(recipe_id):
				return {"ok": false, "message": "Choose an available crop in an empty completed farm."}
			var recipe: Dictionary = CROPS[recipe_id]
			var cost: int = recipe["gold"]
			if gold < cost:
				return {"ok": false, "message": "Not enough Gold."}
			gold -= cost
			farm_crops[farm_id] = {"recipe": recipe_id, "deadline_ms": elapsed_ms + int(recipe["seconds"]) * 1000, "job_id": op_id}
			message = "−%d Gold · %s planted" % [cost, recipe["name"]]
		"harvest":
			var farm_id: String = "farm-1" if argument.is_empty() else argument
			var job: Dictionary = farm_crop(farm_id)
			if not farm_ids().has(farm_id) or job.is_empty() or remaining_seconds(farm_id) > 0:
				return {"ok": false, "message": "Crop is not ready."}
			var recipe: Dictionary = CROPS[job["recipe"]]
			food += int(recipe["food"])
			xp += int(recipe["xp"])
			message = "+%d Food · +%d account XP" % [recipe["food"], recipe["xp"]]
			farm_crops.erase(farm_id)
		"build":
			var parts: PackedStringArray = argument.split(",")
			if parts.size() != 3 or not BUILD_TYPES.has(parts[0]) or not parts[1].is_valid_int() or not parts[2].is_valid_int():
				return {"ok": false, "message": "Invalid building or coordinates."}
			var spec: Dictionary = BUILD_TYPES[parts[0]]
			var x: int = int(parts[1])
			var y: int = int(parts[2])
			if not construction.is_empty():
				return {"ok": false, "message": "Builder busy; wait or cancel."}
			if account_level() < int(spec["gate"]):
				return {"ok": false, "message": "Unlock at account level %d." % int(spec["gate"])}
			if (parts[0] == "farm" and count_type("farm") >= 2) or (parts[0] == "grotto" and count_type("grotto") >= 1):
				return {"ok": false, "message": "Reached this slice's building limit."}
			if not can_place(x, y, int(spec["size"])):
				return {"ok": false, "message": "Footprint overlaps a building or locked land."}
			if gold < int(spec["gold"]):
				return {"ok": false, "message": "Not enough Gold."}
			var id: String = "building-%d" % next_building_serial
			next_building_serial += 1
			gold -= int(spec["gold"])
			buildings.append({"id": id, "type": parts[0], "kind": spec["kind"], "x": x, "y": y, "size": spec["size"]})
			construction = {"building_id": id, "deadline_ms": elapsed_ms + int(spec["seconds"]) * 1000, "cost": spec["gold"]}
			message = "−%d Gold · Building %s (%ds)" % [spec["gold"], spec["kind"], spec["seconds"]]
		"move":
			var parts: PackedStringArray = argument.split(",")
			if parts.size() != 3 or not parts[1].is_valid_int() or not parts[2].is_valid_int():
				return {"ok": false, "message": "Invalid move coordinates."}
			var building: Dictionary = find_building(parts[0])
			if building.is_empty() or pending(parts[0]):
				return {"ok": false, "message": "Choose a completed building."}
			var x: int = int(parts[1])
			var y: int = int(parts[2])
			if not can_place(x, y, int(building["size"]), parts[0]):
				return {"ok": false, "message": "Footprint overlaps a building or locked land."}
			building["x"] = x
			building["y"] = y
			message = "Moved %s · no Gold cost" % building["kind"]
		"cancel_build":
			if construction.is_empty():
				return {"ok": false, "message": "No construction to cancel."}
			var building: Dictionary = find_building(str(construction["building_id"]))
			var refund: int = floori(int(construction["cost"]) * 0.8)
			buildings.erase(building)
			gold += refund
			construction = {}
			message = "Construction canceled · +%d Gold refund" % refund
		"feed":
			var cost: int = feed_cost()
			if cost == 0 or food < cost:
				return {"ok": false, "message": "Level cap or insufficient Food."}
			food -= cost
			pips += 1
			if pips == 4:
				pips = 0
				level += 1
				message = "−%d Food · level %d! Gold rate increased." % [cost, level]
			else:
				message = "−%d Food · feed pip %d/4" % [cost, pips]
		_:
			return {"ok": false, "message": "Unknown command."}
	revision += 1
	receipts[op_id] = {"kind": kind, "argument": argument, "message": message}
	return {"ok": true, "message": message}

func snapshot() -> Dictionary:
	return {"checkpoint_schema": 1, "revision": revision, "gold": gold, "food": food, "xp": xp,
		"individual": {"id": "ray-1", "species": "blueberry", "elements": ["Tide"], "rarity": "Common", "nickname": nickname, "level": level, "pips": pips, "habitat_id": "tide-1"},
		"buildings": buildings.duplicate(true), "construction": construction.duplicate(true), "next_building_serial": next_building_serial, "farm_crops": farm_crops.duplicate(true), "income_ticks": income_ticks, "elapsed_ms": elapsed_ms,
		"income_subticks": income_subticks, "sample_claimed": sample_claimed, "crop": crop.duplicate(true), "receipts": receipts.duplicate(true)}
