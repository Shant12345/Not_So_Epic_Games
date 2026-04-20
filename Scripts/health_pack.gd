extends Area2D

@export var item_name: String = "Health Pack"
@export var item_description: String = "Restores 25 HP"
@export var item_type: String = "heal"
@export var item_icon: Texture2D

func _ready() -> void:
	if has_node("AnimationPlayer"):
		$AnimationPlayer.play("default")
	elif has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play("default")

func pickup() -> void:
	# Add any visual/audio feedback here
	queue_free()
