extends CanvasLayer

## Minecraft-style container UI for cabinets, chests, etc.
## Grid slots on top for container contents, grid slots on bottom for player inventory.
## Click a container slot to take one item into your inventory.

signal closed

const SLOT_SIZE := Vector2(52, 52)
const SLOT_GAP := 2
const COLS := 9

var cabinet_items: Array[Dictionary] = []
var player_inventory: Inventory = null
var _player_ref: Node = null

var bg_dim: ColorRect
var main_panel: PanelContainer
var cabinet_grid: GridContainer
var player_grid: GridContainer
var title_label: Label

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100
	_build_ui()
	_refresh()

func setup(items: Array[Dictionary], inventory: Inventory, player: Node) -> void:
	cabinet_items = items
	player_inventory = inventory
	_player_ref = player
	if player_inventory:
		player_inventory.inventory_changed.connect(_refresh)
	_refresh()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") or event.is_action_pressed("pause"):
		_close()
		get_viewport().set_input_as_handled()

func _close() -> void:
	if player_inventory and player_inventory.inventory_changed.is_connected(_refresh):
		player_inventory.inventory_changed.disconnect(_refresh)
	closed.emit()
	queue_free()

# ──────────────────────────────────────
#  Build Minecraft-style UI
# ──────────────────────────────────────

func _build_ui() -> void:
	# Dim overlay
	bg_dim = ColorRect.new()
	bg_dim.anchors_preset = Control.PRESET_FULL_RECT
	bg_dim.anchor_right = 1.0
	bg_dim.anchor_bottom = 1.0
	bg_dim.color = Color(0, 0, 0, 0.6)
	bg_dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(bg_dim)

	# Center everything
	var center := CenterContainer.new()
	center.anchors_preset = Control.PRESET_FULL_RECT
	center.anchor_right = 1.0
	center.anchor_bottom = 1.0
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	# ── Main panel (Minecraft gray) ──
	main_panel = PanelContainer.new()
	var ps := StyleBoxFlat.new()
	ps.bg_color = Color(0.76, 0.76, 0.76, 1.0)  # Classic MC gray
	# 3D bevel: white top-left, dark bottom-right
	ps.border_width_top = 3
	ps.border_width_left = 3
	ps.border_width_bottom = 3
	ps.border_width_right = 3
	ps.border_color = Color(0.22, 0.22, 0.22, 1.0)
	ps.corner_radius_top_left = 0
	ps.corner_radius_top_right = 0
	ps.corner_radius_bottom_right = 0
	ps.corner_radius_bottom_left = 0
	main_panel.add_theme_stylebox_override("panel", ps)
	center.add_child(main_panel)

	# White highlight edges (top & left bevel)
	var highlight_top := ColorRect.new()
	highlight_top.custom_minimum_size = Vector2(0, 3)
	highlight_top.color = Color(1, 1, 1, 0.55)
	highlight_top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	highlight_top.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	highlight_top.anchor_bottom = 0.0
	highlight_top.offset_bottom = 3
	main_panel.add_child(highlight_top)

	var highlight_left := ColorRect.new()
	highlight_left.custom_minimum_size = Vector2(3, 0)
	highlight_left.color = Color(1, 1, 1, 0.55)
	highlight_left.mouse_filter = Control.MOUSE_FILTER_IGNORE
	highlight_left.set_anchors_and_offsets_preset(Control.PRESET_LEFT_WIDE)
	highlight_left.anchor_right = 0.0
	highlight_left.offset_right = 3
	main_panel.add_child(highlight_left)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	main_panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	margin.add_child(vbox)

	# ── Container title ──
	title_label = Label.new()
	title_label.text = "Cabinet"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title_label.add_theme_font_size_override("font_size", 14)
	title_label.add_theme_color_override("font_color", Color(0.25, 0.25, 0.25, 1.0))
	vbox.add_child(title_label)

	# ── Container slots (3 rows) ──
	cabinet_grid = GridContainer.new()
	cabinet_grid.columns = COLS
	cabinet_grid.add_theme_constant_override("h_separation", SLOT_GAP)
	cabinet_grid.add_theme_constant_override("v_separation", SLOT_GAP)
	vbox.add_child(cabinet_grid)

	# ── Separator ──
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 8)
	vbox.add_child(spacer)

	# ── "Inventory" label ──
	var inv_label := Label.new()
	inv_label.text = "Inventory"
	inv_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	inv_label.add_theme_font_size_override("font_size", 14)
	inv_label.add_theme_color_override("font_color", Color(0.25, 0.25, 0.25, 1.0))
	vbox.add_child(inv_label)

	# ── Player inventory slots (3 rows) ──
	player_grid = GridContainer.new()
	player_grid.columns = COLS
	player_grid.add_theme_constant_override("h_separation", SLOT_GAP)
	player_grid.add_theme_constant_override("v_separation", SLOT_GAP)
	vbox.add_child(player_grid)

	# ── Hotbar separator ──
	var hotbar_spacer := Control.new()
	hotbar_spacer.custom_minimum_size = Vector2(0, 4)
	vbox.add_child(hotbar_spacer)

	# ── Close hint ──
	var hint := Label.new()
	hint.text = "Press E or ESC to close"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 11)
	hint.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4, 1.0))
	vbox.add_child(hint)


# ──────────────────────────────────────
#  Refresh
# ──────────────────────────────────────

func _refresh() -> void:
	if not is_inside_tree():
		return
	_refresh_grid(cabinet_grid, cabinet_items, true, 27)
	var inv_items: Array[Dictionary] = []
	if player_inventory:
		inv_items = player_inventory.items
	_refresh_grid(player_grid, inv_items, false, 27)


func _refresh_grid(grid: GridContainer, items: Array[Dictionary], clickable: bool, total_slots: int) -> void:
	for child in grid.get_children():
		child.queue_free()

	for i in total_slots:
		if i < items.size():
			var slot := _create_item_slot(items[i], clickable, i)
			grid.add_child(slot)
		else:
			grid.add_child(_create_empty_slot())


# ──────────────────────────────────────
#  Slot creation (Minecraft style)
# ──────────────────────────────────────

func _create_item_slot(item: Dictionary, clickable: bool, index: int) -> PanelContainer:
	var slot := PanelContainer.new()
	slot.custom_minimum_size = SLOT_SIZE
	slot.add_theme_stylebox_override("panel", _mc_slot_style())

	var center := CenterContainer.new()
	slot.add_child(center)

	# Icon
	if item.get("icon") != null:
		var tex := TextureRect.new()
		tex.texture = item["icon"]
		tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex.custom_minimum_size = Vector2(36, 36)
		center.add_child(tex)

		# Quantity in bottom-right
		if item.get("quantity", 1) > 1:
			var qty := Label.new()
			qty.text = str(item["quantity"])
			qty.add_theme_font_size_override("font_size", 13)
			qty.add_theme_color_override("font_color", Color(1, 1, 1, 1.0))
			qty.add_theme_color_override("font_shadow_color", Color(0.15, 0.15, 0.15, 1.0))
			qty.add_theme_constant_override("shadow_offset_x", 1)
			qty.add_theme_constant_override("shadow_offset_y", 1)
			qty.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			qty.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
			qty.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			slot.add_child(qty)
	else:
		var lbl := Label.new()
		lbl.text = item.get("name", "?").substr(0, 3)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 14)
		lbl.add_theme_color_override("font_color", Color(1, 1, 1, 0.85))
		center.add_child(lbl)

	# Click overlay
	if clickable:
		var btn := Button.new()
		btn.flat = true
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn.anchors_preset = Control.PRESET_FULL_RECT
		btn.tooltip_text = item.get("name", "") + "\n" + item.get("description", "")
		btn.pressed.connect(func(): _take_from_cabinet(index))
		slot.add_child(btn)

	return slot


func _create_empty_slot() -> PanelContainer:
	var slot := PanelContainer.new()
	slot.custom_minimum_size = SLOT_SIZE
	slot.add_theme_stylebox_override("panel", _mc_slot_style())
	return slot


func _mc_slot_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.545, 0.545, 0.545, 1.0)  # MC slot gray
	# Inset bevel: dark top-left, light bottom-right (opposite of panel)
	s.border_width_top = 2
	s.border_width_left = 2
	s.border_width_bottom = 2
	s.border_width_right = 2
	s.border_color = Color(0.33, 0.33, 0.33, 1.0)
	return s


# ──────────────────────────────────────
#  Actions
# ──────────────────────────────────────

func _take_from_cabinet(index: int) -> void:
	if index < 0 or index >= cabinet_items.size():
		return
	if player_inventory == null:
		return

	var item = cabinet_items[index]
	var success = player_inventory.add_item(
		item.get("name", "Unknown"),
		1,
		item.get("description", ""),
		item.get("type", "misc"),
		item.get("icon")
	)

	if success:
		item["quantity"] -= 1
		if item["quantity"] <= 0:
			cabinet_items.remove_at(index)
		_refresh()
