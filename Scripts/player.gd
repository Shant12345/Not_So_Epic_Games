extends CharacterBody2D

@export var max_speed := 1400.0
@export var sprint_speed := 1700.0
@export var acceleration := 2500.0
@export var deceleration := 2500.0
@export var max_stamina := 100.0
@export var stamina_consumption := 20.0 
@export var stamina_recovery := 15.0

var health := 30
var stamina := 100.0
var is_sprint_exhausted := false
var inventory: Inventory = null
var danger_overlay: ColorRect = null
var danger_flash_intensity := 0.0
var ghost_visible := false

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
	
	_setup_danger_overlay()
	
	



func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
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
	_update_danger_flash(delta)

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

func _setup_danger_overlay() -> void:
	danger_overlay = ColorRect.new()
	danger_overlay.name = "DangerOverlay"
	danger_overlay.anchors_preset = Control.PRESET_FULL_RECT
	danger_overlay.anchor_right = 1.0
	danger_overlay.anchor_bottom = 1.0
	danger_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var mat = ShaderMaterial.new()
	mat.shader = load("res://Scripts/danger_vignette.gdshader")
	danger_overlay.material = mat
	
	var ui = get_node_or_null("CanvasLayer/UI")
	if ui:
		ui.add_child(danger_overlay)
		ui.move_child(danger_overlay, 0)

func _is_ghost_on_screen() -> bool:
	var camera = get_node_or_null("Camera2D")
	if not camera:
		return false
	
	var viewport_size = get_viewport_rect().size
	var zoom = camera.zoom
	var visible_size = viewport_size / zoom
	var camera_center = camera.global_position
	var view_rect = Rect2(camera_center - visible_size / 2.0, visible_size)
	
	var ghosts = get_tree().get_nodes_in_group("GhostEnemy")
	for ghost in ghosts:
		if is_instance_valid(ghost) and view_rect.has_point(ghost.global_position):
			return true
	return false

func _update_danger_flash(delta: float) -> void:
	if not danger_overlay or not danger_overlay.material:
		return
	
	ghost_visible = _is_ghost_on_screen()
	
	if ghost_visible:
		danger_flash_intensity = move_toward(danger_flash_intensity, 0.5, delta * 1.0)
	else:
		danger_flash_intensity = move_toward(danger_flash_intensity, 0.0, delta * 1.0)
	
	if danger_flash_intensity > 0.0:
		var pulse = (sin(Time.get_ticks_msec() / 200.0) + 1.0) / 2.0
		# Wider range and sharper curve for a "flashing" feel
		var flash_value = pow(pulse, 1.8)
		var intensity = danger_flash_intensity * lerpf(0.0, 2.2, flash_value)
		danger_overlay.material.set_shader_parameter("intensity", intensity)
	else:
		danger_overlay.material.set_shader_parameter("intensity", 0.0)
