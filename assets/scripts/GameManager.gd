extends Node2D

var play_area
var player
var drag_indicator
var trail

var time_in_slowmo = 0.0
var slowmo_scale = 0.2
var length_of_slowmo = 1

var level_transitioning = false
var max_scroll_speed = 150
var current_vertical_offset = 0
var screen_height

var invert_controls = false

signal score_change

var current_level = 1
var EnemyDirectorTemplate = load("res://assets/scripts/EnemyDirector.gd")
var enemy_director

var pathfinding_counter = 0
var pathfinding_threhsold = 20

var audio_manager

func _ready():
	# Initialise the button callbacks
	var menu_button = get_node("HUD/Overlay/OverlayColumns/MenuButtonBackground/MenuButton")
	var _discard = menu_button.connect("button_down", self, "menu_button_press")
	var continue_button = get_node("HUD/PauseMenu/Continue")
	_discard = continue_button.connect("button_up", self, "continue_button_press")
	var restart_button = get_node("HUD/PauseMenu/Restart")
	_discard = restart_button.connect("button_up", self, "restart_button_press")
	var quit_button = get_node("HUD/PauseMenu/QuitToMenu")
	_discard = quit_button.connect("button_up", self, "quit_button_press")
	var invert_toggle = get_node("HUD/PauseMenu/Invert")
	_discard = invert_toggle.connect("toggled", self, "invert_toggle_callback")
	var restart_button_death = get_node("HUD/DeathMenu/Restart")
	_discard = restart_button_death.connect("button_up", self, "restart_button_press")
	var share_button_death = get_node("HUD/DeathMenu/TwitterShare")
	_discard = share_button_death.connect("button_up", self, "share_button_press")
	var quit_button_death = get_node("HUD/DeathMenu/QuitToMenu")
	_discard = quit_button_death.connect("button_up", self, "quit_button_press")
	# Everything else
	audio_manager = get_tree().get_root().get_node("SceneManager/AudioManager")
	screen_height = get_viewport().get_visible_rect().size.y - 40
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
	_discard = $NextLevelTrigger.connect("body_entered", self, "next_level_setup")

func _enter_tree():
	enemy_director = EnemyDirectorTemplate.new()
	add_child(enemy_director)
	initialise_level()

func _input(event):
	if not get_tree().paused:
		if event is InputEventScreenDrag and not level_transitioning:
			drag_indicator.update_line(event, player.position, invert_controls)
			trail.set_projection_point(player.position + drag_indicator.get_movement_vector())
		if event is InputEventScreenTouch and not level_transitioning:
			if event.pressed:
				drag_indicator.initialise(event.position)
				drag_indicator.show()
				trail.enable_projection(player.position + drag_indicator.get_movement_vector())
			else:
				# This if statement was needed so the code didn't trigger after a menu button was pressed
				if drag_indicator.visible:
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
	if player.health <= 0:
		display_death_screen()
	if (get_tree().get_nodes_in_group("gnat").size() == 0 and
		get_tree().get_nodes_in_group("moth").size() == 0 and
		not $HUD.get_node("GoSprite").visible):
		initialise_goto_next_level()
	var gnat_array = get_tree().get_nodes_in_group("gnat")
	if gnat_array.size() > 0 and pathfinding_counter >= pathfinding_threhsold:
		enemy_director.update_gnat_offset_positions(gnat_array)
		pathfinding_counter = 0
	pathfinding_counter += 1

func enemy_died_callback(score):
	emit_signal("score_change", score)

func initialise_slowdown(length):
	length_of_slowmo = length
	Engine.time_scale = slowmo_scale

func shape_slowdown(_shape_info):
	initialise_slowdown(0.1)

func initialise_goto_next_level():
	$HUD.get_node("GoSprite").visible = true
	$Boundaries.get_node("TopWall").set_deferred("disabled", true)

func draw_map(position=0):
	var tilemap = get_node("PlayArea/TileMap")
	var max_tilemap = tilemap.world_to_map(
		get_viewport().get_visible_rect().size) + Vector2(1, 1)
	var starting_tilemap_idx = tilemap.world_to_map(
		-get_node("PlayArea").position) - Vector2(0, position*max_tilemap.y)
	for x_idx in range(starting_tilemap_idx.x, starting_tilemap_idx.x+max_tilemap.x):
		for y_idx in range(starting_tilemap_idx.y, starting_tilemap_idx.y+max_tilemap.y):
			tilemap.set_cell(x_idx, y_idx, 0)

func initialise_level(next=false):
	var enemy_vector = enemy_director.get_enemy_vector(current_level)
	var enemy_position_offset = -get_node("PlayArea").position.y
	if next:
		draw_map(1)
		enemy_position_offset -= screen_height
	else:
		draw_map(0)
	for enemy in enemy_vector:
		enemy.position += Vector2(0, enemy_position_offset)
		get_node("PlayArea/EnemiesNode").call_deferred("add_child", enemy)

func next_level_setup(body):
	if body.is_in_group("player"):
		current_level += 1
		initialise_level(true)
		$HUD.get_node("GoSprite").visible = false
		pause_mode = PAUSE_MODE_PROCESS
		$PlayArea.pause_mode = PAUSE_MODE_STOP
		get_tree().paused = true
		level_transitioning = true
		player.current_target = player.position
		trail.point_list = PoolVector2Array([])

func level_transition_finish():
	level_transitioning = false
	$Boundaries.get_node("TopWall").disabled = false
	current_vertical_offset = 0
	pause_mode = PAUSE_MODE_INHERIT
	$PlayArea.pause_mode = PAUSE_MODE_INHERIT
	get_tree().paused = false

func menu_button_press():
	if not get_node("HUD/DeathMenu").visible and not level_transitioning:
		if get_node("HUD/PauseMenu").visible:
			continue_button_press()
		else:
			audio_manager.play_sound("button_press")
			pause_mode = PAUSE_MODE_PROCESS
			$PlayArea.pause_mode = PAUSE_MODE_STOP
			get_tree().paused = true
			get_node("HUD/PauseMenu").visible = true
	
func display_death_screen():
	pause_mode = PAUSE_MODE_PROCESS
	$PlayArea.pause_mode = PAUSE_MODE_STOP
	get_tree().paused = true
	get_node("HUD/DeathMenu").visible = true
	
func continue_button_press():
	audio_manager.play_sound("button_press")
	pause_mode = PAUSE_MODE_INHERIT
	$PlayArea.pause_mode = PAUSE_MODE_INHERIT
	get_tree().paused = false
	get_node("HUD/PauseMenu").visible = false
	
func restart_button_press():
	audio_manager.play_sound("button_press")
	pause_mode = PAUSE_MODE_INHERIT
	$PlayArea.pause_mode = PAUSE_MODE_INHERIT
	get_tree().paused = false
	get_tree().get_root().get_node("SceneManager").start_new_game()
	
func quit_button_press():
	audio_manager.play_sound("button_press")
	pause_mode = PAUSE_MODE_INHERIT
	$PlayArea.pause_mode = PAUSE_MODE_INHERIT
	get_tree().paused = false
	get_tree().get_root().get_node("SceneManager").start_menu()

func invert_toggle_callback(pressed):
	audio_manager.play_sound("button_press")
	invert_controls = pressed

func share_button_press():
	audio_manager.play_sound("button_press")
	var score = get_node("HUD/Overlay").current_score_total
	var _return = OS.shell_open("http://twitter.com/share?text=I just scored " +
		str(score) + " playing Itsy Bitsy Spyder&url=" +
		"https://manicmoleman.itch.io/spyder&hashtags=GitHubGameOff,GodotEngine,Spyder")
