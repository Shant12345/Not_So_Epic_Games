extends Node

var current_time_minutes: float = 600.0 # 10 * 60 = 10:00 AM
var inventory_items: Array[Dictionary] = []

# Checkpoint backup for the current level
var checkpoint_time: float = 600.0
var checkpoint_inventory: Array[Dictionary] = []
var checkpoint_pending: bool = true

func reset() -> void:
	current_time_minutes = 600.0
	inventory_items.clear()
	checkpoint_time = 600.0
	checkpoint_inventory.clear()
	checkpoint_pending = true

func prepare_new_level() -> void:
	checkpoint_pending = true

func save_level_checkpoint() -> void:
	checkpoint_time = current_time_minutes
	checkpoint_inventory = []
	for item in inventory_items:
		checkpoint_inventory.append(item.duplicate(true))
	checkpoint_pending = false

func load_level_checkpoint() -> void:
	current_time_minutes = checkpoint_time
	inventory_items = []
	for item in checkpoint_inventory:
		inventory_items.append(item.duplicate(true))

