extends CharacterBody2D

@export var max_speed := 1700.0
@export var acceleration := 4500.0
@export var deceleration := 4500.0
var health := 10

func _ready() -> void:
	$Hitbox.area_entered.connect(_on_area_entered)
	set_health(health)

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("move_left","move_right","move_down","move_up")
	var has_input_direction := direction.length() > 0.0
	if has_input_direction:
		var desired_velocity := direction * max_speed
		velocity = velocity.move_toward(desired_velocity, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
	move_and_slide()

func set_health(new_health: int) -> void:
	health = new_health
	get_node("UI/HealthBar").value = health

func _on_area_entered(_area_that_entered: Area2D) -> void:
	set_health(health + 10)
func get_global_player_position() -> Vector2:
	return get_tree().root.get_node("Game/Player").global_position
