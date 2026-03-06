extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func change_scene(target_path: String) -> void:
	animation_player.play("fade_to_black")
	await animation_player.animation_finished
	get_tree().change_scene_to_file(target_path)
	animation_player.play("fade_from_black")
