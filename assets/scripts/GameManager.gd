extends Node2D

var play_area
var player
var drag_indicator
var trail

const EnemyTemplate = preload("res://assets/scenes/Gnat.tscn")
var max_enemy_number = 5

var time_in_slowmo = 0.0
var slowmo_scale = 0.2
var length_of_slowmo = 1

var level_transitioning = false
var max_scroll_speed = 150
var current_vertical_offset = 0
var screen_height

func _ready():
	screen_height = get_viewport().get_visible_rect().size.y
	play_area = get_node("PlayArea")
	player = play_area.get_node("Player")
	var viewport = get_viewport_rect().size
	var player_start_position = Vector2(viewport.x / 2, (viewport.y*9) / 10)
	player.teleport(player_start_position)
	trail = play_area.get_node("Trail")
	trail.add_point(player.position)
	trail.set_player_point(player.position)
	trail.connect("shape_completed", self, "shape_slowdown")
	drag_indicator = play_area.get_node("DragIndicator")
	$NextLevelTrigger.connect("body_entered", self, "next_level_setup")
#	var _discard = $Timer.connect("timeout", self, "spawn_enemy")
#DEBUG
	initialise_goto_next_level()

func _input(event):
	if event is InputEventScreenDrag and not level_transitioning:
		drag_indicator.update_line(event, player.position)
		trail.set_projection_point(player.position + drag_indicator.get_movement_vector())
	if event is InputEventScreenTouch and not level_transitioning:
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
	var current_time_scale = Engine.time_scale
	if round(current_time_scale - slowmo_scale) == 0:
		time_in_slowmo += delta
	if length_of_slowmo < time_in_slowmo:
		Engine.time_scale = 1
		time_in_slowmo = 0.0
	if level_transitioning:
		var amount_to_increase = max_scroll_speed * delta
		current_vertical_offset += amount_to_increase
		if current_vertical_offset <= screen_height:
			$PlayArea.position.y += amount_to_increase
		else:
			$PlayArea.position.y += amount_to_increase - (current_vertical_offset - screen_height)
			level_transition_finish()

func spawn_enemy():
	if get_tree().get_nodes_in_group("enemy").size() < max_enemy_number:
		var new_enemy = EnemyTemplate.instance()
		play_area.get_node("EnemiesNode").add_child(new_enemy)

func initialise_slowdown(length):
	length_of_slowmo = length
	Engine.time_scale = slowmo_scale

func shape_slowdown(_shape_info):
	initialise_slowdown(0.1)

func initialise_goto_next_level():
	$Boundaries.get_node("TopWall").disabled = true

func next_level_setup(body):
	if body.is_in_group("player"):
		pause_mode = PAUSE_MODE_PROCESS
		$PlayArea.pause_mode = PAUSE_MODE_STOP
		get_tree().paused = true
		level_transitioning = true
		player.current_target = player.position
		trail.point_list = PoolVector2Array([])

func level_transition_finish():
	level_transitioning = false
	current_vertical_offset = 0
	pause_mode = PAUSE_MODE_INHERIT
	$PlayArea.pause_mode = PAUSE_MODE_INHERIT
	get_tree().paused = false
