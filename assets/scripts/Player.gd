extends KinematicBody2D

# Declare member variables here. Examples:
# var a = 2
var speed = 5
var rotation_speed = 10

var current_target = Vector2(0, 0)
var current_rotation = 0
var snap_distance = 2.0
var moving = false
signal moved

var incapacitated = false
var time_incapacitated = 0.0
var incapacitated_threshold = 1.0

var drag_indicator
# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("player")
	drag_indicator = get_node("../DragIndicator")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var current_speed = speed
	if incapacitated:
		time_incapacitated += delta
		if time_incapacitated < incapacitated_threshold:
			current_speed = 0
		else:
			incapacitated = false
			time_incapacitated = 0.0
	if position.distance_to(current_target) > snap_distance:
		$AnimatedSprite.play("jumping")
		current_rotation = position.angle_to_point(current_target) + PI/2
		var _discard = move_and_slide(position.direction_to(current_target)*
			position.distance_to(current_target)*current_speed)
		emit_signal("moved", position)
		moving = true
	else:
		$AnimatedSprite.play("idle")
		position = current_target
		moving = false
	if drag_indicator.visible:
		current_rotation = drag_indicator.get_movement_vector().angle() - PI/2

func _process(delta):
	animate_rotation(delta)

func animate_rotation(delta):
	var anticlockwise_distance = $AnimatedSprite.rotation-current_rotation
	var clockwork_distance = current_rotation-$AnimatedSprite.rotation
	while clockwork_distance < 0:
		clockwork_distance += 2*PI
	while anticlockwise_distance < 0:
		anticlockwise_distance += 2*PI
	while 2*PI < clockwork_distance:
		clockwork_distance -= 2*PI
	while 2*PI < anticlockwise_distance:
		anticlockwise_distance -= 2*PI
	var rotation_direction = 1
	if anticlockwise_distance < clockwork_distance:
		rotation_direction = -1
	if min(clockwork_distance, anticlockwise_distance) > 2*PI/100:
		$AnimatedSprite.rotation += rotation_direction*min(clockwork_distance,
			anticlockwise_distance)*delta*rotation_speed
	$AnimatedSprite.rotation = fmod($AnimatedSprite.rotation, 2*PI)

func teleport(point):
	position = point
	current_target = point

func move_to(point):
	current_target = point

func register_hit():
	get_parent().get_parent().initialise_slowdown(0.1)
	incapacitate(0.1)
	print('New hit')

func incapacitate(length):
	incapacitated_threshold = length
	incapacitated = true
	time_incapacitated = 0.0
