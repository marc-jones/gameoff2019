extends "res://assets/scripts/Enemy.gd"

var player_in_range = false

var hit_register_threshold = 0.5
var player_in_range_time = 0.0
var max_speed = 50
var movement_threshold = 2

signal enemy_hit

func _init():
	add_to_group('gnat')

func _ready():
	score = 250

func _enter_tree():
	var game_manager = get_tree().get_root().get_node("SceneManager/GameManager")
	var player = game_manager.get_node("PlayArea/Player")
	var _discard = get_node("HitTrigger").connect(
		"body_entered", self, "hit_box_entered_callback")
	_discard = get_node("HitTrigger").connect(
		"body_exited", self, "hit_box_exited_callback")
	_discard = connect("enemy_hit", player, "register_hit")

func _physics_process(_delta):
	if not $AnimatedSprite.animation == "hit":
		if movement_threshold < position.distance_to(target):
			set_walk_animation()
			var _linear_velocity = move_and_slide(max_speed * position.direction_to(target))
		else:
			set_idle_animation()

func _process(delta):
	var facing_target = target
	if $AnimatedSprite.animation in ["idle", "hit"]:
		facing_target = target - target_offset
	if position.direction_to(facing_target).x < 0:
		$AnimatedSprite.set_flip_h(true)
	else:
		$AnimatedSprite.set_flip_h(false)
	if player_in_range:
		if not $AnimatedSprite.animation == "hit":
			audio_manager.play_sound("swing")
			set_hit_animation()
			player_in_range_time = 0.0
		else:
			player_in_range_time += delta
		if hit_register_threshold <= player_in_range_time:
			player_in_range_time = 0.0
			emit_signal("enemy_hit")

func set_hit_animation():
	$AnimatedSprite.play("hit")
	$AnimatedSprite.offset = Vector2(3,-3)
		
func hit_box_entered_callback(body):
	if body.is_in_group("player"):
		player_in_range = true

func hit_box_exited_callback(body):
	if body.is_in_group("player"):
		player_in_range = false

func animation_finished_callback():
	if $AnimatedSprite.animation == "hit" and not player_in_range:
		set_walk_animation()
	if $AnimatedSprite.animation == "hit" and player_in_range:
		player_in_range_time = 0.0
