extends Node

var current_time_minutes: float = 1200.0 # 20 * 60 = 8:00 PM
var inventory_items: Array[Dictionary] = []

func reset() -> void:
	current_time_minutes = 1200.0
	inventory_items.clear()
