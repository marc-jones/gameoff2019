extends Path2D

var radius = 60
var starting_thickness = 5.0
var max_length = 400

var sampling_rate = 0.05

func _ready():
	var center = get_viewport().get_size() / 2
	curve.add_point(Vector2(center.x, center.y-radius))
	curve.add_point(Vector2(center.x+radius, center.y))
	curve.add_point(Vector2(center.x, center.y+radius))
	curve.add_point(Vector2(center.x-radius, center.y))
	curve.add_point(Vector2(center.x, center.y-radius))
	update()

func _draw():
	var thickness = starting_thickness * pow(max_length / curve.get_baked_length(), 2)
	draw_polyline(curve.get_baked_points(), Color.black, thickness)

func linear_extrapolation(from_point, to_point, distance):
	var direction : Vector2 = to_point - from_point
	return(to_point + direction.normalized()*distance)

func insert_new_point(new_point, old_point):
	var start_fofs = 0.0
	var distance_array = []
	while start_fofs < curve.get_point_count():
		distance_array.append(curve.interpolatef(start_fofs).distance_to(old_point))
		start_fofs += sampling_rate
	var point_after_index = ceil(distance_array.find(distance_array.min())*sampling_rate)
	curve.add_point(new_point, Vector2(0,0), Vector2(0,0), point_after_index)

func smooth_curve():
	for idx in range(0, curve.get_point_count()):
		var prev_idx = idx-1
		var next_idx = idx+1
		if idx == 0 or idx == curve.get_point_count()-1:
			prev_idx = curve.get_point_count()-2
			next_idx = 1
		var idx_vec = curve.get_point_position(idx)
		var prev_vec = curve.get_point_position(prev_idx) - idx_vec
		var next_vec = curve.get_point_position(next_idx) - idx_vec
		var prev_len = prev_vec.length()
		var next_len = next_vec.length()
		var dir_vec = ((prev_len / next_len) * next_vec - prev_vec).normalized()
		curve.set_point_in(idx, -dir_vec*(prev_len/3))
		curve.set_point_out(idx, dir_vec*(next_len/3))

func update():
	smooth_curve()
	.update()
