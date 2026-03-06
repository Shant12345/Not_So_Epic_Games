extends Area2D


func _ready() -> void:
	area_entered.connect(_area_entered)

func _area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("Player") or area.get_parent().name == "Player":
		queue_free()
