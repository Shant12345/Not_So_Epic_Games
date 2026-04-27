extends Node

@export var mouse_speed := 1000.0
@export var deadzone := 0.15

func _process(delta: float) -> void:
	var stick_vector = Vector2(
		Input.get_joy_axis(0, JOY_AXIS_RIGHT_X),
		Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
	)
	
	if stick_vector.length() > deadzone:
		var mouse_pos = get_viewport().get_mouse_position()
		var movement = stick_vector * mouse_speed * delta
		get_viewport().warp_mouse(mouse_pos + movement)
	
	# Handle simulated click
	if Input.is_action_just_pressed("controller_left_click"):
		_simulate_mouse_click(true)
	elif Input.is_action_just_released("controller_left_click"):
		_simulate_mouse_click(false)

func _simulate_mouse_click(is_pressed: bool) -> void:
	var event = InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = is_pressed
	event.position = get_viewport().get_mouse_position()
	Input.parse_input_event(event)
