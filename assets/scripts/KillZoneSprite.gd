extends Sprite

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var current_point_list : PoolVector2Array
var current_midpoint : Vector2

var fade_speed = 5

var current_scale = 1
var scale_speed = 1

func _ready():
	modulate.a = 0
	current_point_list = PoolVector2Array([])

func _draw():
	draw_colored_polygon(expand_point_list(current_point_list, current_scale), Color.white)

func set_current_polygon(new_point_list):
	current_point_list = new_point_list
	update_midpoint()
	modulate.a = 1
	current_scale = 1
	update()

func update_midpoint():
	var return_vector = Vector2(0, 0)
	for point in current_point_list:
		return_vector += point
	return_vector /= current_point_list.size()
	current_midpoint = return_vector

func expand_point_list(input_point_list, expand_scale):
	var return_vector = PoolVector2Array([])
	for point in input_point_list:
		return_vector.append(current_midpoint + (point - current_midpoint) * expand_scale)
	return(return_vector)

func _process(delta):
	if 0 < modulate.a:
		modulate.a -= fade_speed*delta*modulate.a
		current_scale += scale_speed*delta*current_scale
		update()
