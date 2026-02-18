extends CharacterBody2D

@export var max_speed := 350.0
@export var acceleration := 700.0

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

func _ready() -> void:
	navigation_agent.path_desired_distance = 20.0
	navigation_agent.target_desired_distance = 20.0
	
	var hit_box = get_node_or_null("HitBox")
	if hit_box:
		hit_box.body_entered.connect(_on_hit_box_body_entered)

	call_deferred("actor_setup")

func actor_setup():
	await get_tree().physics_frame

func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		get_tree().reload_current_scene()

func _physics_process(delta: float) -> void:
	var player = get_tree().root.find_child("Player", true, false)
	if player:
		navigation_agent.target_position = player.global_position

	if navigation_agent.is_navigation_finished():
		return

	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()

	var direction := current_agent_position.direction_to(next_path_position)
	var desired_velocity := direction * max_speed
	velocity = velocity.move_toward(desired_velocity, acceleration * delta)

	move_and_slide()

	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		sprite.flip_h = velocity.x < 0
