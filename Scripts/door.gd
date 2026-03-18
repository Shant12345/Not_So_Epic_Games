extends StaticBody2D

@export var is_open: bool = false
@export var requires_key: bool = true

var player_in_range: bool = false
var _player_ref: Node = null

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var door_visual: ColorRect = $ColorRect
@onready var interact_label: Label = $InteractLabel
@onready var safety_area: Area2D = $SafetyArea

func _ready() -> void:
	_update_door_state()
	if interact_label:
		interact_label.hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and player_in_range:
		if is_open:
			# Check if anyone is in the way before closing
			if safety_area.get_overlapping_bodies().is_empty():
				is_open = false
				_update_door_state()
			else:
				print("Door blocked!")
		else:
			# Check for key requirement
			if requires_key:
				if _player_has_key():
					_consume_key()
					is_open = true
					_update_door_state()
				else:
					# Flash the label to indicate the door is locked
					if interact_label:
						interact_label.text = "Need a Key!"
						interact_label.show()
						await get_tree().create_timer(1.5).timeout
						interact_label.text = "Press E to Open"
						if player_in_range:
							interact_label.show()
						else:
							interact_label.hide()
			else:
				is_open = true
				_update_door_state()
		get_viewport().set_input_as_handled()

func _update_door_state() -> void:
	if is_open:
		collision_shape.disabled = true
		door_visual.hide()
		if interact_label:
			interact_label.hide()
	else:
		collision_shape.disabled = false
		door_visual.show()

func _player_has_key() -> bool:
	if _player_ref == null:
		return false
	if "inventory" in _player_ref and _player_ref.inventory != null:
		return _player_ref.inventory.has_item("Key", 1)
	return false

func _consume_key() -> void:
	if _player_ref == null:
		return
	if "inventory" in _player_ref and _player_ref.inventory != null:
		_player_ref.inventory.remove_item("Key", 1)

func _on_interact_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") or body.name == "Player":
		player_in_range = true
		_player_ref = body
		if interact_label and not is_open:
			interact_label.text = "Press E to Open" if not requires_key or _player_has_key() else "Need a Key!"
			interact_label.show()

func _on_interact_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player") or body.name == "Player":
		player_in_range = false
		_player_ref = null
		if interact_label:
			interact_label.hide()
