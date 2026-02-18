extends CharacterBody2D

@export var max_speed := 200.0
@export var acceleration := 800.0

func _ready() -> void:
	var hit_box = get_node_or_null("HitBox")
	if hit_box:
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
	var player_pos = get_global_player_position()
	var direction := global_position.direction_to(player_pos)
	var distance := global_position.distance_to(player_pos)
	

	var speed := max_speed
	if distance < 50:
		speed = max_speed * (distance / 50.0)

	var desired_velocity := direction * speed
	velocity = velocity.move_toward(desired_velocity, acceleration * delta)
	
	
	move_and_slide()

	
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		sprite.flip_h = velocity.x < 0
