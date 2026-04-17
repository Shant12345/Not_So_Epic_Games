extends CharacterBody2D

@export var max_speed := 300.0
@export var acceleration := 800.0
var _anim_time := 0.0
var _original_sprite_pos := Vector2.ZERO

func _ready() -> void:
	var hit_box = get_node_or_null("HitBox")
	if hit_box:
		hit_box.body_entered.connect(_on_hit_box_body_entered)
	
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		_original_sprite_pos = sprite.position
		sprite.modulate.a = 1.0 # Ensure fully opaque

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
	var direction := global_position.direction_to(player_pos)
	var distance := global_position.distance_to(player_pos)
	
	var speed := max_speed
	if distance < 50:
		speed = max_speed * (distance / 50.0)

	var desired_velocity := direction * speed
	velocity = velocity.move_toward(desired_velocity, acceleration * delta)
	
	move_and_slide()

	# Animation Logic
	_anim_time += delta
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		# Directional Flip
		if velocity.x != 0:
			sprite.flip_h = velocity.x < 0
		
		# Slight Ghostly Bobbing (Sine wave on Y)
		sprite.position.y = _original_sprite_pos.y + sin(_anim_time * 4.0) * 8.0
		
		# Walking animation cycle
		var total_frames = sprite.hframes * sprite.vframes
		if total_frames > 1:
			if velocity.length() > 10:
				sprite.frame = int(_anim_time * 8) % total_frames
			else:
				sprite.frame = 0
		else:
			sprite.frame = 0
