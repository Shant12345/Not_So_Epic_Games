extends CharacterBody2D

@export var max_speed := 1400.0
@export var acceleration := 3500.0
@export var deceleration := 3500.0
var health := 30

func _ready() -> void:
	var hitbox = get_node_or_null("Hitbox")
	if hitbox:
		hitbox.area_entered.connect(_on_area_entered)
	
	set_health(health)

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_down", "move_up")
	var has_input_direction := direction.length() > 0.0
	
	var target_velocity := direction * max_speed
	
	if has_input_direction:
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
		
	move_and_slide()

func set_health(new_health: int) -> void:
	health = clamp(new_health, 0, 100)
	var health_bar = get_node_or_null("CanvasLayer/UI/HealthBar")
	if health_bar:
		var tween = create_tween()
		tween.tween_property(health_bar, "value", health, 0.3).set_trans(Tween.TRANS_SINE)
		
		var hp_number = health_bar.get_node_or_null("HPNumber")
		if hp_number:
			hp_number.text = str(health) + " / 100"
		
		# Dynamic color logic
		var style_box = health_bar.get_theme_stylebox("fill").duplicate()
		if health > 50:
			style_box.bg_color = Color(0, 0.8, 0.4) # Green
		elif health > 25:
			style_box.bg_color = Color(1, 0.6, 0.2) # Orange
		else:
			style_box.bg_color = Color(0.8, 0.1, 0.1) # Red
		health_bar.add_theme_stylebox_override("fill", style_box)
	
	if health <= 0:
		get_tree().reload_current_scene()

func take_damage(amount: int) -> void:
	set_health(health - amount)

func _on_area_entered(_area_that_entered: Area2D) -> void:
	set_health(health + 10)
	

func get_global_player_position() -> Vector2:
	return global_position
