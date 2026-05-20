extends CharacterBody2D

@export var max_speed := 200.0
@export var acceleration := 600.0
var _original_sprite_pos := Vector2.ZERO
var _original_sprite_scale := Vector2(1,1)

func _ready() -> void:
	# Set collision mask to 0 to phase through all obstacles (Walls, Player, etc.)
	# The HitBox (Area2D) will still handle detecting the player for kills.
	collision_mask = 0
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	
	var hit_box = get_node_or_null("HitBox")
	if hit_box:
		hit_box.body_entered.connect(_on_hit_box_body_entered)
	
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		_original_sprite_pos = sprite.position
		_original_sprite_scale = sprite.scale
		# Give it a ghostly semi-transparent look
		sprite.modulate.a = 0.7 

@onready var stab_sound = $StabSound
@onready var footstep_sound = get_node_or_null("FootstepSound")

func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") or body.name == "Player":
		if body.has_method("die"):
			if stab_sound:
				stab_sound.play()
			body.die(true)
		# Killer Crush contact = instant death

func get_global_player_position() -> Vector2:
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		return player.global_position
	return global_position

func _physics_process(delta: float) -> void:
	var player_pos = get_global_player_position()
	var direction := global_position.direction_to(player_pos)
	var distance := global_position.distance_to(player_pos)
	
	var speed := max_speed
	if distance < 50:
		speed = max_speed * (distance / 50.0)

	var desired_velocity := direction * speed
	velocity = velocity.move_toward(desired_velocity, acceleration * delta)
	
	move_and_slide()

	# Animation Logic
	var anim_player = get_node_or_null("AnimationPlayer")
	var sprite = get_node_or_null("Sprite2D")
	
	if sprite:
		# Directional Flip
		if velocity.x != 0:
			sprite.flip_h = velocity.x < 0
	
	if anim_player:
		if distance < 150:
			if anim_player.current_animation != "crush":
				# print("Playing crush animation")
				anim_player.play("crush")
			# Stop footsteps during crush
			if footstep_sound and footstep_sound.playing:
				footstep_sound.stop()
		elif velocity.length() > 10:
			if anim_player.current_animation != "walk":
				# print("Playing walk animation")
				anim_player.play("walk")
			# Play footsteps while walking (only if visible on screen)
			if is_on_screen():
				if footstep_sound and not footstep_sound.playing:
					footstep_sound.play()
			else:
				if footstep_sound and footstep_sound.playing:
					footstep_sound.stop()
		else:
			if anim_player.is_playing():
				anim_player.stop()
			# Stop footsteps when idle
			if footstep_sound and footstep_sound.playing:
				footstep_sound.stop()
			if sprite:
				sprite.frame = 0
				sprite.position = _original_sprite_pos
				sprite.scale = _original_sprite_scale

func is_on_screen() -> bool:
	var player = get_tree().get_first_node_in_group("Player")
	if not player:
		return false
	var camera = player.get_node_or_null("Camera2D")
	if not camera:
		return false
	var viewport_size = get_viewport_rect().size
	var zoom = camera.zoom
	var visible_size = viewport_size / zoom
	var camera_center = camera.global_position
	var view_rect = Rect2(camera_center - visible_size / 2.0, visible_size)
	return view_rect.has_point(global_position)
