extends Control

func _ready():
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Add hover effects to all buttons
	for btn in find_children("*", "Button", true):
		# Connect to lambda to set pivot after button has its actual size
		btn.ready.connect(func(): btn.pivot_offset = btn.size / 2)

func _on_start_button_pressed():
	if SceneTransition:
		SceneTransition.change_scene("res://tscn/dialogue_scene.tscn")
	else:
		get_tree().change_scene_to_file("res://tscn/dialogue_scene.tscn")

func _on_quit_button_pressed():
	get_tree().quit()
