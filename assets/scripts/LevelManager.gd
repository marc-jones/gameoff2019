extends Node2D

var player
var drag_indicator
var trail

var max_displacement = 50.0

func _ready():
	player = get_node("Player")
	var viewport = get_viewport_rect().size
	var player_start_position = Vector2(viewport.x / 2, (viewport.y*9) / 10)
	player.teleport(player_start_position)
	trail = get_node("Trail")
	trail.add_point(player.position)
	trail.set_player_point(player.position)
	drag_indicator = get_node("DragIndicator")

func _input(event):
	if event is InputEventScreenDrag:
		drag_indicator.update_line(event, player.position)
		trail.set_projection_point(player.position + drag_indicator.get_movement_vector())
	if event is InputEventScreenTouch:
		if event.pressed:
			drag_indicator.initialise(event.position)
			drag_indicator.show()
			trail.enable_projection(player.position + drag_indicator.get_movement_vector())
		else:
			var new_position = player.position + drag_indicator.get_movement_vector()
			trail.add_point(player.position)
			player.move_to(new_position)
			drag_indicator.hide()
			trail.disable_projection()

func _process(delta):
	if player.moving:
		trail.set_player_point(player.position)
