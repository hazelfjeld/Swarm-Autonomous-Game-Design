extends Control

const State = preload("res://probe_state.gd")
const Store = preload("res://probe_store.gd")
const Ray = preload("res://blueberry.gd")
var store = Store.new()
var state := State.fresh()
var pending: Dictionary = {}
var count_label: Label
var status_label: Label
var backup: TextEdit
var confirm: ConfirmationDialog
var sound: AudioStreamPlayer

func _ready() -> void:
	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(scroll)
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 12)
	scroll.add_child(box)
	_label(box, "Little Ray · delivery probe", 28)
	_label(box, "A disposable runtime test. Use one tab; this is not your game save.", 16)
	var ray := Ray.new()
	ray.custom_minimum_size = Vector2(320, 180)
	box.add_child(ray)
	count_label = _label(box, "", 24)
	_button(box, "Greet Blueberry", _greet)
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
	confirm.confirmed.connect(func(): _commit(pending))
	add_child(confirm)
	_prepare_sample()
	var loaded: Dictionary = store.load_state()
	if loaded.ok:
		state = loaded.state
	status_label.text = loaded.reason
	_refresh()

func _greet() -> void:
	var candidate := state.duplicate(true)
	candidate.greetings = int(candidate.greetings) + 1
	if _commit(candidate):
		sound.play() # Invoked only by a normal button gesture; never autoplay.

func _commit(candidate: Dictionary) -> bool:
	var result: Dictionary = store.save(candidate)
	status_label.text = result.reason
	if result.ok:
		state = candidate.duplicate(true)
		_refresh()
	return result.ok

func _preview_import() -> void:
	var result: Dictionary = store.decode(backup.text)
	if not result.ok:
		status_label.text = result.reason
		return
	pending = result.state
	confirm.dialog_text = "Blueberry · schema 1\nReplace %s greetings with %s?\nA previous copy is retained." % [state.greetings, pending.greetings]
	confirm.popup_centered(Vector2i(360, 180))

func _refresh() -> void:
	count_label.text = "Blueberry has heard %s greetings" % state.greetings

func _label(parent: Node, text: String, size_px: int) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", size_px)
	parent.add_child(label)
	return label

func _button(parent: Node, text: String, action: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 48
	button.pressed.connect(action)
	parent.add_child(button)

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
