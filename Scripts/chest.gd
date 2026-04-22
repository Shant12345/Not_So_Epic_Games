extends Area2D

@export var is_open: bool = false
@export var items_inside: Array[String] = ["Pizza"] # Default reward

signal opened(items)

@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	anim_player.play("closed")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Check if it's the player and they are moving into the chest
	if not is_open and body.name == "player":
		open_chest()

func open_chest() -> void:
	is_open = true
	anim_player.play("open")
	opened.emit(items_inside)
	# Logic to give items to player inventory
	if body_entered.is_connected(_on_body_entered):
		body_entered.disconnect(_on_body_entered)
	print("Chest opened! Found: ", items_inside)

