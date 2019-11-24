extends Sprite

var current_point_list : PoolVector2Array
var current_colour = Color("#f9f9f9")
var current_width = 4

var projecting = false
var projection_point_list : PoolVector2Array
var projection_colour = Color("#656664")
var projection_width = 5

func _ready():
	pass # Replace with function body.

func _draw():
	if current_point_list.size() < 2:
		set_visible(false)
	else:
		draw_polyline(current_point_list, current_colour, current_width)
		if projecting:
			draw_polyline(projection_point_list, projection_colour, projection_width)

func set_current_line(new_point_list):
	if new_point_list.size() > 1:
		set_visible(true)
	current_point_list = new_point_list
	update()

func set_projection_line(new_point_list):
	projection_point_list = new_point_list
	update()
