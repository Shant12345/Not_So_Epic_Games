extends CharacterBody2D

@export var point_a: Vector2 = Vector2(173, 339)
@export var point_b: Vector2 = Vector2(986, 338)
@export var move_time: float = 2.2
@export var pause_at_end: float = 0.25
var health := 70

var going_to_b := true

func _ready():
	if has_node("PointA") and has_node("PointB"):
		point_a = $PointA.global_position
		point_b = $PointB.global_position
	position = point_a
	
	var hit_box = get_node_or_null("HitBox")
	if hit_box:
		hit_box.body_entered.connect(_on_hit_box_body_entered)
		
	move_to_next_point()

func move_to_next_point():
	var target = point_b if going_to_b else point_a
	var tw = create_tween()
	tw.tween_property(self, "position", target, move_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tw.finished.connect(_on_tween_finished)

func _on_tween_finished():
	going_to_b = !going_to_b
	move_to_next_point()
	
	

func set_health(new_health: int) -> void:
	health = new_health
	var health_bar = get_node_or_null("UI/HealthBar")
	if health_bar:
		health_bar.value = health
		
func _on_hit_box_body_entered(body: Node2D):
	if body.name == "Player":
		set_health(health - 10)
	
