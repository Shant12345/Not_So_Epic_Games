extends CharacterBody2D

@export var point_a: Vector2 = Vector2(173, 339)
@export var point_b: Vector2 = Vector2(986, 338)
@export var move_time: float = 1.2
@export var pause_at_end: float = 0.25

var going_to_b := true

func _ready():
	if has_node("PointA") and has_node("PointB"):
		point_a = $PointA.global_position
		point_b = $PointB.global_position
	position = point_a
	move_to_next_point()

func move_to_next_point():
	var target = point_b if going_to_b else point_a
	var tw = create_tween()
	tw.tween_property(self, "position", target, move_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tw.finished.connect(_on_tween_finished)

func _on_tween_finished():
	going_to_b = !going_to_b
	move_to_next_point()
