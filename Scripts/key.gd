extends Area2D

@export var item_name: String = "Key"
@export var item_description: String = "A heavy iron key that opens many doors."
@export var item_type: String = "key"
@export var item_icon: Texture2D

func _ready() -> void:
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play("default")
	elif has_node("Sprite2D"):
		# Add a simple bobbing animation if we have a sprite
		var tween = create_tween().set_loops()
		tween.tween_property($Sprite2D, "position:y", -10, 1.0).as_relative().set_trans(Tween.TRANS_SINE)
		tween.tween_property($Sprite2D, "position:y", 10, 1.0).as_relative().set_trans(Tween.TRANS_SINE)

	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	if parent.is_in_group("Player") or parent.name == "Player":
		# The player script handles the actual inventory addition in its own _on_area_entered
		# but we need to make sure we're deleted after being picked up.
		# However, to avoid race conditions, we can let the player call a 'pickup' method.
		pass

func pickup() -> void:
	# Optional: play a sound or particle effect
	queue_free()
