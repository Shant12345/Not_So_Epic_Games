extends Control

## Inventory UI — toggled with the "inventory" input action (Tab).
## Displays items in a grid of slots.  Left-click a slot to use the item.

@onready var grid: GridContainer = $Panel/MarginContainer/VBoxContainer/ScrollContainer/GridContainer
@onready var title_label: Label = $Panel/MarginContainer/VBoxContainer/TitleLabel

var inventory: Inventory = null
var slot_scene_cache: Dictionary = {}

# ──────────────────────────────────────
#  Lifecycle
# ──────────────────────────────────────

func _ready() -> void:
	visible = false

func setup(inv: Inventory) -> void:
	inventory = inv
	inventory.inventory_changed.connect(_refresh)
	_refresh()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		toggle()

# ──────────────────────────────────────
#  Show / Hide
# ──────────────────────────────────────

func toggle() -> void:
	visible = !visible
	# Pause / unpause tree so gameplay freezes while inventory is open
	get_tree().paused = visible

func open() -> void:
	visible = true
	get_tree().paused = true

func close() -> void:
	visible = false
	get_tree().paused = false

# ──────────────────────────────────────
#  Rendering
# ──────────────────────────────────────

func _refresh() -> void:
	if grid == null:
		return

	# Remove old slot nodes
	for child in grid.get_children():
		child.queue_free()

	if inventory == null:
		return

	for item in inventory.items:
		var slot := _create_slot(item)
		grid.add_child(slot)

	# Fill remaining empty slots up to MAX_SLOTS for visual consistency
	var empty_slots := inventory.MAX_SLOTS - inventory.items.size()
	for i in empty_slots:
		var empty := _create_empty_slot()
		grid.add_child(empty)


func _create_slot(item: Dictionary) -> PanelContainer:
	var slot := PanelContainer.new()
	slot.custom_minimum_size = Vector2(80, 80)

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
	style.border_color = Color(1, 1, 1, 0.15)
	slot.add_theme_stylebox_override("panel", style)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	slot.add_child(vbox)

	# Item icon (emoji-style label for simplicity)
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

	# Use-item button (invisible, overlays the slot)
	var btn := Button.new()
	btn.flat = true
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn.anchors_preset = Control.PRESET_FULL_RECT
	btn.tooltip_text = item.get("description", item["name"])
	btn.pressed.connect(func(): _on_slot_pressed(item["name"]))
	slot.add_child(btn)

	return slot


func _create_empty_slot() -> PanelContainer:
	var slot := PanelContainer.new()
	slot.custom_minimum_size = Vector2(80, 80)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.12, 0.15, 0.5)
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_right = 6
	style.corner_radius_bottom_left = 6
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(1, 1, 1, 0.05)
	slot.add_theme_stylebox_override("panel", style)

	return slot


# ──────────────────────────────────────
#  Helpers
# ──────────────────────────────────────

func _on_slot_pressed(item_name: String) -> void:
	if inventory:
		inventory.use_item(item_name)


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
