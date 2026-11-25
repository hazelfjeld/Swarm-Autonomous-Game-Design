extends RefCounted
## Isolated domain checkpoint, not the accepted production save schema.
## Time is an explicitly supplied monotonic delta; UI never awards resources.

const TICKS_PER_GOLD = 240
const SMALL_CAP = 500
const SMALL_CAPACITY = 2
const LARGE_CAPACITY = 4
const LARGE_CAP = 5000
const LARGE_COST = 600
const LARGE_DURATION_MS = 300000
const LARGE_GATE = 5
const SECTOR_COST = 250
const OBSTACLE_COST = 50
const OBSTACLE_DURATION_MS = 60000
const ISLAND_SIZE = 16
# GDD v2 §§5–7,9: ordered elements and source-defined stat profiles.
const SPECIES = {
	"blueberry": {"name": "Blueberry", "elements": ["Tide"], "rarity": "Common", "role": "Attacker", "source": "Founder shop"},
	"sunbeam": {"name": "Sunbeam", "elements": ["Light"], "rarity": "Common", "role": "Attacker", "source": "Founder shop"},
	"mossdrop": {"name": "Mossdrop", "elements": ["Bloom"], "rarity": "Common", "role": "Tank", "source": "Founder shop"},
	"pearlcloud": {"name": "Pearlcloud", "elements": ["Tide", "Light"], "rarity": "Rare", "role": "Support", "source": "Tide × Light"},
	"kelpskip": {"name": "Kelpskip", "elements": ["Tide", "Bloom"], "rarity": "Uncommon", "role": "Support", "source": "Tide × Bloom"},
	"rosefin": {"name": "Rosefin", "elements": ["Bloom", "Light"], "rarity": "Rare", "role": "Support", "source": "Bloom × Light"}
}
const RARITIES = {
	"Common": {"factor_percent": 100, "gold": 2, "cap": 20},
	"Uncommon": {"factor_percent": 112, "gold": 3, "cap": 25},
	"Rare": {"factor_percent": 128, "gold": 5, "cap": 30}
}
const ROLES = {"Attacker": [100, 30, 24], "Tank": [150, 22, 16], "Support": [120, 24, 22]}
const FOUNDER_GATES = {"blueberry": 1, "sunbeam": 1, "mossdrop": 4}
const HABITAT_ELEMENTS = {"tide": "Tide", "light": "Light", "bloom": "Bloom"}
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
var individuals: Dictionary = {"ray-1": {
	"id": "ray-1", "species": "blueberry", "nickname": "Blueberry", "level": 1,
	"pips": 0, "rank": 0, "habitat_id": "tide-1", "parents": [],
	"acquisition_receipt": "starter", "equipped_skills": [], "runes": []
}}
var discoveries: Dictionary = {"blueberry": true}
var next_ray_serial: int = 2
var habitat_bins: Dictionary = {"tide-1": {"ticks": 0, "subticks": 0}}
# Original Blueberry fixture accessors, no duplicate mutable state.
var level: int:
	get:
		return int(individuals["ray-1"]["level"])
var pips: int:
	get:
		return int(individuals["ray-1"]["pips"])
var nickname: String:
	get:
		return str(individuals["ray-1"]["nickname"])
var income_ticks: int:
	get:
		return int(habitat_bins["tide-1"]["ticks"])
var income_subticks: int:
	get:
		return int(habitat_bins["tide-1"]["subticks"])
var elapsed_ms: int = 0
var sample_claimed: bool = false
# Provisional deterministic founder-only slot for the account progression seam.
# #23 owns random breeding, egg transfer and the integrated hatchery.
var founder_egg: Dictionary = {}
var tutorial_sunbeam_started: bool = false
var founder_placed_milestone: bool = false
var trained_founders_milestone: bool = false
var buildings: Array = BUILDINGS.duplicate(true)
# First-island slice: four opening sectors plus exactly one adjacent purchase.
var owned_sectors: Array[String] = ["0,0", "1,0", "0,1", "1,1"]
var starter_obstacle: Dictionary = {}
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
	var target_ms: int = elapsed_ms + delta_ms
	# Settle each side of the builder deadline separately. Upgrades pause only
	# the selected habitat, retain its bin, then resume at its new capacity.
	if not construction.is_empty() and int(construction["deadline_ms"]) <= target_ms:
		var deadline: int = maxi(elapsed_ms, int(construction["deadline_ms"]))
		_produce(deadline - elapsed_ms)
		elapsed_ms = deadline
		_finish_construction()
	_produce(target_ms - elapsed_ms)
	elapsed_ms = target_ms

func _produce(delta_ms: int) -> void:
	if delta_ms <= 0:
		return
	for habitat_id in habitat_ids():
		var bin: Dictionary = habitat_bins[habitat_id]
		var cap_ticks: int = habitat_gold_cap(habitat_id) * TICKS_PER_GOLD
		var total: int = int(bin["subticks"]) + delta_ms * habitat_rate_ticks(habitat_id)
		bin["ticks"] = mini(cap_ticks, int(bin["ticks"]) + floori(total / 1000.0))
		bin["subticks"] = 0 if int(bin["ticks"]) == cap_ticks else total % 1000

func _finish_construction() -> void:
	if construction.get("kind", "build") == "clear":
		starter_obstacle["cleared"] = true
		xp += 10
		construction = {}
		revision += 1
		return
	var built: Dictionary = find_building(str(construction["building_id"]))
	if construction.get("kind", "build") == "upgrade":
		built["tier"] = 2
		xp += 25
	else:
		if HABITAT_ELEMENTS.has(built["type"]):
			habitat_bins[built["id"]] = {"ticks": 0, "subticks": 0}
		xp += 50
	construction = {}
	_settle_trained_founders()
	revision += 1

func habitat_capacity(habitat_id: String) -> int:
	return LARGE_CAPACITY if int(find_building(habitat_id).get("tier", 1)) == 2 else SMALL_CAPACITY

func habitat_gold_cap(habitat_id: String) -> int:
	return LARGE_CAP if int(find_building(habitat_id).get("tier", 1)) == 2 else SMALL_CAP

func upgrading(id: String) -> bool:
	return not construction.is_empty() and construction["building_id"] == id and construction.get("kind", "build") == "upgrade"

func habitat_ids() -> Array[String]:
	var ids: Array[String] = []
	for building in buildings:
		if HABITAT_ELEMENTS.has(building["type"]) and not pending(str(building["id"])):
			ids.append(str(building["id"]))
	return ids

func resident_ids(habitat_id: String) -> Array[String]:
	var ids: Array[String] = []
	for id in individuals:
		if individuals[id]["habitat_id"] == habitat_id:
			ids.append(str(id))
	return ids

func ray_species(ray_id: String) -> Dictionary:
	if not individuals.has(ray_id):
		return {}
	return SPECIES[individuals[ray_id]["species"]]

func ray_rate_ticks(ray_id: String) -> int:
	var ray: Dictionary = individuals[ray_id]
	return int(RARITIES[ray_species(ray_id)["rarity"]]["gold"]) * (int(ray["level"]) + 3)

func habitat_rate_ticks(habitat_id: String) -> int:
	if upgrading(habitat_id):
		return 0
	var rate: int = 0
	for id in resident_ids(habitat_id):
		rate += ray_rate_ticks(id)
	return rate

func stored_gold(habitat_id: String = "tide-1") -> int:
	var bin: Dictionary = habitat_bins.get(habitat_id, {})
	return floori(int(bin.get("ticks", 0)) / float(TICKS_PER_GOLD))

func ray_stats(ray_id: String) -> Dictionary:
	var ray: Dictionary = individuals[ray_id]
	var species: Dictionary = ray_species(ray_id)
	var base: Array = ROLES[species["role"]]
	var factor: int = int(RARITIES[species["rarity"]]["factor_percent"])
	var growth: int = 100 + 12 * (int(ray["level"]) - 1)
	var rank_factor: int = 100 + 10 * int(ray["rank"])
	# Positive half-up from integer numerators; no intermediate stat rounding.
	return {"health": floori((int(base[0]) * factor * growth * rank_factor + 500000) / 1000000.0),
		"power": floori((int(base[1]) * factor * growth * rank_factor + 500000) / 1000000.0),
		"speed": floori((int(base[2]) * 10 + 4 * (int(ray["level"]) - 1) + int(ray["rank"]) * 10 + 5) / 10.0),
		"stamina": 100}

func feed_cost(ray_id: String = "ray-1") -> int:
	if not individuals.has(ray_id):
		return 0
	var current: int = int(individuals[ray_id]["level"])
	if current >= 10:
		return 0
	return FEED_COSTS[current - 1]

func housing_error(species_id: String, habitat_id: String) -> String:
	if not SPECIES.has(species_id):
		return "Unknown species."
	if not habitat_ids().has(habitat_id):
		return "Choose a completed elemental habitat."
	var building: Dictionary = find_building(habitat_id)
	if not SPECIES[species_id]["elements"].has(HABITAT_ELEMENTS[building["type"]]):
		return "Element mismatch: %s needs %s." % [SPECIES[species_id]["name"], " or ".join(PackedStringArray(SPECIES[species_id]["elements"]))]
	var capacity: int = habitat_capacity(habitat_id)
	if resident_ids(habitat_id).size() >= capacity:
		return "Habitat full (%d/%d). Upgrade, build another compatible habitat or move a resident." % [capacity, capacity]
	return ""

func founder_remaining() -> int:
	if founder_egg.is_empty():
		return 0
	return ceili(maxi(0, int(founder_egg["deadline_ms"]) - elapsed_ms) / 1000.0)

func _new_individual(species_id: String, habitat_id: String, receipt: String) -> String:
	# Internal placement seam; caller validates acquisition and housing.
	var id: String = "ray-%d" % next_ray_serial
	next_ray_serial += 1
	individuals[id] = {"id": id, "species": species_id, "nickname": SPECIES[species_id]["name"],
		"level": 1, "pips": 0, "rank": 0, "habitat_id": habitat_id,
		"parents": [], "acquisition_receipt": receipt, "equipped_skills": [], "runes": []}
	discoveries[species_id] = true
	return id

func _settle_trained_founders() -> bool:
	if trained_founders_milestone or not founder_placed_milestone:
		return false
	var blue_ready: bool = false
	var sun_ready: bool = false
	var grotto_ready: bool = false
	for ray in individuals.values():
		if int(ray["level"]) >= 4:
			blue_ready = blue_ready or ray["species"] == "blueberry"
			sun_ready = sun_ready or ray["species"] == "sunbeam"
	for building in buildings:
		if building["type"] == "grotto" and not pending(str(building["id"])):
			grotto_ready = true
	if blue_ready and sun_ready and grotto_ready:
		trained_founders_milestone = true
		xp += 300
		return true
	return false

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
	return not construction.is_empty() and construction["building_id"] == id and not upgrading(id)

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

func sector_key(sx: int, sy: int) -> String:
	return "%d,%d" % [sx, sy]

func owns_cell(x: int, y: int) -> bool:
	return x >= 0 and y >= 0 and x < ISLAND_SIZE and y < ISLAND_SIZE and owned_sectors.has(sector_key(floori(x / 4.0), floori(y / 4.0)))

func can_buy_sector(sx: int, sy: int) -> bool:
	if owned_sectors.size() >= 5 or sx < 0 or sy < 0 or sx >= 4 or sy >= 4 or owned_sectors.has(sector_key(sx, sy)):
		return false
	for d in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
		if owned_sectors.has(sector_key(sx + d.x, sy + d.y)):
			return true
	return false

func clearance_remaining() -> int:
	return construction_remaining() if construction.get("kind", "build") == "clear" else 0

func can_place(x: int, y: int, footprint: int, ignore_id: String = "") -> bool:
	if footprint <= 0 or x < 0 or y < 0 or x + footprint > ISLAND_SIZE or y + footprint > ISLAND_SIZE:
		return false
	for cx in range(x, x + footprint):
		for cy in range(y, y + footprint):
			if not owns_cell(cx, cy):
				return false
	if not starter_obstacle.is_empty() and not starter_obstacle["cleared"]:
		var ox: int = starter_obstacle["x"]
		var oy: int = starter_obstacle["y"]
		if x <= ox and x + footprint > ox and y <= oy and y + footprint > oy:
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
			individuals["ray-1"]["nickname"] = clean
			message = "Named " + clean + "."
		"rename":
			var parts: PackedStringArray = argument.split(":", true, 1)
			if parts.size() != 2 or not individuals.has(parts[0]):
				return {"ok": false, "message": "Choose an owned ray."}
			var clean: String = parts[1].strip_edges()
			if clean.is_empty() or clean.length() > 24:
				return {"ok": false, "message": "Choose a name of 1–24 characters."}
			individuals[parts[0]]["nickname"] = clean
			message = "Named " + clean + "."
		"sample":
			if sample_claimed:
				return {"ok": false, "message": "Tutorial sample already claimed."}
			sample_claimed = true
			gold += 10
			xp += 100
			message = "+10 tutorial Gold · +100 account XP"
		"collect":
			var habitat_id: String = "tide-1" if argument.is_empty() else argument
			if not habitat_ids().has(habitat_id):
				return {"ok": false, "message": "Choose a completed habitat."}
			var amount: int = stored_gold(habitat_id)
			if amount <= 0:
				return {"ok": false, "message": "No whole Gold ready yet."}
			gold += amount
			habitat_bins[habitat_id]["ticks"] -= amount * TICKS_PER_GOLD
			message = "+%d resident Gold" % amount
		"buy_founder":
			if not FOUNDER_GATES.has(argument):
				return {"ok": false, "message": "Only unlocked Common founder eggs are sold here."}
			if account_level() < int(FOUNDER_GATES[argument]):
				return {"ok": false, "message": "Founder unlocks at account level %d." % int(FOUNDER_GATES[argument])}
			if not founder_egg.is_empty():
				return {"ok": false, "message": "Hatchery occupied. Place the current egg first."}
			if gold < 100:
				return {"ok": false, "message": "Not enough Gold for the 100-Gold founder egg."}
			var guided: bool = argument == "sunbeam" and not tutorial_sunbeam_started
			var seconds: int = 30 if guided else 120
			gold -= 100
			tutorial_sunbeam_started = tutorial_sunbeam_started or guided
			founder_egg = {"species": argument, "deadline_ms": elapsed_ms + seconds * 1000,
				"purchase_receipt": op_id, "tutorial": guided}
			message = "−100 Gold · %s egg incubating (%ds)" % [SPECIES[argument]["name"], seconds]
		"place_founder":
			if founder_egg.is_empty() or founder_remaining() > 0:
				return {"ok": false, "message": "Founder egg is not ready to place."}
			var species_id: String = str(founder_egg["species"])
			var error: String = housing_error(species_id, argument)
			if not error.is_empty():
				return {"ok": false, "message": error}
			var id: String = _new_individual(species_id, argument, str(founder_egg["purchase_receipt"]))
			message = "%s hatched at Lv 1." % individuals[id]["nickname"]
			if bool(founder_egg["tutorial"]) and not founder_placed_milestone:
				founder_placed_milestone = true
				xp += 200
				message += " +200 founder milestone XP."
			founder_egg = {}
		"move_ray":
			var parts: PackedStringArray = argument.split(",")
			if parts.size() != 2 or not individuals.has(parts[0]):
				return {"ok": false, "message": "Choose an owned ray and target habitat."}
			var ray: Dictionary = individuals[parts[0]]
			if ray["habitat_id"] == parts[1]:
				return {"ok": false, "message": "Ray already lives there."}
			var error: String = housing_error(str(ray["species"]), parts[1])
			if not error.is_empty():
				return {"ok": false, "message": error}
			ray["habitat_id"] = parts[1]
			message = "%s moved · stored Gold stays in its original habitat." % ray["nickname"]
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
		"buy_sector":
			var parts: PackedStringArray = argument.split(",")
			if parts.size() != 2 or not parts[0].is_valid_int() or not parts[1].is_valid_int():
				return {"ok": false, "message": "Choose a valid adjacent sector."}
			var sx: int = int(parts[0])
			var sy: int = int(parts[1])
			if not can_buy_sector(sx, sy):
				return {"ok": false, "message": "Land must share an edge; this slice allows one purchase."}
			if gold < SECTOR_COST:
				return {"ok": false, "message": "First sector costs 250 Gold."}
			gold -= SECTOR_COST
			owned_sectors.append(sector_key(sx, sy))
			# Provisional one-cell obstacle footprint inside the purchased sector.
			starter_obstacle = {"id": "starter-obstacle", "x": sx * 4 + 1, "y": sy * 4 + 1, "cleared": false}
			message = "−250 Gold · Sector purchased permanently. Clear its obstacle for 50 Gold."
		"clear_obstacle":
			if argument != "starter-obstacle" or starter_obstacle.is_empty() or starter_obstacle["cleared"]:
				return {"ok": false, "message": "No uncleared starter obstacle."}
			if not construction.is_empty():
				return {"ok": false, "message": "Builder busy; wait or cancel."}
			if gold < OBSTACLE_COST:
				return {"ok": false, "message": "Obstacle clearance costs 50 Gold."}
			gold -= OBSTACLE_COST
			construction = {"kind": "clear", "building_id": "starter-obstacle", "deadline_ms": elapsed_ms + OBSTACLE_DURATION_MS, "cost": OBSTACLE_COST}
			message = "−50 Gold · Clearing obstacle (60s)."
		"upgrade_habitat":
			if not habitat_ids().has(argument):
				return {"ok": false, "message": "Choose a completed elemental habitat."}
			if not construction.is_empty():
				return {"ok": false, "message": "Builder busy; wait or cancel."}
			if habitat_capacity(argument) != SMALL_CAPACITY:
				return {"ok": false, "message": "Large is the maximum tier in this slice."}
			if account_level() < LARGE_GATE:
				return {"ok": false, "message": "Large habitat unlocks at account level 5."}
			if gold < LARGE_COST:
				return {"ok": false, "message": "Large habitat costs 600 Gold."}
			gold -= LARGE_COST
			construction = {"kind": "upgrade", "building_id": argument, "deadline_ms": elapsed_ms + LARGE_DURATION_MS, "cost": LARGE_COST}
			message = "−600 Gold · Large upgrade (5m); income paused, collection available."
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
			if construction.get("kind", "build") == "build":
				buildings.erase(building)
			gold += refund
			construction = {}
			message = "Builder job canceled · +%d Gold refund" % refund
		"feed":
			var ray_id: String = "ray-1" if argument.is_empty() else argument
			var cost: int = feed_cost(ray_id)
			if cost == 0 or food < cost:
				return {"ok": false, "message": "Unknown ray, level cap or insufficient Food."}
			var ray: Dictionary = individuals[ray_id]
			food -= cost
			ray["pips"] += 1
			if int(ray["pips"]) == 4:
				ray["pips"] = 0
				ray["level"] += 1
				message = "−%d Food · %s level %d! Gold rate increased." % [cost, ray["nickname"], ray["level"]]
			else:
				message = "−%d Food · feed pip %d/4" % [cost, ray["pips"]]
		_:
			return {"ok": false, "message": "Unknown command."}
	if _settle_trained_founders():
		message += " +300 trained-founder milestone XP."
	revision += 1
	receipts[op_id] = {"kind": kind, "argument": argument, "message": message}
	return {"ok": true, "message": message}

func snapshot() -> Dictionary:
	return {"checkpoint_schema": 2, "revision": revision, "gold": gold, "food": food, "xp": xp,
		"individual": individuals["ray-1"].duplicate(true), "individuals": individuals.duplicate(true),
		"discoveries": discoveries.duplicate(true), "next_ray_serial": next_ray_serial,
		"habitat_bins": habitat_bins.duplicate(true), "founder_egg": founder_egg.duplicate(true),
		"tutorial_sunbeam_started": tutorial_sunbeam_started, "founder_placed_milestone": founder_placed_milestone,
		"trained_founders_milestone": trained_founders_milestone,
		"buildings": buildings.duplicate(true), "construction": construction.duplicate(true),
		"owned_sectors": owned_sectors.duplicate(), "starter_obstacle": starter_obstacle.duplicate(true),
		"next_building_serial": next_building_serial, "farm_crops": farm_crops.duplicate(true),
		"income_ticks": income_ticks, "elapsed_ms": elapsed_ms, "income_subticks": income_subticks,
		"sample_claimed": sample_claimed, "crop": crop.duplicate(true), "receipts": receipts.duplicate(true)}
