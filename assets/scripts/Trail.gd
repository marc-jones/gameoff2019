extends StaticBody2D

var point_list = PoolVector2Array()
var max_length = 500.0

var projection_point : Vector2

var player_point : Vector2

var shrink_speed = 50.0 

var sprite : Sprite
var collision_poly : CollisionPolygon2D

var polygon_width = 2

signal shape_completed

func _ready():
	add_to_group("trail")
	sprite = get_node("TrailSprite")
	collision_poly = get_node("CollisionPolygon2D")

func get_point_list_with_player_position():
	var point_list_with_player_position = PoolVector2Array(point_list)
	point_list_with_player_position.insert(0, player_point)
	point_list_with_player_position = length_check(point_list_with_player_position)
	return(point_list_with_player_position)

func draw_visuals():
	var point_list_with_player_position = get_point_list_with_player_position()
#	if not len(point_list_with_player_position) < 2:
	sprite.set_current_line(point_list_with_player_position)
	if sprite.projecting:
		var point_list_copy = PoolVector2Array(point_list_with_player_position)
		point_list_copy.insert(0, projection_point)
		point_list_copy = length_check(point_list_copy)
		point_list_copy.remove(0)
		sprite.set_projection_line(point_list_copy)

func length_check(input_point_list):
	# Shrinks the input_point_list if the cumulative length of the line is larger than max_length
	if len(input_point_list) > 1:
		var new_point_list = PoolVector2Array([input_point_list[0]])
		var cumulative_length = 0.0
		for idx in range(1, len(input_point_list)):
			var segment_length = input_point_list[idx-1].distance_to(input_point_list[idx])
			if cumulative_length + segment_length < max_length:
				new_point_list.append(input_point_list[idx])
			elif cumulative_length < max_length:
				new_point_list.append(input_point_list[idx-1] +
					input_point_list[idx-1].direction_to(input_point_list[idx])*(max_length - cumulative_length))
			cumulative_length += segment_length
		return(new_point_list)
	return(input_point_list)

func add_point(point:Vector2):
	if not (not len(point_list) == 0 and point_list[0] == point):
		point_list.insert(0, point)
		point_list = length_check(point_list)

func set_projection_point(point:Vector2):
	projection_point = point

func enable_projection(point:Vector2):
	sprite.projecting = true
	set_projection_point(point)
	
func disable_projection():
	sprite.projecting = false

func shrink_line(delta):
	# Shrinks the point_list based on the elapsed time
	var point_list_with_player_position = get_point_list_with_player_position()
	if len(point_list_with_player_position) > 1:
		var length_to_decrease = shrink_speed * delta
		for idx in range(len(point_list_with_player_position)-1, 0, -1):
			if not length_to_decrease == 0:
				var segment_length = point_list_with_player_position[idx-1].distance_to(
					point_list_with_player_position[idx])
				if segment_length < length_to_decrease:
					if len(point_list) > 1:
						point_list.remove(idx-1)
						length_to_decrease -= segment_length
				else:
					var segment_direction = point_list_with_player_position[idx-1].direction_to(
						point_list_with_player_position[idx])
					point_list.set(idx-1, point_list_with_player_position[idx-1] +
						segment_direction*(segment_length-length_to_decrease))
					length_to_decrease = 0
	
func set_player_point(new_point:Vector2):
	var point_list_with_player_position = get_point_list_with_player_position()
	var intersection = get_line_intersection_with_point_list(player_point, new_point,
		point_list_with_player_position, 2)
	if not intersection[0] == null:
		emit_signal("shape_completed", get_killzone_polygon(intersection[1],
			point_list_with_player_position, intersection[0]))
		point_list = PoolVector2Array([])
	player_point = new_point

func get_killzone_polygon(starting_idx:int, input_point_list:PoolVector2Array, intersection:Vector2):
	var return_array = PoolVector2Array()
	for idx in range(starting_idx+1):
		return_array.append(input_point_list[idx])
	return_array.append(intersection)
	return(return_array)

func _physics_process(delta):
	shrink_line(delta)
	var point_list_with_player_position = get_point_list_with_player_position()
	if point_list_with_player_position.size() < 2:
		collision_poly.set_disabled(true)
	else:
		collision_poly.polygon = return_polygon(point_list_with_player_position)
		collision_poly.set_disabled(false)
	draw_visuals()

func return_polygon(input_point_list:PoolVector2Array):
	# Returns a polygon which surrounds the trail line
	if input_point_list.size() > 1:
		var fwd_array = PoolVector2Array()
		var rev_array = PoolVector2Array()
		for idx in range(len(input_point_list)):
			if idx == 0:
				var dir : Vector2 = input_point_list[idx].direction_to(input_point_list[idx+1])
				fwd_array.append(input_point_list[idx] + dir.rotated(-PI/2) * polygon_width)
				rev_array.append(input_point_list[idx] + dir.rotated(PI/2) * polygon_width)
			elif idx == len(input_point_list)-1:
				var dir : Vector2 = input_point_list[idx].direction_to(input_point_list[idx-1])
				fwd_array.append(input_point_list[idx] + dir.rotated(PI/2) * polygon_width)
				rev_array.append(input_point_list[idx] + dir.rotated(-PI/2) * polygon_width)
			else:
				var fwd_vector = input_point_list[idx].direction_to(input_point_list[idx+1])
				var rev_vector = input_point_list[idx].direction_to(input_point_list[idx-1])
				var dir : Vector2 = (rev_vector - fwd_vector).normalized()
				var modifier = abs(sin(fwd_vector.angle_to(rev_vector)/2))
				# Feels a bit hacky, but seems to work okay
				if modifier < 0.01:
					modifier = 1
				fwd_array.append(input_point_list[idx] + dir.rotated(PI/2) * (polygon_width / modifier))
				rev_array.append(input_point_list[idx] + dir.rotated(-PI/2) * (polygon_width / modifier))
		rev_array.invert()
		fwd_array.append_array(rev_array)
		return(fwd_array)
	else:
		return(PoolVector2Array([]))

# MANUAL INTERSECTION
func get_line_intersection_with_point_list(from:Vector2, to:Vector2, test_point_list, starting_idx=0):
	for idx in range(starting_idx, len(test_point_list)-1):
		var intersection = get_line_intersection(test_point_list[idx], test_point_list[idx+1], from, to)
		if not intersection == null:
			return([intersection, idx])
	return([null, null])

func get_line_intersection(from1:Vector2, to1:Vector2, from2:Vector2, to2:Vector2):
	#https://stackoverflow.com/questions/563198/how-do-you-detect-where-two-line-segments-intersect
	var relative_to1 = to1 - from1
	var relative_to2 = to2 - from2
	var r_cross_s = relative_to1.cross(relative_to2)
	var q_minus_p = from2 - from1
	if r_cross_s == 0:
		return(null)
	var t = q_minus_p.cross(relative_to2) / r_cross_s
	var u = q_minus_p.cross(relative_to1) / r_cross_s
	if 0 <= t and t <= 1 and 0 <= u and u <= 1:
		return(from1 + t*relative_to1)
