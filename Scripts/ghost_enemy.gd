extends CharacterBody2D

@export var max_speed := 300.0
@export var acceleration := 1200.0
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

var _original_sprite_pos := Vector2.ZERO
var _original_sprite_scale := Vector2(1,1)

func _ready() -> void:
	var hit_box = get_node_or_null("HitBox")
	if hit_box:
		hit_box.body_entered.connect(_on_hit_box_body_entered)
	
	if sprite:
		_original_sprite_pos = sprite.position
		_original_sprite_scale = sprite.scale
		sprite.modulate.a = 1.0 # Ensure fully opaque
	
	# Setup navigation agent
	nav_agent.path_desired_distance = 15.0
	nav_agent.target_desired_distance = 15.0
	
	# Optimization: only recalculate path every few frames if needed, 
	# but for a "crush" stalker, every frame is usually fine in Godot 4
	
func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") or body.name == "Player":
		if body.has_method("die"):
			body.die()
		else:
			get_tree().reload_current_scene()

func get_global_player_position() -> Vector2:
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		return player.global_position
	return global_position

func _physics_process(delta: float) -> void:
	var player_pos = get_global_player_position()
	
	# Update target position
	nav_agent.target_position = player_pos
	
	if nav_agent.is_navigation_finished():
		# If close enough, just drift towards player slightly or stay still
		var direction := global_position.direction_to(player_pos)
		velocity = velocity.move_toward(direction * (max_speed * 0.5), acceleration * delta)
	else:
		var next_path_pos = nav_agent.get_next_path_position()
		var direction := global_position.direction_to(next_path_pos)
		var desired_velocity = direction * max_speed
		
		# Move towards the next point in the navmesh path
		velocity = velocity.move_toward(desired_velocity, acceleration * delta)
	
	# move_and_slide handles the physics collision
	# Since doors are on layer 16 and ghost mask is 3, it ignores doors.
	# It still collides with walls (layer 1).
	move_and_slide()

	# Distance to player for animation logic
	var distance_to_player = global_position.distance_to(player_pos)

	# Animation Logic
	if sprite:
		# Directional Flip
		if velocity.x != 0:
			sprite.flip_h = velocity.x < 0
	
	if anim_player:
		if distance_to_player < 150:
			if anim_player.current_animation != "crush":
				anim_player.play("crush")
		elif velocity.length() > 10:
			if anim_player.current_animation != "walk":
				anim_player.play("walk")
		else:
			if anim_player.is_playing():
				anim_player.stop()
			if sprite:
				sprite.frame = 0
				sprite.position = _original_sprite_pos
				sprite.scale = _original_sprite_scale
