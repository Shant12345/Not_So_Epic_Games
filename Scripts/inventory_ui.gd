extends Control

## Hotbar style inventory UI
## Displays 5 slots at the bottom. Click to select, press 'E' (interact) to use.

@onready var container: HBoxContainer = $Panel/MarginContainer/HBoxContainer

var inventory: Inventory = null
var selected_index: int = -1

func _ready() -> void:
	visible = true

func setup(inv: Inventory) -> void:
	inventory = inv
	inventory.inventory_changed.connect(_refresh)
	_refresh()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and selected_index >= 0:
		if inventory and selected_index < inventory.items.size():
			inventory.use_item(inventory.items[selected_index]["name"])
			# The door interact action is also 'E'. The door script checks 'is_action_pressed'.
			# It's okay if both happen, but typically if player uses a health pack, we might not want to open door.
			# But if they use a key, the door consumes the key automatically via _player_has_key / _consume_key anyway.
			# So we don't necessarily have to block the door.

func _refresh() -> void:
	if container == null:
		return

	# Remove old slot nodes
	for child in container.get_children():
		child.queue_free()

	if inventory == null:
		return
		
	# Ensure selected_index is valid
	if selected_index >= inventory.items.size() and inventory.items.size() > 0:
		selected_index = inventory.items.size() - 1
	elif inventory.items.size() == 0:
		selected_index = -1

	for i in inventory.items.size():
		var item = inventory.items[i]
		var slot := _create_slot(item, i)
		container.add_child(slot)

	# Fill remaining empty slots up to MAX_SLOTS for visual consistency
	var empty_slots := inventory.MAX_SLOTS - inventory.items.size()
	for i in empty_slots:
		var empty := _create_empty_slot(inventory.items.size() + i)
		container.add_child(empty)


func _create_slot(item: Dictionary, index: int) -> PanelContainer:
	var slot := PanelContainer.new()
	slot.custom_minimum_size = Vector2(80, 80)
	slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# Slot background style
	var style := StyleBoxFlat.new()
	style.bg_color = _get_slot_color(item.get("type", "misc"))
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_right = 6
	style.corner_radius_bottom_left = 6
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	if index == selected_index:
		style.border_color = Color(1, 1, 0.4, 1.0) # Yellow highlight text
		style.border_width_left = 3
		style.border_width_top = 3
		style.border_width_right = 3
		style.border_width_bottom = 3
	else:
		style.border_color = Color(1, 1, 1, 0.15)
	slot.add_theme_stylebox_override("panel", style)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	slot.add_child(vbox)

	# Item icon
	if item.get("icon") != null:
		var tex_rect := TextureRect.new()
		tex_rect.texture = item["icon"]
		tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex_rect.custom_minimum_size = Vector2(48, 48)
		tex_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		tex_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		vbox.add_child(tex_rect)
	else:
		var icon_label := Label.new()
		icon_label.text = _get_item_icon(item.get("type", "misc"))
		icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		icon_label.add_theme_font_size_override("font_size", 28)
		vbox.add_child(icon_label)


	# Item name
	var name_label := Label.new()
	name_label.text = item["name"]
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 11)
	name_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	vbox.add_child(name_label)

	# Quantity badge
	if item["quantity"] > 1:
		var qty_label := Label.new()
		qty_label.text = "x" + str(item["quantity"])
		qty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		qty_label.add_theme_font_size_override("font_size", 10)
		qty_label.add_theme_color_override("font_color", Color(0.7, 0.85, 1.0))
		vbox.add_child(qty_label)

	# Select-item button (invisible, overlays the slot)
	var btn := Button.new()
	btn.flat = true
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn.anchors_preset = Control.PRESET_FULL_RECT
	btn.tooltip_text = item.get("description", item["name"])
	btn.pressed.connect(func(): _on_slot_pressed(index))
	slot.add_child(btn)

	return slot


func _create_empty_slot(index: int) -> PanelContainer:
	var slot := PanelContainer.new()
	slot.custom_minimum_size = Vector2(80, 80)
	slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.12, 0.15, 0.5)
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_right = 6
	style.corner_radius_bottom_left = 6
	if index == selected_index:
		style.border_color = Color(1, 1, 0.4, 0.8)
		style.border_width_left = 2
		style.border_width_top = 2
		style.border_width_right = 2
		style.border_width_bottom = 2
	else:
		style.border_color = Color(1, 1, 1, 0.05)
		style.border_width_left = 1
		style.border_width_top = 1
		style.border_width_right = 1
		style.border_width_bottom = 1
	slot.add_theme_stylebox_override("panel", style)
	
	var btn := Button.new()
	btn.flat = true
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn.anchors_preset = Control.PRESET_FULL_RECT
	btn.pressed.connect(func(): _on_slot_pressed(index))
	slot.add_child(btn)

	return slot


# ──────────────────────────────────────
#  Helpers
# ──────────────────────────────────────

func _on_slot_pressed(index: int) -> void:
	selected_index = index
	_refresh()


func _get_slot_color(type: String) -> Color:
	match type:
		"healing":
			return Color(0.15, 0.35, 0.15, 0.85)
		"key":
			return Color(0.4, 0.35, 0.1, 0.85)
		"weapon":
			return Color(0.35, 0.12, 0.12, 0.85)
		"ammo":
			return Color(0.12, 0.2, 0.35, 0.85)
		_:
			return Color(0.18, 0.18, 0.22, 0.85)


func _get_item_icon(type: String) -> String:
	match type:
		"healing":
			return "+"
		"key":
			return "*"
		"weapon":
			return "!"
		"ammo":
			return ">"
		_:
			return "?"
