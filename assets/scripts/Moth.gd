extends "res://assets/scripts/Enemy.gd"

var player_in_range = false

onready var ray = $RayCast2D
var player

var time_since_last_shot = 0
var reload_time = 3.0

var max_speed = 30
var min_distance_from_player = 150
var max_range = 300

var BulletTemplate = load("res://assets/scenes/Bullet.tscn")

func _init():
	add_to_group('moth')

func _ready():
	score = 400

func _enter_tree():
	var game_manager = get_tree().get_root().get_node("SceneManager/GameManager")
	player = game_manager.get_node("PlayArea/Player")

func _physics_process(_delta):
	if not $AnimatedSprite.animation == "shoot":
		if position.distance_to(target) < min_distance_from_player:
			set_walk_animation()
			var _linear_velocity = move_and_slide(max_speed * target.direction_to(position))
		if max_range < position.distance_to(target):
			set_walk_animation()
			var _linear_velocity = move_and_slide(max_speed * position.direction_to(target))
		else:
			set_idle_animation()
	
func _process(delta):
	ray.set_cast_to(target - position)
	if ray.get_collider() == player:
		player_in_range = true
	else:
		player_in_range = false
	if position.direction_to(target).x < 0:
		$AnimatedSprite.set_flip_h(true)
	else:
		$AnimatedSprite.set_flip_h(false)
	if player_in_range and reload_time <= time_since_last_shot:
		shoot()
		time_since_last_shot = 0
	time_since_last_shot += delta

func set_shoot_animation():
	$AnimatedSprite.play("shoot")
	$AnimatedSprite.offset = Vector2(0,0)

func shoot():
	set_shoot_animation()
	var bullet = BulletTemplate.instance()
	bullet.position = position
	bullet.set_dir(target - position)
	get_parent().add_child(bullet)
	audio_manager.play_sound("gunshot")

func animation_finished_callback():
	if $AnimatedSprite.animation == "shoot":
		set_idle_animation()
