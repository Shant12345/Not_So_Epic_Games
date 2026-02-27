extends StaticBody2D

@export var is_open: bool = false
var player_in_range: bool = false

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var door_visual: ColorRect = $ColorRect
@onready var interact_label: Label = $InteractLabel
@onready var safety_area: Area2D = $SafetyArea

func _ready() -> void:
    # Ensure initial state is correct
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
                # Optional: Add feedback that door is blocked
                print("Door blocked!")
        else:
            is_open = true
            _update_door_state()
        get_viewport().set_input_as_handled()

func _update_door_state() -> void:
    if is_open:
        collision_shape.disabled = true
        door_visual.hide()
    else:
        collision_shape.disabled = false
        door_visual.show()

func _on_interact_area_body_entered(body: Node2D) -> void:
    if body.is_in_group("Player") or body.name == "Player":
        player_in_range = true
        if interact_label:
            interact_label.show()

func _on_interact_area_body_exited(body: Node2D) -> void:
    if body.is_in_group("Player") or body.name == "Player":
        player_in_range = false
        if interact_label:
            interact_label.hide()
