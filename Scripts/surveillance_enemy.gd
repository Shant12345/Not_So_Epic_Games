extends CharacterBody2D

@export var max_speed := 300.0
@export var acceleration := 600.0
@export var detection_radius := 400.0

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var detection_area: Area2D = $DetectionArea
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_chasing := false
var is_killing := false
var damage_cooldown := 1.0
var time_since_last_damage := 0.0

func _ready() -> void:
	navigation_agent.path_desired_distance = 20.0
	navigation_agent.target_desired_distance = 20.0
	
	# Configure detection area collision shape if it exists
	var collision_shape = detection_area.get_node_or_null("CollisionShape2D")
	if collision_shape and collision_shape.shape is CircleShape2D:
		collision_shape.shape.radius = detection_radius
		
	var hit_box = get_node_or_null("HitBox")
	if hit_box:
		hit_box.body_entered.connect(_on_hit_box_body_entered)

func _on_hit_box_body_entered(body: Node2D) -> void:
	if is_killing:
		return
		
	if body.name == "Player" or body.is_in_group("Player"):
		if time_since_last_damage >= damage_cooldown:
			inflict_damage(body)


func inflict_damage(player: Node2D) -> void:
	time_since_last_damage = 0.0
	if player.has_method("take_damage"):
		player.take_damage(10)
	
	if animation_player.has_animation("kill"):
		animation_player.play("kill")


func _physics_process(delta: float) -> void:
	if is_killing:
		return
		
	var player = get_tree().root.find_child("Player", true, false)
	
	if player:
		var distance_to_player = global_position.distance_to(player.global_position)
		
		
		if distance_to_player <= detection_radius:
			is_chasing = true
		else:
			is_chasing = false
			velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
		
		if is_chasing:
			navigation_agent.target_position = player.global_position
			
			if not navigation_agent.is_navigation_finished():
				var next_path_position: Vector2 = navigation_agent.get_next_path_position()
				var direction := global_position.direction_to(next_path_position)
				var desired_velocity := direction * max_speed
				velocity = velocity.move_toward(desired_velocity, acceleration * delta)

	time_since_last_damage += delta
	move_and_slide()

	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		sprite.flip_h = velocity.x < 0
		
		sprite.modulate = Color(1, 0.5, 0) if is_chasing else Color(1, 1, 0)
