extends Control

const State = preload("res://probe_state.gd")
const Store = preload("res://probe_store.gd")
const Ray = preload("res://blueberry.gd")
const TimerState = preload("res://probe_timer.gd")
const DIAGNOSTIC_MS := 10000
const CHECKPOINT_MS := 1000
var store = Store.new()
var state := State.fresh()
var pending: Dictionary = {}
var count_label: Label
var status_label: Label
var backup: TextEdit
var confirm: ConfirmationDialog
var sound: AudioStreamPlayer
var timer_label: Label
var start_button: Button
var claim_button: Button
var timer_base: Dictionary = {}
var timer_anchor_ms := 0
var next_checkpoint_ms := 0

func _ready() -> void:
	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(scroll)
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 12)
	scroll.add_child(box)
	_label(box, "Little Ray · delivery probe", 28)
	_label(box, "A disposable runtime test. One writer; this is not your game save.", 16)
	var ray := Ray.new()
	ray.custom_minimum_size = Vector2(320, 180)
	box.add_child(ray)
	count_label = _label(box, "", 24)
	_button(box, "Greet Blueberry", _greet)
	timer_label = _label(box, "", 20)
	start_button = _button(box, "Start 10-second diagnostic timer", _start_timer)
	claim_button = _button(box, "Claim diagnostic completion", _claim_timer)
	status_label = _label(box, "", 16)
	_button(box, "Export probe backup to text", func(): backup.text = JSON.stringify(state, "  "))
	backup = TextEdit.new()
	backup.custom_minimum_size.y = 180
	backup.placeholder_text = "Copy an exported backup somewhere safe, or paste one here to preview."
	box.add_child(backup)
	_button(box, "Preview backup import", _preview_import)
	var failure := CheckButton.new()
	failure.text = "Simulate save failure"
	failure.toggled.connect(func(on: bool):
		store.fail_writes = on
		status_label.text = "Save failure simulation on." if on else "Save failure simulation off.")
	box.add_child(failure)
	confirm = ConfirmationDialog.new()
	confirm.title = "Replace this probe save?"
	confirm.confirmed.connect(_restore_pending)
	add_child(confirm)
	_prepare_sample()
	var loaded: Dictionary = store.load_state()
	if loaded.ok:
		state = loaded.state
	status_label.text = loaded.reason
	# Hold the resume result separately until it can be committed. A failed
	# write must not discard elapsed time or move the committed UI forward.
	timer_anchor_ms = Time.get_ticks_msec()
	timer_base = TimerState.resume(state.timer, _wall_ms())
	next_checkpoint_ms = timer_anchor_ms + CHECKPOINT_MS
	_refresh()
	if timer_base != state.timer:
		_checkpoint(timer_anchor_ms)

func _greet() -> void:
	var tick := Time.get_ticks_msec()
	var candidate := state.duplicate(true)
	candidate.timer = _timer_at(tick)
	candidate.greetings = int(candidate.greetings) + 1
	if _commit(candidate, tick):
		sound.play() # Invoked only by a normal button gesture; never autoplay.

func _commit(candidate: Dictionary, tick: int) -> bool:
	var result: Dictionary = store.save(candidate, int(state.revision))
	status_label.text = result.reason
	if result.ok:
		state = result.state.duplicate(true)
		timer_base = state.timer.duplicate(true)
		timer_anchor_ms = tick
		next_checkpoint_ms = tick + CHECKPOINT_MS
		_refresh()
	return result.ok

func _wall_ms() -> int:
	return int(Time.get_unix_time_from_system() * 1000.0)

func _timer_at(tick: int) -> Dictionary:
	return TimerState.advance_active(timer_base, maxi(0, tick - timer_anchor_ms), _wall_ms())

func _process(_delta: float) -> void:
	if timer_base.is_empty() or state.timer.phase != "running":
		return
	var tick := Time.get_ticks_msec()
	if tick >= next_checkpoint_ms:
		_checkpoint(tick)

func _checkpoint(tick: int) -> void:
	next_checkpoint_ms = tick + CHECKPOINT_MS
	var candidate := state.duplicate(true)
	candidate.timer = _timer_at(tick)
	if candidate.timer != state.timer:
		_commit(candidate, tick)

func _start_timer() -> void:
	if state.timer.phase != "idle":
		return
	var tick := Time.get_ticks_msec()
	var candidate := state.duplicate(true)
	candidate.timer = TimerState.start(state.timer, DIAGNOSTIC_MS, _wall_ms())
	if candidate.timer != state.timer:
		_commit(candidate, tick)

func _claim_timer() -> void:
	if state.timer.phase != "ready":
		return
	var tick := Time.get_ticks_msec()
	var candidate := state.duplicate(true)
	candidate.timer = TimerState.claim(state.timer)
	_commit(candidate, tick)

func _restore_pending() -> void:
	if pending.is_empty():
		return
	var tick := Time.get_ticks_msec()
	var candidate := pending.duplicate(true)
	# Explicit replacement uses the imported clock, not the old profile anchor.
	candidate.timer = TimerState.resume(candidate.timer, _wall_ms())
	if _commit(candidate, tick):
		pending = {}

func _preview_import() -> void:
	var result: Dictionary = store.decode(backup.text)
	if not result.ok:
		status_label.text = result.reason
		return
	pending = result.state
	confirm.dialog_text = "Blueberry · schema 1\nReplace %s greetings with %s?\nImported timer: %s (%s ms saved).\nElapsed time is reconciled on restore. A previous copy is retained." % [state.greetings, pending.greetings, pending.timer.phase, pending.timer.remaining_ms]
	confirm.popup_centered(Vector2i(400, 240))

func _refresh() -> void:
	count_label.text = "Blueberry has heard %s greetings" % state.greetings
	var phase: String = state.timer.phase
	timer_label.text = "Saved diagnostic: %s · %s seconds remaining" % [phase, ceili(float(state.timer.remaining_ms) / 1000.0)]
	start_button.disabled = phase != "idle"
	claim_button.disabled = phase != "ready"

func _label(parent: Node, text: String, size_px: int) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", size_px)
	parent.add_child(label)
	return label

func _button(parent: Node, text: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 48
	button.pressed.connect(action)
	parent.add_child(button)
	return button

func _prepare_sample() -> void:
	# A short, fixed PCM test tone, prepared once; no live procedural audio stream.
	var data := PackedByteArray()
	for i in range(3308):
		var t := float(i) / 22050.0
		var pcm := int(3000.0 * sin(TAU * 660.0 * t) * (1.0 - float(i) / 3308.0))
		data.append(pcm & 255)
		data.append((pcm >> 8) & 255)
	var sample := AudioStreamWAV.new()
	sample.format = AudioStreamWAV.FORMAT_16_BITS
	sample.mix_rate = 22050
	sample.data = data
	sound = AudioStreamPlayer.new()
	sound.stream = sample
	add_child(sound)
