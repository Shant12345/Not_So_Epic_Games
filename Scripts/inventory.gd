extends Node
class_name Inventory

## Inventory system — stores items as { "name": String, "quantity": int, "description": String, "type": String }
## Emits signals so the UI can stay in sync.

signal inventory_changed
signal item_used(item_name: String)

const MAX_SLOTS := 5

var items: Array[Dictionary] = []

# ──────────────────────────────────────
#  Public API
# ──────────────────────────────────────

## Returns true if the item was successfully added.
func add_item(item_name: String, quantity: int = 1, description: String = "", type: String = "misc", icon: Texture2D = null) -> bool:
	# Try to stack onto an existing entry first
	for item in items:
		if item["name"] == item_name:
			item["quantity"] += quantity
			inventory_changed.emit()
			return true

	# Otherwise create a new slot (if room)
	if items.size() >= MAX_SLOTS:
		return false

	items.append({
		"name": item_name,
		"quantity": quantity,
		"description": description,
		"type": type,
		"icon": icon
	})
	inventory_changed.emit()
	return true



## Removes *quantity* of the given item.  Returns true on success.
func remove_item(item_name: String, quantity: int = 1) -> bool:
	for i in items.size():
		if items[i]["name"] == item_name:
			items[i]["quantity"] -= quantity
			if items[i]["quantity"] <= 0:
				items.remove_at(i)
			inventory_changed.emit()
			return true
	return false


## Uses an item (removes 1 and emits item_used).
func use_item(item_name: String) -> bool:
	if remove_item(item_name, 1):
		item_used.emit(item_name)
		return true
	return false


## Returns the quantity of the given item (0 if not found).
func get_item_quantity(item_name: String) -> int:
	for item in items:
		if item["name"] == item_name:
			return item["quantity"]
	return 0


## Returns true if the inventory contains at least *quantity* of the item.
func has_item(item_name: String, quantity: int = 1) -> bool:
	return get_item_quantity(item_name) >= quantity


## Clears the entire inventory.
func clear() -> void:
	items.clear()
	inventory_changed.emit()
