extends Area2D

@export var next_level_path: String = "res://Levels/level_2.tscn"

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") or body.name == "Player":
		SceneTransition.change_scene(next_level_path)
