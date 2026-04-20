extends Control

# ── dialogue data ────────────────────────────────────────────────────────────
const LINES := [
	{
		"speaker": "Killer Crush",
		"text": "H-hey... I've been meaning to tell you something for a while now.",
		"color": Color(0.877, 0.0, 0.602, 1.0)
	},
	{
		"speaker": "Killer Crush",
		"text": "I really, really like you. Like... a lot. Will you go out with me?",
		"color": Color(0.877, 0.0, 0.602, 1.0)
	},
	{
		"speaker": "Yuming",
		"text": "Oh. Uh...",
		"color": Color(0.0, 0.532, 0.743, 1.0)
	},
	{
		"speaker": "Yuming",
		"text": "Yeah, no. Hard pass. You're kind of... a lot.",
		"color": Color(0.0, 0.532, 0.743, 1.0)
	},
	{
		"speaker": "Yuming",
		"text": "Also I'm seeing someone. And even if I wasn't, I wouldn't.",
		"color": Color(0.0, 0.532, 0.743, 1.0)
	},
	{
		"speaker": "Killer Crush",
		"text": "WOW! You're actually braver then I thought.",
		"color": Color(0.877, 0.0, 0.602, 1.0)
	},
	{
		"speaker": "Killer Crush",
		"text": "You- you just said that like it was NOTHING.",
		"color": Color(0.877, 0.0, 0.602, 1.0)
	},
	{
		"speaker": "Killer Crush",
		"text": "After everything I did for you. After every single lunch. Every note. Every smile.",
		"color": Color(0.877, 0.0, 0.602, 1.0)
	},
	{
		"speaker": "Yuming",
		"text": "Okay, this is getting weird. I'm gonna go.",
		"color": Color(0.0, 0.532, 0.743, 1.0)
	},
	{
		"speaker": "Killer Crush",
		"text": "...",
		"color": Color(0.877, 0.0, 0.602, 1.0)
	},
	{
		"speaker": "Killer Crush",
		"text": "Fine.",
		"color": Color(0.877, 0.0, 0.602, 1.0)
	},
	{
		"speaker": "Killer Crush",
		"text": "If I can't have him...",
		"color": Color(0.877, 0.0, 0.602, 1.0)
	},
	{
		"speaker": "Killer Crush",
		"text": "Then NO ONE will.",
		"color": Color(0.877, 0.0, 0.602, 1.0)
	},
]

# ── node refs ────────────────────────────────────────────────────────────────
@onready var dialogue_box   : PanelContainer = $DialogueBox
@onready var speaker_label  : Label          = $DialogueBox/VBox/SpeakerName
@onready var text_label     : Label          = $DialogueBox/VBox/DialogueText
@onready var continue_hint  : Label          = $DialogueBox/VBox/ContinueHint
@onready var bg_overlay     : ColorRect      = $BgOverlay
@onready var skip_btn       : Button         = $SkipButton

# ── state ────────────────────────────────────────────────────────────────────
var _current_line   := 0
var _typing         := false
var _full_text      := ""
var _tween          : Tween

const CHAR_DELAY   := 0.03   # seconds per character
const SLIDE_TIME   := 0.45   # panel slide duration

# ── lifecycle ────────────────────────────────────────────────────────────────
func _ready() -> void:
	# Start box off-screen below
	dialogue_box.position.y = get_viewport_rect().size.y + 100
	bg_overlay.modulate.a  = 0.0
	continue_hint.modulate.a = 0.0

	await get_tree().create_timer(0.3).timeout
	_slide_in()

func _slide_in() -> void:
	var target_y := get_viewport_rect().size.y - dialogue_box.size.y - 40.0
	_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	_tween.tween_property(bg_overlay,     "modulate:a",   0.65, SLIDE_TIME)
	_tween.parallel().tween_property(dialogue_box, "position:y", target_y, SLIDE_TIME)
	await _tween.finished
	_show_line(_current_line)

func _show_line(idx: int) -> void:
	if idx >= LINES.size():
		_finish()
		return

	var data : Dictionary = LINES[idx]
	_full_text   = data["text"]
	_typing      = true
	continue_hint.modulate.a = 0.0

	speaker_label.text       = data["speaker"]
	speaker_label.modulate   = data["color"]
	text_label.text          = ""

	# Bounce the panel slightly
	var base_y := dialogue_box.position.y
	var bounce := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	bounce.tween_property(dialogue_box, "position:y", base_y - 8, 0.12)
	bounce.tween_property(dialogue_box, "position:y", base_y, 0.12)

	# Type out text
	for i in _full_text.length():
		if not _typing:
			break
		text_label.text = _full_text.substr(0, i + 1)
		await get_tree().create_timer(CHAR_DELAY).timeout

	text_label.text = _full_text
	_typing = false
	_flash_hint()

func _flash_hint() -> void:
	var t := create_tween().set_loops()
	t.tween_property(continue_hint, "modulate:a", 1.0, 0.4)
	t.tween_property(continue_hint, "modulate:a", 0.0, 0.4)

func _advance() -> void:
	if _typing:
		# Skip typing – show full text immediately
		_typing = false
		text_label.text = _full_text
		return

	_current_line += 1
	_show_line(_current_line)

func _finish() -> void:
	# Slide out
	var t := create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	t.tween_property(dialogue_box, "position:y", get_viewport_rect().size.y + 100, SLIDE_TIME)
	t.parallel().tween_property(bg_overlay,    "modulate:a", 0.0, SLIDE_TIME)
	await t.finished

	# Load level 1
	get_tree().change_scene_to_file("res://Levels/level_1.tscn")

# ── input ────────────────────────────────────────────────────────────────────
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_advance()
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode in [KEY_SPACE, KEY_ENTER, KEY_Z]:
			_advance()

func _on_skip_button_pressed() -> void:
	_finish()
