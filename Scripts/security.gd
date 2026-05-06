extends CharacterBody2D

@export var point_a: Vector2 = Vector2(173, 339)
@export var point_b: Vector2 = Vector2(986, 338)
@export var move_time: float = 4.0
@export var pause_at_end: float = 0.25
@export var slow_duration: float = 1.0  # seconds to stay slowed after hitting player
@export var chase_speed: float = 350.0
@export var damage_cooldown: float = 1.5
var health := 70

var going_to_b := true
var _is_slowed := false
var _current_tween: Tween = null
var _player_in_range: Node2D = null
var _can_damage := true
var _already_hit_player := false

func _ready():
	# Use FLOATING mode to prevent physical pushing/interaction with player physics
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play("default")
	
	if has_node("PointA") and has_node("PointB"):
		point_a = $PointA.global_position
		point_b = $PointB.global_position
	else:
		point_a = position
		# If point_b was default, make it relative to current position to avoid huge jumps
		point_b = position + (point_b - Vector2(173, 339))
	
	position = point_a
	
	var hit_box = get_node_or_null("HitBox")
	if hit_box:
		hit_box.body_entered.connect(_on_hit_box_body_entered)
	
	# Connect detection radius signals
	var detection = get_node_or_null("DetectionRadius")
	if detection:
		detection.body_entered.connect(_on_detection_body_entered)
		detection.body_exited.connect(_on_detection_body_exited)
		
	move_to_next_point()

func _physics_process(delta: float) -> void:
	if _player_in_range and is_instance_valid(_player_in_range) and not _already_hit_player:
		# Chase the player — kill the patrol tween
		if _current_tween:
			_current_tween.kill()
			_current_tween = null
		
		var direction = global_position.direction_to(_player_in_range.global_position)
		var effective_speed = chase_speed * (0.5 if _is_slowed else 1.0)
		velocity = direction * effective_speed
		move_and_slide()
		
		# Flip sprite to face the player
		if has_node("AnimatedSprite2D"):
			var sprite = $AnimatedSprite2D
			if direction.x != 0:
				sprite.flip_h = direction.x < 0
		
		# Deal damage when close enough
		var dist = global_position.distance_to(_player_in_range.global_position)
		if dist < 60 and _can_damage:
			_deal_damage(_player_in_range)

func _on_detection_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") or body.name == "Player":
		_player_in_range = body
		_already_hit_player = false

func _on_detection_body_exited(body: Node2D) -> void:
	if body == _player_in_range:
		_player_in_range = null
		_already_hit_player = false
		# Resume patrol if we weren't already
		if not _current_tween:
			move_to_next_point()

func _on_hit_box_body_entered(body: Node2D):
	if body.is_in_group("Player") or body.name == "Player":
		_deal_damage(body)

func move_to_next_point():
	# Don't patrol if actively chasing (not yet hit)
	if _player_in_range and not _already_hit_player:
		return
		
	var target = point_b if going_to_b else point_a
	var direction = (target - position).normalized()
	
	if has_node("AnimatedSprite2D"):
		var sprite = $AnimatedSprite2D
		sprite.flip_v = false
		if direction.x < 0:
			sprite.flip_h = true
		elif direction.x > 0:
			sprite.flip_h = false
	
	# Halve the speed (double the time) when slowed
	var effective_time = move_time * (1.0 if _is_slowed else 0.5)
	
	# Adjust time proportionally based on remaining distance
	var total_dist = point_a.distance_to(point_b)
	if total_dist > 0:
		var remaining_dist = position.distance_to(target)
		effective_time *= (remaining_dist / total_dist)
	
	if _current_tween:
		_current_tween.kill()
	
	_current_tween = create_tween()
	_current_tween.tween_property(self, "position", target, max(effective_time, 0.01)).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	_current_tween.finished.connect(_on_tween_finished)

func _on_tween_finished():
	going_to_b = !going_to_b
	move_to_next_point()

func _deal_damage(body: Node2D) -> void:
	if not _can_damage:
		return
	_can_damage = false
	_already_hit_player = true
	
	if body.has_method("take_damage"):
		body.take_damage(10)
	else:
		# Fallback
		get_tree().reload_current_scene()
	
	# Stun the player
	if body.has_method("stun"):
		body.stun()
	
	# Slow the guard after hitting the player
	_apply_slow()
	
	# Resume patrol immediately since we stopped chasing
	move_to_next_point()
	
	# Damage cooldown
	await get_tree().create_timer(damage_cooldown).timeout
	_can_damage = true

func _apply_slow():
	_is_slowed = true
	# Restart movement with new slowed speed
	if not _player_in_range:
		move_to_next_point()
	
	# Remove slow after duration
	await get_tree().create_timer(slow_duration).timeout
	_is_slowed = false
	if not _player_in_range:
		move_to_next_point()
