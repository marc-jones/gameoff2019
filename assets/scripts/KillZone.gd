extends Area2D

var collision_poly : CollisionPolygon2D
var physics_frame_kill_zone_active = 0
var kill_zone_active_cutoff = 2

func _ready():
	var _discard = get_parent().get_node("Trail").connect("shape_completed", self, "shape_completed_callback")
	var _return_val = connect("body_entered", self, "body_entered_callback")
	collision_poly = get_node("CollisionPolygon2D")

func shape_completed_callback(input_point_array:PoolVector2Array):
	set_monitoring(true)
	collision_poly.polygon = input_point_array
	$Sprite.set_current_polygon(input_point_array)

func body_entered_callback(_body):
	set_deferred("monitoring", false)

func _physics_process(_delta):
	if monitoring:
		if physics_frame_kill_zone_active <= kill_zone_active_cutoff:
			physics_frame_kill_zone_active += 1
		else:
			physics_frame_kill_zone_active = 0
			set_monitoring(false)
