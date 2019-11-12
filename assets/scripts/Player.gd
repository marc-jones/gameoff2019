extends Sprite

# Declare member variables here. Examples:
# var a = 2
var speed = 5

var current_target = Vector2(0, 0)

var snap_distance = 1.0

var moving = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if position.distance_to(current_target) > snap_distance:
		position += position.direction_to(current_target)*position.distance_to(current_target)*delta*speed
		moving = true
	else:
		position = current_target
		moving = false

func teleport(point):
	position = point
	current_target = point

func move_to(point):
	current_target = point
