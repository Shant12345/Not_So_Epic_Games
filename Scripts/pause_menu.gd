extends Control

func _ready():
	visible = false
	# Add hover effects to all buttons
	for btn in find_children("*", "Button", true):
		btn.ready.connect(func(): btn.pivot_offset = btn.size / 2)
		btn.mouse_entered.connect(_on_button_hover.bind(btn))
		btn.mouse_exited.connect(_on_button_unhover.bind(btn))

func _on_button_hover(btn: Button):
	var tween = create_tween()
	tween.tween_property(btn, "scale", Vector2(1.1, 1.1), 0.1).set_trans(Tween.TRANS_SINE)

func _on_button_unhover(btn: Button):
	var tween = create_tween()
	tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_SINE)

func _input(event):
	if event.is_action_pressed("pause"):
		var is_paused = not get_tree().paused
		get_tree().paused = is_paused
		visible = is_paused
		
		if is_paused:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			
		# Prevent other input events from firing
		get_viewport().set_input_as_handled()

func _on_resume_pressed():
	get_tree().paused = false
	visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_restart_pressed():
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().reload_current_scene()

func _on_quit_pressed():
	get_tree().paused = false
	if SceneTransition:
		SceneTransition.change_scene("res://tscn/main_menu.tscn")
	else:
		get_tree().change_scene_to_file("res://tscn/main_menu.tscn")

func _on_pause_hud_button_pressed():
	var is_paused = not get_tree().paused
	get_tree().paused = is_paused
	visible = is_paused
	
	if is_paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
