extends Node

var current_time_minutes: float = 600.0 # 10 * 60 = 10:00 AM
var inventory_items: Array[Dictionary] = []

func reset() -> void:
	current_time_minutes = 600.0
	inventory_items.clear()
