extends Node2D

var tween_positions
var distance_to_move = 10
var time_to_move = 0.5

# Called when the node enters the scene tree for the first time.
func _ready():
	tween_positions = [$Hand.get_position(),
		$Hand.get_position() - Vector2(0,distance_to_move)]
	start_tween()

func _enter_tree():
	$Tween.connect("tween_completed", self, "on_tween_completed")

func start_tween():
	var tween = get_node("Tween")
	tween.interpolate_property($Hand, "position",
		tween_positions[0], tween_positions[1], time_to_move,
		Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.start()

func on_tween_completed(object, key):
	tween_positions.invert()
	start_tween()
