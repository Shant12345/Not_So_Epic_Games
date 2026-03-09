extends CharacterBody2D

@export var max_speed := 1400.0
@export var sprint_speed := 2200.0
@export var acceleration := 3500.0
@export var deceleration := 3500.0
@export var max_stamina := 100.0
@export var stamina_consumption := 20.0 
@export var stamina_recovery := 15.0

var health := 30
var stamina := 100.0
var is_sprint_exhausted := false
var inventory: Inventory = null

func _ready() -> void:
	var hitbox = get_node_or_null("Hitbox")
	if hitbox:
		hitbox.area_entered.connect(_on_area_entered)
	
	set_health(health)
	
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	
	safe_margin = 0.05
	
	
	inventory = Inventory.new()
	add_child(inventory)
	inventory.item_used.connect(_on_item_used)
	
	var inv_ui = get_node_or_null("CanvasLayer/InventoryUI")
	if inv_ui:
		inv_ui.setup(inventory)

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_down", "move_up")
	var has_input_direction := direction.length() > 0.0
	
	var is_sprinting := Input.is_action_pressed("sprint") and has_input_direction and not is_sprint_exhausted
	
	if is_sprinting:
		stamina -= stamina_consumption * delta
		if stamina <= 0:
			stamina = 0
			is_sprint_exhausted = true
	else:
		stamina += stamina_recovery * delta
		if stamina >= 20: 
			is_sprint_exhausted = false
	
	stamina = clamp(stamina, 0, max_stamina)
	set_stamina(stamina)
	
	var current_max_speed: float = sprint_speed if is_sprinting else max_speed
	var target_velocity: Vector2 = direction * current_max_speed
	
	if has_input_direction:
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
		
	move_and_slide()

func set_health(new_health: int) -> void:
	health = clamp(new_health, 0, 100)
	var health_bar = get_node_or_null("CanvasLayer/UI/HealthBar")
	if health_bar:
		var tween = create_tween()
		tween.tween_property(health_bar, "value", health, 0.3).set_trans(Tween.TRANS_SINE)
		
		var hp_number = health_bar.get_node_or_null("HPLabel")
		if hp_number:
			hp_number.text = str(health) + " / 100"
		
		
		var style_box = health_bar.get_theme_stylebox("fill").duplicate()
		if health > 50:
			style_box.bg_color = Color(0, 0.8, 0.4) 
		elif health > 25:
			style_box.bg_color = Color(0.803, 0.691, 0.041, 1.0) 
		else:
			style_box.bg_color = Color(0.8, 0.1, 0.1) 
		health_bar.add_theme_stylebox_override("fill", style_box)
	
	if health <= 0:
		get_tree().reload_current_scene()

func take_damage(amount: int) -> void:
	set_health(health - amount)

func set_stamina(new_stamina: float) -> void:
	stamina = new_stamina
	var stamina_bar = get_node_or_null("CanvasLayer/UI/SprintBar")
	if stamina_bar:
		stamina_bar.value = stamina

func _on_area_entered(area_that_entered: Area2D) -> void:
	if area_that_entered.name.begins_with("HealthPack") or area_that_entered.is_in_group("HealthPack"):
		if inventory:
			inventory.add_item("Health Pack", 1, "Restores 10 HP", "healing")
		else:
			set_health(health + 10)


func _on_item_used(item_name: String) -> void:
	match item_name:
		"Health Pack":
			set_health(health + 10)

func get_global_player_position() -> Vector2:
	return global_position
