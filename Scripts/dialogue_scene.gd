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
		"text": "WOW! You're actually braver than I thought.",
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
@onready var antag_sprite   : Sprite2D       = $AntagonistSprite
@onready var yuming_sprite  : Sprite2D       = $YumingSprite
@onready var talk_tex       := preload("res://texture/KillercrushTalking.png")
@onready var idle_tex       := preload("res://texture/killercrushnottalking.png")
@onready var yuming_talk_tex := preload("res://texture/Yumingtalkinganimation-Sheet.png")


# ── state ────────────────────────────────────────────────────────────────────
var _current_line   := 0
var _typing         := false
var _full_text      := ""
var _tween          : Tween
var _is_talking     := false
var _anim_timer     := 0.0
var _current_frame  := 0
var _sprite_locked_position := Vector2.ZERO

# Yuming animation state
var _yuming_talking     := false
var _yuming_anim_timer  := 0.0
var _yuming_frame       := 0
var _yuming_locked_position := Vector2.ZERO

const ANIM_SPEED   := 0.1
const CHAR_DELAY   := 0.03   # seconds per character
const SLIDE_TIME   := 0.45   # panel slide duration

# ── lifecycle ────────────────────────────────────────────────────────────────
func _ready() -> void:
	bg_overlay.modulate.a  = 0.4
	continue_hint.modulate.a = 1.0
	
	antag_sprite.modulate.a = 1.0
	yuming_sprite.modulate.a = 1.0
	
	# Position dialogue box
	# Position dialogue box at the bottom, accounting for its scale
	var scaled_height = dialogue_box.size.y * dialogue_box.scale.y
	dialogue_box.position.y = get_viewport_rect().size.y - scaled_height - 20.0
	
	# Ensure antagonist sprite is visible on screen
	if antag_sprite.position.y > get_viewport_rect().size.y:
		antag_sprite.position.y = get_viewport_rect().size.y - 100.0
	
	# Ensure Yuming sprite is visible on screen
	if yuming_sprite.position.y > get_viewport_rect().size.y:
		yuming_sprite.position.y = get_viewport_rect().size.y - 100.0
	
	# Lock sprite positions so frame changes don't shift their perceived location
	antag_sprite.centered = true
	_sprite_locked_position = antag_sprite.position
	
	yuming_sprite.centered = true
	_yuming_locked_position = yuming_sprite.position
	
	_show_line(_current_line)

func _process(delta: float) -> void:
	# Killer Crush animation
	if _is_talking:
		_anim_timer += delta
		if _anim_timer >= ANIM_SPEED:
			_anim_timer = 0.0
			var frames = max(1, antag_sprite.hframes)
			_current_frame = (_current_frame + 1) % frames
			antag_sprite.frame = _current_frame
		antag_sprite.position = _sprite_locked_position
	else:
		antag_sprite.frame = 0
		antag_sprite.position = _sprite_locked_position
	
	# Yuming animation
	if _yuming_talking:
		_yuming_anim_timer += delta
		if _yuming_anim_timer >= ANIM_SPEED:
			_yuming_anim_timer = 0.0
			var yframes = max(1, yuming_sprite.hframes)
			_yuming_frame = (_yuming_frame + 1) % yframes
			yuming_sprite.frame = _yuming_frame
		yuming_sprite.position = _yuming_locked_position
	else:
		yuming_sprite.frame = 0
		yuming_sprite.position = _yuming_locked_position


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

	# Handle character textures and animation
	if data["speaker"] == "Killer Crush":
		# Killer Crush is talking — animate her, idle Yuming
		antag_sprite.texture = talk_tex
		antag_sprite.hframes = 3  # 3 frames in KillercrushTalking.png
		_current_frame = 0
		_is_talking = true
		
		yuming_sprite.texture = yuming_talk_tex
		yuming_sprite.hframes = 4
		_yuming_frame = 0
		_yuming_talking = false  # Yuming is idle while Killer Crush talks
	else:
		# Yuming is talking — animate him, idle Killer Crush
		antag_sprite.texture = idle_tex
		antag_sprite.hframes = 1
		_current_frame = 0
		_is_talking = false
		
		yuming_sprite.texture = yuming_talk_tex
		yuming_sprite.hframes = 4  # 4 frames in Yumingtalkinganimation-Sheet.png
		_yuming_frame = 0
		_yuming_talking = true  # Yuming is talking
	
	antag_sprite.visible = true
	yuming_sprite.visible = true

	# Type out text
	for i in _full_text.length():
		if not _typing:
			break
		text_label.text = _full_text.substr(0, i + 1)
		await get_tree().create_timer(CHAR_DELAY).timeout

	text_label.text = _full_text
	_typing = false
	_is_talking = false
	_yuming_talking = false
	continue_hint.modulate.a = 1.0

func _advance() -> void:
	if _typing:
		# Skip typing – show full text immediately
		_typing = false
		_is_talking = false
		_yuming_talking = false
		text_label.text = _full_text
		return

	_current_line += 1
	_show_line(_current_line)

func _finish() -> void:
	# Change scene immediately

	# Load level 1
	if SceneTransition:
		SceneTransition.change_scene("res://Levels/level_1.tscn")
	else:
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
