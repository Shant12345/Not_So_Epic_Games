extends Area2D

## Key pickup — collected by walking over it.
## Adds one "Key" to the player's inventory, then disappears.
## Spins and bobs up and down to attract the player's attention.

@export var bob_height := 8.0       # pixels up and down
@export var bob_speed := 2.5        # oscillations per second
@export var spin_speed := 2.0       # full rotations per second

var _time := 0.0
var _base_y := 0.0
var _sprite: Sprite2D = null

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	_sprite = get_node_or_null("Sprite2D")
	_base_y = position.y

func _process(delta: float) -> void:
	_time += delta

	# Bob up and down (sine wave)
	position.y = _base_y + sin(_time * bob_speed * TAU) * bob_height

	# Spin the sprite
	if _sprite:
		_sprite.rotation += spin_speed * TAU * delta

func _on_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	if parent.is_in_group("Player") or parent.name == "Player":
		if "inventory" in parent and parent.inventory != null:
			parent.inventory.add_item("Key", 1, "Opens a locked door.", "key")
		queue_free()
