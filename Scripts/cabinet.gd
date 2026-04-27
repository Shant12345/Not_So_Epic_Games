extends StaticBody2D

@export var is_open: bool = false
@export var loot_table: Array[PackedScene] = []

var player_in_range: bool = false
var has_generated_loot: bool = false
var cabinet_items: Array[Dictionary] = []
var _player_ref: Node = null
var _ui_instance: Node = null

@onready var sprite: Sprite2D = $Sprite2D
@onready var interact_label: Label = $InteractLabel

# Loot generation config
const MIN_ITEMS := 1
const MAX_ITEMS := 4

func _ready() -> void:
	# Default loot if none provided
	if loot_table.is_empty():
		loot_table.append(load("res://tscn/Hot_Doggy_Style.tscn"))
		loot_table.append(load("res://tscn/SchoolMilk.tscn"))
		loot_table.append(load("res://tscn/key.tscn"))
	
	_update_visuals()
	if interact_label:
		interact_label.hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and player_in_range:
		if _ui_instance != null:
			# UI is open, let the UI handle closing itself
			return
		if not is_open:
			open_cabinet()
		else:
			close_cabinet()
		get_viewport().set_input_as_handled()

func open_cabinet() -> void:
	is_open = true
	_update_visuals()
	
	if not has_generated_loot:
		_generate_loot()
	
	_show_ui()
	
	if interact_label:
		interact_label.hide()

func close_cabinet() -> void:
	is_open = false
	_update_visuals()
	
	if _ui_instance:
		_ui_instance.queue_free()
		_ui_instance = null
	
	if interact_label and player_in_range:
		interact_label.text = "Press E to Open"
		interact_label.show()

func _generate_loot() -> void:
	has_generated_loot = true
	if loot_table.is_empty():
		return
	
	# Generate 1-4 random items
	var item_count = randi_range(MIN_ITEMS, MAX_ITEMS)
	
	for i in item_count:
		var random_index = randi() % loot_table.size()
		var item_scene = loot_table[random_index]
		if item_scene == null:
			continue
		
		# Temporarily instantiate to read item data, then free it
		var temp_item = item_scene.instantiate()
		var item_data := {
			"name": temp_item.get("item_name") if temp_item.get("item_name") else "Unknown",
			"description": temp_item.get("item_description") if temp_item.get("item_description") else "",
			"type": temp_item.get("item_type") if temp_item.get("item_type") else "misc",
			"icon": temp_item.get("item_icon") if temp_item.get("item_icon") else null,
			"quantity": 1
		}
		temp_item.queue_free()
		
		# Stack if same item already exists
		var stacked := false
		for existing in cabinet_items:
			if existing["name"] == item_data["name"]:
				existing["quantity"] += 1
				stacked = true
				break
		if not stacked:
			cabinet_items.append(item_data)

func _show_ui() -> void:
	if _ui_instance != null:
		return
	
	# Find the player to get their inventory
	var player = _player_ref
	if player == null:
		player = get_tree().get_first_node_in_group("Player")
	if player == null:
		return
	
	var inventory = player.get("inventory") if player else null
	if inventory == null:
		return
	
	# Create the UI
	var ui_script = load("res://Scripts/cabinet_ui.gd")
	_ui_instance = CanvasLayer.new()
	_ui_instance.set_script(ui_script)
	
	# Add to the scene tree first so _ready runs
	get_tree().root.add_child(_ui_instance)
	
	# Then set up data
	_ui_instance.setup(cabinet_items, inventory, player)
	_ui_instance.closed.connect(_on_ui_closed)

func _on_ui_closed() -> void:
	is_open = false
	_update_visuals()
	_ui_instance = null
	
	if interact_label and player_in_range:
		interact_label.text = "Press E to Open"
		interact_label.show()

func _update_visuals() -> void:
	if sprite == null:
		return
	if is_open:
		sprite.frame = 1
	else:
		sprite.frame = 0

func _on_interact_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") or body.name == "Player":
		player_in_range = true
		_player_ref = body
		if interact_label and _ui_instance == null:
			interact_label.text = "Press E to Open" if not is_open else "Press E to Close"
			interact_label.show()

func _on_interact_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player") or body.name == "Player":
		player_in_range = false
		_player_ref = null
		if interact_label:
			interact_label.hide()
		# Auto-close if player walks away
		if is_open and _ui_instance:
			close_cabinet()
