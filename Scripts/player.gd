extends CharacterBody2D

@export var max_speed := 1000.0
@export var acceleration := 3500.0
@export var deceleration := 3500.0
var health := 70

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
	health = new_health
	var health_bar = get_node_or_null("UI/HealthBar")
	if health_bar:
		health_bar.value = health

func _on_area_entered(_area_that_entered: Area2D) -> void:
	set_health(health + 10)
	

func get_global_player_position() -> Vector2:
	return global_position
