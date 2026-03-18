extends Control

func _ready():
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Add hover effects to all buttons
	for btn in find_children("*", "Button", true):
		# Connect to lambda to set pivot after button has its actual size
		btn.ready.connect(func(): btn.pivot_offset = btn.size / 2)
		btn.mouse_entered.connect(_on_button_hover.bind(btn))
		btn.mouse_exited.connect(_on_button_unhover.bind(btn))

func _on_button_hover(btn: Button):
	var tween = create_tween()
	tween.tween_property(btn, "scale", Vector2(1.1, 1.1), 0.1).set_trans(Tween.TRANS_SINE)

func _on_button_unhover(btn: Button):
	var tween = create_tween()
	tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_SINE)

func _on_start_button_pressed():
	if SceneTransition:
		SceneTransition.change_scene("res://Levels/level_1.tscn")
	else:
		get_tree().change_scene_to_file("res://Levels/level_1.tscn")

func _on_quit_button_pressed():
	get_tree().quit()
