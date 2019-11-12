extends Sprite

var from : Vector2
var to : Vector2
var player_position : Vector2
var current_length = 0.0

var max_length = 150.0
var max_thickness = 8.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
	
func _draw():
	var new_to = to
	if current_length > max_length:
		new_to = from + (from.direction_to(to) * max_length)
	var line_thickness = min(1.0, current_length / max_length)*max_thickness
#	draw_line(from, new_to, Color.red, line_thickness)
	draw_line(player_position, player_position + (new_to - from), Color.red, line_thickness)

func initialise(point):
	from = point
	to = point

func update_line(drag_event:InputEventScreenDrag, new_player_position):
	player_position = new_player_position
	from = drag_event.position
	current_length = from.distance_to(to)
	update()

func get_length():
	return(min(max_length, current_length))

func get_movement_vector():
	return((to - from).normalized() * get_length())
	