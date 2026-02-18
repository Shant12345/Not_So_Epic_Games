extends CharacterBody2D

@export var max_speed := 600.0
@export var acceleration := 1200.0
@export var avoidance_strength := 21000.0
@onready var hit_box: Area2D = $HitBox
@onready var raycasts: Node2D = %Raycasts

func _ready() -> void:
	hit_box.body_entered.connect(_on_hit_box_body_entered)

func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		get_tree().reload_current_scene()




func get_global_player_position() -> Vector2:
	var player = get_tree().root.find_child("Player", true, false)
	if player:
		return player.global_position
	return global_position

func _physics_process(delta: float) -> void:
	var direction := global_position.direction_to(get_global_player_position())
	var distance := global_position.distance_to(get_global_player_position())
	var speed := max_speed if distance > 100 else max_speed * distance / 100

	var desired_velocity := direction * speed
	
	# Apply avoidance force
	var avoidance_force := calculate_avoidance_force()
	desired_velocity += avoidance_force
	
	velocity = velocity.move_toward(desired_velocity, acceleration * delta)
	move_and_slide()
	
	
func calculate_avoidance_force() -> Vector2:
	var avoidance_force := Vector2.ZERO

	for raycast: RayCast2D in raycasts.get_children():
		if raycast.is_colliding():
			var collision_position := raycast.get_collision_point()
			var direction_away_from_obstacle := collision_position.direction_to(raycast.global_position)
			var ray_length := raycast.target_position.length()
			var intensity := 1.0 - collision_position.distance_to(raycast.global_position) / ray_length

			var force := direction_away_from_obstacle * avoidance_strength * intensity
			avoidance_force += force

	return avoidance_force
