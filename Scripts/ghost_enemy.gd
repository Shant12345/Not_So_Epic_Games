extends CharacterBody2D

@export var max_speed := 400.0
@export var acceleration := 800.0

func get_global_player_position() -> Vector2:
	var player = get_tree().root.find_child("Player", true, false)
	if player:
		return player.global_position
	return global_position

func _physics_process(delta: float) -> void:
	var player_pos = get_global_player_position()
	var direction := global_position.direction_to(player_pos)
	var distance := global_position.distance_to(player_pos)
	
	# Basic chase logic
	var speed := max_speed
	if distance < 50:
		speed = max_speed * (distance / 50.0)

	var desired_velocity := direction * speed
	velocity = velocity.move_toward(desired_velocity, acceleration * delta)
	
	# Use move_and_collide or just update position? 
	# CharacterBody2D move_and_slide handles collisions.
	# To "pass through" obstacles, we should configure the collision layers correctly.
	# However, if we want it to ONLY pass through certain things, we handle that in the scene set up.
	# For simplicity in the script, we just use move_and_slide.
	move_and_slide()

	# Visual indicator: flip sprite if needed (assuming a sprite child)
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		sprite.flip_h = velocity.x < 0
