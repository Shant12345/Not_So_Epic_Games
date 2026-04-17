extends Control

@onready var title = $CenterContainer/VBoxContainer/Title
@onready var subtitle = $CenterContainer/VBoxContainer/Subtitle
@onready var buttons_container = $CenterContainer/VBoxContainer/Buttons

func _ready():
	# Ensure the tree isn't paused (or handle pausing if needed)
	# If we pause the game when death screen is shown, process_mode should be set to ALWAYS on this node
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Initial UI state for animations
	modulate.a = 0
	title.position.y -= 30
	subtitle.modulate.a = 0
	buttons_container.modulate.a = 0
	
	# Create a dark, moody entrance animation
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	
	# Fade in everything
	tween.tween_property(self, "modulate:a", 1.0, 1.5)
	
	# Slide title into place
	tween.tween_property(title, "position:y", title.position.y + 30, 2.0).set_delay(0.5)
	
	# Fade in subtitle and buttons with staggered timing
	tween.tween_property(subtitle, "modulate:a", 1.0, 1.2).set_delay(1.2)
	tween.tween_property(buttons_container, "modulate:a", 1.0, 1.2).set_delay(2.0)
	
	# Add a continuous eerie pulse to the title
	_pulse_title_forever()

func _pulse_title_forever():
	var pulse_tween = create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	pulse_tween.tween_property(title, "scale", Vector2(1.03, 1.03), 3.0)
	pulse_tween.tween_property(title, "scale", Vector2(1.0, 1.0), 3.0)

func _on_retry_button_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_main_menu_button_pressed():
	get_tree().paused = false
	if get_node_or_null("/root/SceneTransition"):
		get_node("/root/SceneTransition").change_scene("res://tscn/main_menu.tscn")
	else:
		get_tree().change_scene_to_file("res://tscn/main_menu.tscn")

func _on_quit_button_pressed():
	get_tree().quit()
