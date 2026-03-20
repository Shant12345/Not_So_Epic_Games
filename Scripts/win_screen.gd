extends Control

func _ready():
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_main_menu_button_pressed():
	if SceneTransition:
		SceneTransition.change_scene("res://tscn/main_menu.tscn")
	else:
		get_tree().change_scene_to_file("res://tscn/main_menu.tscn")

func _on_quit_button_pressed():
	get_tree().quit()
