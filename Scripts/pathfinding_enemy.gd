extends CharacterBody2D

@export var max_speed := 350.0
@export var acceleration := 700.0

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

func _ready() -> void:
	# These values need to be adjusted based on the actor's size
	# and the desired behavior.
	navigation_agent.path_desired_distance = 20.0
	navigation_agent.target_desired_distance = 20.0

	# Make sure to not await during _ready.
	call_deferred("actor_setup")

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now the agent is ready to query the navigation map.
	# We can update the target here or in _physics_process.

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

	# Visual indicator: flip sprite
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		sprite.flip_h = velocity.x < 0
