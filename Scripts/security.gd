extends CharacterBody2D

@export var point_a: Vector2 = Vector2(173, 339)
@export var point_b: Vector2 = Vector2(986, 338)
@export var move_time: float = 4.0
@export var pause_at_end: float = 0.25
@export var slow_duration: float = 3.0  # seconds to stay slowed after hitting player
var health := 70

var going_to_b := true
var _is_slowed := false
var _current_tween: Tween = null

func _ready():
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play("default")
	
	if has_node("PointA") and has_node("PointB"):
		point_a = $PointA.global_position
		point_b = $PointB.global_position
	position = point_a
	
	var hit_box = get_node_or_null("HitBox")
	if hit_box:
		hit_box.body_entered.connect(_on_hit_box_body_entered)
		
	move_to_next_point()

func move_to_next_point():
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
	var effective_time = move_time * (2.0 if _is_slowed else 1.0)
	
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

func _on_hit_box_body_entered(body: Node2D):
	if body.is_in_group("Player") or body.name == "Player":
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


func _apply_slow():
	_is_slowed = true
	# Restart movement with new slowed speed
	move_to_next_point()
	
	# Remove slow after duration
	await get_tree().create_timer(slow_duration).timeout
	_is_slowed = false
	move_to_next_point()
