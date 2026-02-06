extends Area2D


func _ready() -> void:
	area_entered.connect(_area_entered)

func _area_entered(_area_that_entered: Area2D) -> void:
	queue_free()
