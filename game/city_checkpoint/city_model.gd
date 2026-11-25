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
const BUILDINGS = [
	{"id": "tide-1", "kind": "Tide habitat", "x": 0, "y": 0, "size": 3},
	{"id": "hatchery-1", "kind": "Hatchery", "x": 3, "y": 3, "size": 2},
	{"id": "farm-1", "kind": "Farm", "x": 5, "y": 3, "size": 2}
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
var crop: Dictionary = {}
var receipts: Dictionary = {}

func advance(delta_ms: int) -> void:
	if delta_ms <= 0:
		return
	elapsed_ms += delta_ms
	# Fixed-point thousandths of a tick preserve production before a mid-second feed.
	var total: int = income_subticks + delta_ms * 2 * (level + 3)
	income_ticks = mini(SMALL_CAP * TICKS_PER_GOLD, income_ticks + floori(total / 1000.0))
	income_subticks = 0 if income_ticks == SMALL_CAP * TICKS_PER_GOLD else total % 1000

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

func remaining_seconds() -> int:
	if crop.is_empty():
		return 0
	return ceili(maxi(0, int(crop["deadline_ms"]) - elapsed_ms) / 1000.0)

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
			if not crop.is_empty() or not CROPS.has(argument):
				return {"ok": false, "message": "Choose an available crop in an empty farm."}
			var recipe: Dictionary = CROPS[argument]
			var cost: int = recipe["gold"]
			if gold < cost:
				return {"ok": false, "message": "Not enough Gold."}
			gold -= cost
			crop = {"recipe": argument, "deadline_ms": elapsed_ms + int(recipe["seconds"]) * 1000, "job_id": op_id}
			message = "−%d Gold · %s planted" % [cost, recipe["name"]]
		"harvest":
			if crop.is_empty() or remaining_seconds() > 0:
				return {"ok": false, "message": "Crop is not ready."}
			var recipe: Dictionary = CROPS[crop["recipe"]]
			food += int(recipe["food"])
			xp += int(recipe["xp"])
			message = "+%d Food · +%d account XP" % [recipe["food"], recipe["xp"]]
			crop = {}
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
		"buildings": BUILDINGS.duplicate(true), "income_ticks": income_ticks, "elapsed_ms": elapsed_ms,
		"income_subticks": income_subticks, "sample_claimed": sample_claimed, "crop": crop.duplicate(true), "receipts": receipts.duplicate(true)}
