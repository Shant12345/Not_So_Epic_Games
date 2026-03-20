extends Area2D

@export var next_level_path: String = ""

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") or body.name == "Player":
		var path_to_load = next_level_path
		if path_to_load == "":
			var current_scene = get_tree().current_scene.scene_file_path
			if current_scene.ends_with("level_1.tscn"):
				path_to_load = "res://Levels/level_2.tscn"
			elif current_scene.ends_with("level_2.tscn"):
				path_to_load = "res://Levels/level_3.tscn"
			elif current_scene.ends_with("level_3.tscn"):
				path_to_load = "res://tscn/win_screen.tscn"
		
		if path_to_load != "":
			SceneTransition.change_scene(path_to_load)
