extends Control

@onready var audio_player = $PauseMusic

func _ready():
	visible = false
	
	audio_player.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Looping setup
	if audio_player.stream is AudioStreamWAV:
		audio_player.stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	
	# Add hover effects to all buttons
	for btn in find_children("*", "Button", true):
		btn.pivot_offset = btn.size / 2
		btn.mouse_entered.connect(_on_button_hover.bind(btn))
		btn.mouse_exited.connect(_on_button_unhover.bind(btn))

func set_paused(paused: bool):
	get_tree().paused = paused
	visible = paused
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if paused:
		if not audio_player.playing:
			audio_player.play()
	else:
		audio_player.stop()

func _on_button_hover(btn: Button):
	var tween = create_tween()
	tween.tween_property(btn, "scale", Vector2(1.1, 1.1), 0.1).set_trans(Tween.TRANS_SINE)

func _on_button_unhover(btn: Button):
	var tween = create_tween()
	tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_SINE)

func _input(event):
	if event.is_action_pressed("pause"):
		set_paused(not get_tree().paused)
		# Prevent other input events from firing
		get_viewport().set_input_as_handled()

func _on_resume_pressed():
	set_paused(false)

func _on_restart_pressed():
	set_paused(false)
	get_tree().reload_current_scene()

func _on_quit_pressed():
	set_paused(false)
	if SceneTransition:
		SceneTransition.change_scene("res://tscn/main_menu.tscn")
	else:
		get_tree().change_scene_to_file("res://tscn/main_menu.tscn")

func _on_pause_hud_button_pressed():
	set_paused(not get_tree().paused)

