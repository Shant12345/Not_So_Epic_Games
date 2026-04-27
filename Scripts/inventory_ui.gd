extends Control

## Grid-based inventory UI
## Displays items in a 5-column grid. Click to select, press 'E' to use.

const COLS := 5
const SLOT_SIZE := 72

var inventory: Inventory = null
var selected_index: int = -1

# Built in code — no @onready needed
var grid: GridContainer = null
var panel: PanelContainer = null
var title_label: Label = null

func _ready() -> void:
	visible = true
	_build_ui()

func setup(inv: Inventory) -> void:
	inventory = inv
	inventory.inventory_changed.connect(_refresh)
	_refresh()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and selected_index >= 0:
		if inventory and selected_index < inventory.items.size():
			inventory.use_item(inventory.items[selected_index]["name"])

# ──────────────────────────────────────
#  Build the UI
# ──────────────────────────────────────

func _build_ui() -> void:
	# Main panel background
	panel = PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.06, 0.06, 0.09, 0.92)
	panel_style.border_width_left = 2
	panel_style.border_width_top = 2
	panel_style.border_width_right = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = Color(0.35, 0.45, 0.7, 0.5)
	panel_style.corner_radius_top_left = 8
	panel_style.corner_radius_top_right = 8
	panel_style.corner_radius_bottom_right = 8
	panel_style.corner_radius_bottom_left = 8
	panel_style.shadow_color = Color(0, 0, 0, 0.5)
	panel_style.shadow_size = 6
	panel.add_theme_stylebox_override("panel", panel_style)
	add_child(panel)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 8)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	margin.add_child(vbox)

	# Title
	title_label = Label.new()
	title_label.text = "INVENTORY"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 11)
	title_label.add_theme_color_override("font_color", Color(0.6, 0.7, 0.9, 0.7))
	vbox.add_child(title_label)

	# Grid
	grid = GridContainer.new()
	grid.columns = COLS
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	vbox.add_child(grid)

# ──────────────────────────────────────
#  Refresh
# ──────────────────────────────────────

func _refresh() -> void:
	if grid == null:
		return

	for child in grid.get_children():
		child.queue_free()

	if inventory == null:
		return

	# Clamp selected_index
	if selected_index >= inventory.items.size() and inventory.items.size() > 0:
		selected_index = inventory.items.size() - 1
	elif inventory.items.size() == 0:
		selected_index = -1

	for i in inventory.items.size():
		var slot := _create_slot(inventory.items[i], i)
		grid.add_child(slot)

	# Fill remaining empty slots
	var empty_count := inventory.MAX_SLOTS - inventory.items.size()
	for i in empty_count:
		var empty := _create_empty_slot(inventory.items.size() + i)
		grid.add_child(empty)

# ──────────────────────────────────────
#  Slot creation
# ──────────────────────────────────────

func _create_slot(item: Dictionary, index: int) -> PanelContainer:
	var slot := PanelContainer.new()
	slot.custom_minimum_size = Vector2(SLOT_SIZE, SLOT_SIZE)

	var is_selected := (index == selected_index)

	# Slot style — dark inner with subtle color tint based on type
	var style := StyleBoxFlat.new()
	var base_color := _get_slot_color(item.get("type", "misc"))
	style.bg_color = base_color
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	if is_selected:
		style.border_color = Color(0.95, 0.85, 0.3, 1.0)  # Gold selection
		style.bg_color = base_color.lightened(0.1)
	else:
		style.border_color = Color(0.3, 0.3, 0.4, 0.5)
	slot.add_theme_stylebox_override("panel", style)

	# Content layout
	var content := VBoxContainer.new()
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 1)
	slot.add_child(content)

	# Icon
	if item.get("icon") != null:
		var tex := TextureRect.new()
		tex.texture = item["icon"]
		tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex.custom_minimum_size = Vector2(40, 40)
		tex.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		tex.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		content.add_child(tex)
	else:
		var icon_lbl := Label.new()
		icon_lbl.text = _get_item_icon(item.get("type", "misc"))
		icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		icon_lbl.add_theme_font_size_override("font_size", 24)
		icon_lbl.add_theme_color_override("font_color", Color(1, 1, 1, 0.8))
		content.add_child(icon_lbl)

	# Item name (truncated)
	var name_lbl := Label.new()
	var display_name: String = item["name"]
	if display_name.length() > 8:
		display_name = display_name.substr(0, 7) + "."
	name_lbl.text = display_name
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 9)
	name_lbl.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85, 0.9))
	content.add_child(name_lbl)

	# Quantity
	if item.get("quantity", 1) > 1:
		var qty := Label.new()
		qty.text = "x" + str(item["quantity"])
		qty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		qty.add_theme_font_size_override("font_size", 9)
		qty.add_theme_color_override("font_color", Color(0.6, 0.8, 1.0, 0.8))
		content.add_child(qty)

	# Clickable overlay
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
	slot.custom_minimum_size = Vector2(SLOT_SIZE, SLOT_SIZE)

	var is_selected := (index == selected_index)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.13, 0.6)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	if is_selected:
		style.border_color = Color(0.95, 0.85, 0.3, 0.7)
		style.border_width_left = 2
		style.border_width_top = 2
		style.border_width_right = 2
		style.border_width_bottom = 2
	else:
		style.border_color = Color(1, 1, 1, 0.06)
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
		"heal":
			return Color(0.12, 0.22, 0.14, 0.85)
		"healing":
			return Color(0.12, 0.22, 0.14, 0.85)
		"key":
			return Color(0.25, 0.22, 0.1, 0.85)
		"weapon":
			return Color(0.25, 0.1, 0.1, 0.85)
		_:
			return Color(0.13, 0.13, 0.17, 0.85)


func _get_item_icon(type: String) -> String:
	match type:
		"healing", "heal":
			return "+"
		"key":
			return "*"
		"weapon":
			return "!"
		_:
			return "?"
