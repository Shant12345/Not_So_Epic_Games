extends Area2D

@export var item_name: String = "Health Pack"
@export var item_description: String = "Restores 10 HP"
@export var item_icon: Texture2D

func _ready() -> void:
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play("default")
	area_entered.connect(_area_entered)


func _area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("Player") or area.get_parent().name == "Player":
		queue_free()
