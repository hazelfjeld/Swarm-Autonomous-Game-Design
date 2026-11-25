extends SceneTree

const Model = preload("res://city_model.gd")
const Adapter = preload("res://checkpoint_adapter.gd")
var failures: int = 0
var checks: int = 0
func check(condition: bool, name: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("FAIL: " + name)
	else:
		print("PASS: " + name)
func _initialize() -> void:
	var m = Model.new()
	check(m.gold == 1200 and m.food == 240 and m.level == 1 and m.xp == 0, "opening ledger")
	var occupied: Dictionary = {}
	var good: bool = true
	for b in Model.BUILDINGS:
		for x in range(b.x,b.x+b.size):
			for y in range(b.y,b.y+b.size):
				var cell := Vector2i(x,y)
				if x >= 8 or y >= 8 or occupied.has(cell):
					good = false
				occupied[cell] = true
	check(good and occupied.size() == 17, "starter footprints")
	m.advance(29999)
	check(m.stored_gold() == 0, "fractional income retained")
	m.advance(1)
	check(m.stored_gold() == 1, "30 seconds produces one Gold")
	check(m.command("collect","","collect-1",0).ok and m.gold == 1201, "collect earned Gold")
	check(m.command("collect","","collect-1",0).ok and m.gold == 1201, "duplicate operation no payout")
	check(not m.command("feed","","collect-1",1).ok, "conflicting operation ID")
	check(not m.command("plant","sprout","stale",0).ok and m.crop.is_empty(), "stale revision rejected")
	check(m.command("sample","","sample",1).ok and m.xp == 100 and m.gold == 1211, "sample receipt separate from production")
	check(not m.command("sample","","sample-again",2).ok, "sample not repeated")
	check(m.command("plant","sprout","plant",2).ok and m.gold == 1191, "paid planting")
	check(not m.command("plant","ribbon","busy",3).ok and m.gold == 1191, "occupied farm no debit")
	check(not m.command("harvest","","early",3).ok, "early harvest refused")
	m.advance(59999)
	check(not m.command("harvest","","still-early",3).ok, "deadline boundary")
	m.advance(1)
	check(m.command("harvest","","harvest",3).ok and m.food == 280 and m.xp == 105, "harvest exact output")
	check(not m.command("harvest","","repeat",4).ok and m.food == 280, "repeat harvest refused")
	for n in range(12):
		check(m.command("feed","","feed-%d"%n,m.revision).ok,"feed pip %d"%n)
	check(m.level == 4 and m.pips == 0 and m.food == 180, "level four costs exactly 100 Food")
	var old_ticks: int = m.income_ticks
	m.advance(60000)
	check(m.income_ticks-old_ticks == 840, "level four resident rate")
	m.advance(7*86400000)
	check(m.stored_gold() == 500, "storage cap")
	var old_time: int = m.elapsed_ms
	m.advance(-1000)
	check(m.elapsed_ms == old_time, "negative delta ignored")
	check(m.command("plant","ribbon","ribbon",m.revision).ok, "five-minute crop")
	m.advance(300000)
	check(m.command("harvest","","ribbon-harvest",m.revision).ok and m.food == 360 and m.xp == 120, "ribbon yields 180 Food and 15 XP")
	var fractional = Model.new()
	fractional.advance(500)
	for n in range(4):
		fractional.command("feed", "", "fractional-%d" % n, fractional.revision)
	fractional.advance(500)
	check(fractional.income_ticks == 9 and fractional.income_subticks == 0, "rate change midway through second preserves old and new contribution")
	var a = Adapter.new()
	a.capture(m.snapshot())
	m.command("feed","","extra",m.revision)
	check(a.last_snapshot["individual"]["pips"] == 0, "adapter copies committed state")
	var town = Model.new()
	check(not town.command("build","grotto,0,3","locked",town.revision).ok and town.gold == 1200, "grotto account gate")
	check(not town.command("build","light,0,0","overlap",town.revision).ok and town.gold == 1200, "overlap rejection before debit")
	check(not town.command("build","light,7,7","bounds",town.revision).ok, "locked land rejected")
	check(town.command("build","light,3,0","light",town.revision).ok and town.gold == 1000, "paid Light habitat")
	check(not town.command("build","tide,0,3","busy-builder",town.revision).ok and town.gold == 1000, "single builder")
	check(not town.command("move","building-1,0,3","pending-move",town.revision).ok, "pending construction cannot move")
	town.advance(29999)
	check(town.xp == 0 and town.pending("building-1"), "construction does not complete early")
	town.advance(1)
	check(town.xp == 50 and town.construction.is_empty(), "construction auto-completes and awards XP once")
	town.advance(30000)
	check(town.xp == 50 and town.income_ticks == 480, "empty habitats do not produce")
	check(town.command("move","building-1,0,3","move-light",town.revision).ok and town.gold == 1000 and town.xp == 50, "free move preserves XP and ID")
	check(town.find_building("building-1")["x"] == 0 and town.find_building("building-1")["y"] == 3, "move commits coordinates")
	check(town.command("move","building-1,3,0","move-back",town.revision).ok, "return Light to opening fixture")
	check(town.command("build","tide,0,3","cancel-start",town.revision).ok, "start cancelable build")
	check(town.command("cancel_build","","cancel",town.revision).ok and town.gold == 960 and town.xp == 50, "80 percent refund without XP")
	check(not town.command("cancel_build","","cancel-again",town.revision).ok, "cannot repeat cancellation")
	check(not town.command("build","farm,3,5","farm-locked",town.revision).ok, "second farm requires account level three")
	# Test-only account XP fixture; onboarding milestone remains unimplemented.
	town.xp = 300
	check(town.command("build","grotto,0,3","grotto",town.revision).ok, "place grotto at GDD fixture")
	town.advance(60000)
	check(town.command("build","farm,3,5","farm-two",town.revision).ok and town.farm_ids().size() == 1, "second farm unavailable during construction")
	town.advance(30000)
	check(town.buildings.size() == 6 and town.farm_ids().size() == 2, "all six opening buildings fit")
	var farm_two: String = town.farm_ids()[1]
	check(town.command("plant","farm-1:sprout","plot-a",town.revision).ok, "plant first farm")
	check(town.command("plant",farm_two+":ribbon","plot-b",town.revision).ok, "plant independent second farm")
	check(town.command("move","farm-1,5,5","move-crop",town.revision).ok and town.farm_crop("farm-1")["job_id"] == "plot-a", "moving farm preserves active job")
	town.advance(60000)
	check(town.command("harvest","farm-1","plot-a-harvest",town.revision).ok and not town.farm_crop(farm_two).is_empty(), "harvest frees only selected farm")
	check(not town.command("harvest",farm_two,"early-b",town.revision).ok, "other crop retains deadline")
	town.advance(240000)
	check(town.command("harvest",farm_two,"plot-b-harvest",town.revision).ok and town.food == 460, "independent exact crop rewards")
	check(not town.command("harvest",farm_two,"repeat-b",town.revision).ok, "second harvest cannot repeat")
	print("CITY_MODEL_CHECKS: %d / %d passed" % [checks-failures,checks])
	quit(0 if failures == 0 else 1)
