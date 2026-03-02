extends Control

func _ready():
	visible = false

func _input(event):
	if event.is_action_pressed("pause"):
		var is_paused = not get_tree().paused
		get_tree().paused = is_paused
		visible = is_paused
		# Prevent other input events from firing
		get_viewport().set_input_as_handled()

func _on_resume_pressed():
	get_tree().paused = false
	visible = false

func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://tscn/main_menu.tscn")
