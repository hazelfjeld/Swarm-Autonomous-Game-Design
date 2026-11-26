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
const SALE_VALUES = {"Common": 25, "Uncommon": 50, "Rare": 150}
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
	"acquisition_receipt": "starter", "equipped_skills": [], "runes": [], "favorite": false
}}
var discoveries: Dictionary = {"blueberry": true}
var next_ray_serial: int = 2
var habitat_bins: Dictionary = {"tide-1": {"ticks": 0, "subticks": 0}}
# Original Blueberry fixture accessors, no duplicate mutable state.
var level: int:
	get:
		return int(individuals.get("ray-1", {}).get("level", 0))
var pips: int:
	get:
		return int(individuals.get("ray-1", {}).get("pips", 0))
var nickname: String:
	get:
		return str(individuals.get("ray-1", {}).get("nickname", ""))
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
var stored_buildings: Array = []
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

# Quote the exact remaining pips at this level, never a later level.
func feed_level_cost(ray_id: String) -> int:
	var cost: int = feed_cost(ray_id)
	if cost == 0:
		return 0
	return cost * (4 - int(individuals[ray_id]["pips"]))

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
		"parents": [], "acquisition_receipt": receipt, "equipped_skills": [], "runes": [], "favorite": false}
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

func find_stored_building(id: String) -> Dictionary:
	for building in stored_buildings:
		if building["id"] == id:
			return building
	return {}

func storage_error(id: String) -> String:
	var building: Dictionary = find_building(id)
	if building.is_empty():
		return "Choose a placed building."
	if pending(id) or upgrading(id):
		return "Finish or cancel the builder job first."
	if HABITAT_ELEMENTS.has(building["type"]):
		if not resident_ids(id).is_empty():
			return "Move all residents before storing this habitat."
		if stored_gold(id) > 0:
			return "Collect the habitat's Gold before storing."
	if building["type"] == "farm" and not farm_crop(id).is_empty():
		return "Harvest the crop before storing its farm."
	if building["type"] == "hatchery" and not founder_egg.is_empty():
		return "Place the egg before storing the hatchery."
	# Grotto reservations and Temple caps are not implemented in this slice;
	# their owners must extend this guard when those systems are integrated.
	return ""

func sale_value(ray_id: String) -> int:
	if not individuals.has(ray_id):
		return 0
	return int(SALE_VALUES[ray_species(ray_id)["rarity"]])

func sale_error(ray_id: String) -> String:
	if not individuals.has(ray_id):
		return "Choose an owned ray."
	if bool(individuals[ray_id].get("favorite", false)):
		return "Unmark favorite before selling."
	# All slice residents have compatible active homes. Upgrading temporarily
	# pauses production, but the home remains active and will resume.
	for id in individuals:
		if id != ray_id and habitat_ids().has(str(individuals[id]["habitat_id"])):
			return ""
	return "Keep at least one housed Gold-producing ray."

func pending(id: String) -> bool:
	return not construction.is_empty() and construction["building_id"] == id and not upgrading(id)

func construction_remaining() -> int:
	if construction.is_empty():
		return 0
	return ceili(maxi(0, int(construction["deadline_ms"]) - elapsed_ms) / 1000.0)

func count_type(kind: String) -> int:
	var count: int = 0
	for building in buildings + stored_buildings:
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
			if not individuals.has("ray-1"):
				return {"ok": false, "message": "Starter no longer owned; choose a ray."}
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
		"set_favorite":
			var parts: PackedStringArray = argument.split(",")
			if parts.size() != 2 or not individuals.has(parts[0]) or not ["0", "1"].has(parts[1]):
				return {"ok": false, "message": "Choose an owned ray and favorite state."}
			individuals[parts[0]]["favorite"] = parts[1] == "1"
			message = "Favorite marked." if parts[1] == "1" else "Favorite unmarked."
		"sell_ray":
			# Caller shows an explicit confirmation for this stable ID; guard
			# again at commit. No level/feeding resale premium or XP reward.
			var error: String = sale_error(argument)
			if not error.is_empty():
				return {"ok": false, "message": error}
			var amount: int = sale_value(argument)
			var sold_name: String = str(individuals[argument]["nickname"])
			individuals.erase(argument)
			gold += amount
			message = "Sold %s · +%d Gold; discovery retained." % [sold_name, amount]
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
			if find_building("hatchery-1").is_empty():
				return {"ok": false, "message": "Restore the hatchery before buying an egg."}
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
		"store_building":
			var error: String = storage_error(argument)
			if not error.is_empty():
				return {"ok": false, "message": error}
			var building: Dictionary = find_building(argument)
			buildings.erase(building)
			stored_buildings.append(building)
			message = "Stored %s · no refund; restore for free." % building["kind"]
		"restore_building":
			var parts: PackedStringArray = argument.split(",")
			if parts.size() != 3 or not parts[1].is_valid_int() or not parts[2].is_valid_int():
				return {"ok": false, "message": "Invalid restore coordinates."}
			var building: Dictionary = find_stored_building(parts[0])
			if building.is_empty():
				return {"ok": false, "message": "Choose a stored building."}
			var x: int = int(parts[1])
			var y: int = int(parts[2])
			if not can_place(x, y, int(building["size"])):
				return {"ok": false, "message": "Restore footprint overlaps a building or locked land."}
			stored_buildings.erase(building)
			building["x"] = x
			building["y"] = y
			buildings.append(building)
			message = "Restored %s · no Gold or XP change." % building["kind"]
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
		"feed_level":
			var cost: int = feed_level_cost(argument)
			if cost <= 0 or food < cost:
				return {"ok": false, "message": "Unknown ray, level cap or insufficient Food for next level."}
			var ray: Dictionary = individuals[argument]
			# One debit, one level and one operation receipt; no partial spend.
			food -= cost
			ray["pips"] = 0
			ray["level"] += 1
			message = "−%d Food · %s level %d! Gold rate increased." % [cost, ray["nickname"], ray["level"]]
		_:
			return {"ok": false, "message": "Unknown command."}
	if _settle_trained_founders():
		message += " +300 trained-founder milestone XP."
	revision += 1
	receipts[op_id] = {"kind": kind, "argument": argument, "message": message}
	return {"ok": true, "message": message}

func snapshot() -> Dictionary:
	return {"checkpoint_schema": 2, "revision": revision, "gold": gold, "food": food, "xp": xp,
		"individual": individuals.get("ray-1", {}).duplicate(true), "individuals": individuals.duplicate(true),
		"discoveries": discoveries.duplicate(true), "next_ray_serial": next_ray_serial,
		"habitat_bins": habitat_bins.duplicate(true), "founder_egg": founder_egg.duplicate(true),
		"tutorial_sunbeam_started": tutorial_sunbeam_started, "founder_placed_milestone": founder_placed_milestone,
		"trained_founders_milestone": trained_founders_milestone,
		"buildings": buildings.duplicate(true), "stored_buildings": stored_buildings.duplicate(true), "construction": construction.duplicate(true),
		"owned_sectors": owned_sectors.duplicate(), "starter_obstacle": starter_obstacle.duplicate(true),
		"next_building_serial": next_building_serial, "farm_crops": farm_crops.duplicate(true),
		"income_ticks": income_ticks, "elapsed_ms": elapsed_ms, "income_subticks": income_subticks,
		"sample_claimed": sample_claimed, "crop": crop.duplicate(true), "receipts": receipts.duplicate(true)}

# Domain-only checkpoint codec for the existing isolated schema. Storage,
# wall-clock reconciliation and durable confirmation remain ARCH-002's job.
# JSON parses numbers as floats; normalize only safe whole numbers and never
# silently coerce strings, booleans, fractions or unknown schema fields.
const CHECKPOINT_MAX_INTEGER = 9007199254740991

static func _checkpoint_normalize(value: Variant, depth: int = 0) -> Variant:
	if depth > 12:
		return null
	if value is int or value is float:
		if not is_finite(float(value)) or value < 0 or value > CHECKPOINT_MAX_INTEGER or float(value) != floor(float(value)):
			return null
		return int(value)
	if value is String or value is bool:
		return value
	if value is Dictionary:
		var result: Dictionary = {}
		for key in value:
			if not key is String:
				return null
			var entry: Variant = _checkpoint_normalize(value[key], depth + 1)
			if entry == null:
				return null
			result[key] = entry
		return result
	if value is Array:
		var result: Array = []
		for item in value:
			var entry: Variant = _checkpoint_normalize(item, depth + 1)
			if entry == null:
				return null
			result.append(entry)
		return result
	return null

static func _checkpoint_fields(value: Variant, required: Array, optional: Array = []) -> bool:
	if not value is Dictionary:
		return false
	for key in required:
		if not value.has(key):
			return false
	for key in value:
		if not required.has(key) and not optional.has(key):
			return false
	return true

static func _checkpoint_int(value: Variant, minimum: int, maximum: int) -> bool:
	return value is int and value >= minimum and value <= maximum

static func _checkpoint_serial(value: Variant, prefix: String, next_serial: int) -> bool:
	if not value is String or not value.begins_with(prefix):
		return false
	var suffix: String = value.substr(prefix.length())
	return suffix.is_valid_int() and str(int(suffix)) == suffix and int(suffix) > 0 and int(suffix) < next_serial

static func _checkpoint_receipt(ledger: Dictionary, id: Variant, kind: String, argument: String) -> bool:
	return id is String and ledger.has(id) and ledger[id]["kind"] == kind and ledger[id]["argument"] == argument

# Returns an empty dictionary for malformed/unsupported input, otherwise a
# detached normalized checkpoint. Does not run timers or change live state.
static func _validated_checkpoint(raw: Variant) -> Dictionary:
	var normalized: Variant = _checkpoint_normalize(raw)
	if not _checkpoint_fields(normalized, ["checkpoint_schema", "revision", "gold", "food", "xp", "individual", "individuals", "discoveries", "next_ray_serial", "habitat_bins", "founder_egg", "tutorial_sunbeam_started", "founder_placed_milestone", "trained_founders_milestone", "buildings", "stored_buildings", "construction", "owned_sectors", "starter_obstacle", "next_building_serial", "farm_crops", "income_ticks", "elapsed_ms", "income_subticks", "sample_claimed", "crop", "receipts"]):
		return {}
	var s: Dictionary = normalized
	if s.checkpoint_schema != 2 or not s.checkpoint_schema is int:
		return {}
	for key in ["gold", "food", "xp", "revision", "elapsed_ms", "income_ticks", "income_subticks"]:
		if not _checkpoint_int(s[key], 0, CHECKPOINT_MAX_INTEGER):
			return {}
	# Leave room for the next bounded elapsed-time settlement and deadlines.
	if s.elapsed_ms > CHECKPOINT_MAX_INTEGER - 604800000 or s.revision >= CHECKPOINT_MAX_INTEGER:
		return {}
	for key in ["next_ray_serial", "next_building_serial"]:
		if not _checkpoint_int(s[key], 1, CHECKPOINT_MAX_INTEGER - 1):
			return {}
	if s.next_ray_serial < 2:
		return {}
	for key in ["sample_claimed", "tutorial_sunbeam_started", "founder_placed_milestone", "trained_founders_milestone"]:
		if not s[key] is bool:
			return {}
	if (s.founder_placed_milestone and not s.tutorial_sunbeam_started) or (s.trained_founders_milestone and not s.founder_placed_milestone):
		return {}
	for key in ["individual", "individuals", "discoveries", "habitat_bins", "founder_egg", "construction", "starter_obstacle", "farm_crops", "crop", "receipts"]:
		if not s[key] is Dictionary:
			return {}
	for key in ["buildings", "stored_buildings", "owned_sectors"]:
		if not s[key] is Array:
			return {}
	# The first slice has exactly the four starter sectors and at most one
	# edge-adjacent sector, with a permanent corresponding obstacle record.
	var opening: Array = ["0,0", "1,0", "0,1", "1,1"]
	var adjacent: Array = ["2,0", "2,1", "0,2", "1,2"]
	if s.owned_sectors.size() < 4 or s.owned_sectors.size() > 5:
		return {}
	for sector in opening:
		if s.owned_sectors.count(sector) != 1:
			return {}
	var expansion: String = ""
	for sector in s.owned_sectors:
		if not sector is String or (not opening.has(sector) and not adjacent.has(sector)):
			return {}
		if adjacent.has(sector):
			expansion = sector
	if expansion.is_empty():
		if not s.starter_obstacle.is_empty():
			return {}
	else:
		var obstacle: Dictionary = s.starter_obstacle
		var coordinates: PackedStringArray = expansion.split(",")
		if not _checkpoint_fields(obstacle, ["id", "x", "y", "cleared"]) or obstacle.id != "starter-obstacle" or not obstacle.cleared is bool or not obstacle.x is int or not obstacle.y is int or obstacle.x != int(coordinates[0]) * 4 + 1 or obstacle.y != int(coordinates[1]) * 4 + 1:
			return {}
	var all_buildings: Dictionary = {}
	var active: Dictionary = {}
	var cells: Dictionary = {}
	var counts: Dictionary = {}
	for group in [s.buildings, s.stored_buildings]:
		var placed: bool = group == s.buildings
		for b in group:
			if not _checkpoint_fields(b, ["id", "type", "kind", "x", "y", "size"], ["tier"]):
				return {}
			if not b.id is String or not b.type is String or all_buildings.has(b.id):
				return {}
			var spec: Dictionary = BUILD_TYPES.get(b.type, {})
			if b.type == "hatchery":
				spec = {"kind": "Hatchery", "size": 2}
			if spec.is_empty() or b.kind != spec.kind or not b.size is int or b.size != spec.size:
				return {}
			if not _checkpoint_int(b.x, 0, ISLAND_SIZE - b.size) or not _checkpoint_int(b.y, 0, ISLAND_SIZE - b.size):
				return {}
			if b.has("tier") and (not HABITAT_ELEMENTS.has(b.type) or not _checkpoint_int(b.tier, 1, 2)):
				return {}
			if b.id in ["tide-1", "farm-1", "hatchery-1"]:
				if b.type != {"tide-1": "tide", "farm-1": "farm", "hatchery-1": "hatchery"}[b.id]:
					return {}
			elif not _checkpoint_serial(b.id, "building-", s.next_building_serial) or b.type == "hatchery":
				return {}
			all_buildings[b.id] = b
			counts[b.type] = int(counts.get(b.type, 0)) + 1
			if placed:
				active[b.id] = b
			for x in range(b.x, b.x + b.size):
				for y in range(b.y, b.y + b.size):
					var sector: String = "%d,%d" % [floori(x / 4.0), floori(y / 4.0)]
					if not s.owned_sectors.has(sector):
						return {}
					if placed:
						var cell := Vector2i(x, y)
						if cells.has(cell) or (not s.starter_obstacle.is_empty() and not s.starter_obstacle.cleared and x == s.starter_obstacle.x and y == s.starter_obstacle.y):
							return {}
						cells[cell] = true
	for starter in ["tide-1", "farm-1", "hatchery-1"]:
		if not all_buildings.has(starter):
			return {}
	if counts.get("farm", 0) > 2 or counts.get("grotto", 0) > 1:
		return {}
	var pending_id: String = ""
	var job: Dictionary = s.construction
	if not job.is_empty():
		if not _checkpoint_fields(job, ["building_id", "deadline_ms", "cost"], ["kind"]) or not job.building_id is String or not _checkpoint_int(job.deadline_ms, s.elapsed_ms + 1, s.elapsed_ms + LARGE_DURATION_MS) or not job.cost is int:
			return {}
		var kind: Variant = job.get("kind", "build")
		if kind == "clear":
			if job.building_id != "starter-obstacle" or s.starter_obstacle.is_empty() or s.starter_obstacle.cleared or job.cost != OBSTACLE_COST or job.deadline_ms > s.elapsed_ms + OBSTACLE_DURATION_MS:
				return {}
		elif kind == "upgrade":
			var b: Dictionary = active.get(job.building_id, {})
			if b.is_empty() or not HABITAT_ELEMENTS.has(b.type) or b.get("tier", 1) != 1 or job.cost != LARGE_COST:
				return {}
		elif kind == "build":
			var b: Dictionary = active.get(job.building_id, {})
			if b.is_empty() or not _checkpoint_serial(job.building_id, "building-", s.next_building_serial) or not BUILD_TYPES.has(b.type) or b.has("tier") or job.cost != BUILD_TYPES[b.type].gold or job.deadline_ms > s.elapsed_ms + BUILD_TYPES[b.type].seconds * 1000:
				return {}
			pending_id = job.building_id
		else:
			return {}
	# Every completed habitat (including storage) owns exactly one capped
	# fractional bin; pending buildings cannot own residents or production.
	var expected_bins: int = 0
	for id in all_buildings:
		var b: Dictionary = all_buildings[id]
		if not HABITAT_ELEMENTS.has(b.type) or id == pending_id:
			continue
		expected_bins += 1
		var bin: Variant = s.habitat_bins.get(id)
		var cap: int = (LARGE_CAP if b.get("tier", 1) == 2 else SMALL_CAP) * TICKS_PER_GOLD
		if not _checkpoint_fields(bin, ["ticks", "subticks"]) or not _checkpoint_int(bin.ticks, 0, cap) or not _checkpoint_int(bin.subticks, 0, 999):
			return {}
		if (bin.ticks == cap and bin.subticks != 0) or (not active.has(id) and bin.ticks >= TICKS_PER_GOLD):
			return {}
	if s.habitat_bins.size() != expected_bins:
		return {}
	var command_kinds: Array = ["name", "rename", "set_favorite", "sell_ray", "sample", "collect", "buy_founder", "place_founder", "move_ray", "plant", "harvest", "build", "buy_sector", "clear_obstacle", "upgrade_habitat", "move", "store_building", "restore_building", "cancel_build", "feed", "feed_level"]
	if s.receipts.size() > s.revision:
		return {}
	for id in s.receipts:
		var receipt: Variant = s.receipts[id]
		if id.is_empty() or not _checkpoint_fields(receipt, ["kind", "argument", "message"]) or not command_kinds.has(receipt.kind) or not receipt.argument is String or not receipt.message is String:
			return {}
	for species in s.discoveries:
		if not SPECIES.has(species) or not s.discoveries[species] is bool or not s.discoveries[species]:
			return {}
	if not s.discoveries.has("blueberry") or s.individuals.is_empty():
		return {}
	var resident_counts: Dictionary = {}
	var acquisition_ids: Dictionary = {}
	for id in s.individuals:
		var ray: Variant = s.individuals[id]
		if not _checkpoint_fields(ray, ["id", "species", "nickname", "level", "pips", "rank", "habitat_id", "parents", "acquisition_receipt", "equipped_skills", "runes", "favorite"]) or not _checkpoint_serial(id, "ray-", s.next_ray_serial) or ray.id != id or not ray.species is String or not SPECIES.has(ray.species) or not s.discoveries.has(ray.species):
			return {}
		if not ray.nickname is String or ray.nickname.strip_edges().is_empty() or ray.nickname.length() > 24 or not _checkpoint_int(ray.level, 1, 10) or not _checkpoint_int(ray.pips, 0, 3) or (ray.level == 10 and ray.pips != 0) or not _checkpoint_int(ray.rank, 0, 0) or not ray.favorite is bool:
			return {}
		# Breeding, skills and runes are not yet part of this isolated codec.
		for key in ["parents", "equipped_skills", "runes"]:
			if not ray[key] is Array or not ray[key].is_empty():
				return {}
		if not ray.habitat_id is String or not active.has(ray.habitat_id) or not s.habitat_bins.has(ray.habitat_id):
			return {}
		var home: Dictionary = active[ray.habitat_id]
		if not SPECIES[ray.species].elements.has(HABITAT_ELEMENTS[home.type]):
			return {}
		resident_counts[ray.habitat_id] = int(resident_counts.get(ray.habitat_id, 0)) + 1
		if resident_counts[ray.habitat_id] > (LARGE_CAPACITY if home.get("tier", 1) == 2 else SMALL_CAPACITY):
			return {}
		if not ray.acquisition_receipt is String:
			return {}
		if id == "ray-1":
			if ray.species != "blueberry" or ray.acquisition_receipt != "starter":
				return {}
		else:
			if not _checkpoint_receipt(s.receipts, ray.acquisition_receipt, "buy_founder", ray.species) or acquisition_ids.has(ray.acquisition_receipt):
				return {}
			acquisition_ids[ray.acquisition_receipt] = true
	var egg: Dictionary = s.founder_egg
	if not egg.is_empty():
		if not _checkpoint_fields(egg, ["species", "deadline_ms", "purchase_receipt", "tutorial"]) or not egg.species is String or not FOUNDER_GATES.has(egg.species) or not egg.tutorial is bool or not active.has("hatchery-1") or not _checkpoint_int(egg.deadline_ms, 1, s.elapsed_ms + 120000):
			return {}
		if not _checkpoint_receipt(s.receipts, egg.purchase_receipt, "buy_founder", egg.species) or acquisition_ids.has(egg.purchase_receipt) or (egg.tutorial and (egg.species != "sunbeam" or not s.tutorial_sunbeam_started or s.founder_placed_milestone)):
			return {}
	for id in s.farm_crops:
		var crop_job: Variant = s.farm_crops[id]
		if not active.has(id) or active[id].type != "farm" or id == pending_id or not _checkpoint_fields(crop_job, ["recipe", "deadline_ms", "job_id"]) or not crop_job.recipe is String or not CROPS.has(crop_job.recipe):
			return {}
		if not _checkpoint_int(crop_job.deadline_ms, 1, s.elapsed_ms + CROPS[crop_job.recipe].seconds * 1000) or not crop_job.job_id is String or not s.receipts.has(crop_job.job_id):
			return {}
		var receipt: Dictionary = s.receipts[crop_job.job_id]
		if receipt.kind != "plant" or (receipt.argument != id + ":" + crop_job.recipe and not (id == "farm-1" and receipt.argument == crop_job.recipe)):
			return {}
	# Legacy read-only aliases must agree rather than becoming a second truth.
	if s.individual != s.individuals.get("ray-1", {}) or s.crop != s.farm_crops.get("farm-1", {}) or s.income_ticks != s.habitat_bins["tide-1"].ticks or s.income_subticks != s.habitat_bins["tide-1"].subticks:
		return {}
	return s

# Callable seam for ARCH-002's candidate validator. No I/O or live mutation.
static func validate_snapshot(raw: Variant) -> bool:
	return not _validated_checkpoint(raw).is_empty()

# Explicit restore of a validated detached checkpoint. No partial application,
# no offline credit, no reward replay, no claim of durable storage.
func restore_snapshot(raw: Variant) -> bool:
	var s: Dictionary = _validated_checkpoint(raw)
	if s.is_empty():
		return false
	gold = s.gold
	food = s.food
	xp = s.xp
	revision = s.revision
	elapsed_ms = s.elapsed_ms
	individuals = s.individuals
	discoveries = s.discoveries
	next_ray_serial = s.next_ray_serial
	habitat_bins = s.habitat_bins
	founder_egg = s.founder_egg
	tutorial_sunbeam_started = s.tutorial_sunbeam_started
	founder_placed_milestone = s.founder_placed_milestone
	trained_founders_milestone = s.trained_founders_milestone
	buildings = s.buildings
	stored_buildings = s.stored_buildings
	construction = s.construction
	owned_sectors.assign(s.owned_sectors)
	starter_obstacle = s.starter_obstacle
	next_building_serial = s.next_building_serial
	farm_crops = s.farm_crops
	sample_claimed = s.sample_claimed
	receipts = s.receipts
	return true
