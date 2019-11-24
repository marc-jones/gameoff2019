extends KinematicBody2D

var target : Vector2

var target_offset = Vector2(0, 0)

var score = 0

signal enemy_died

func _ready():
	add_to_group('enemy')
	set_walk_animation()

func _enter_tree():
	var game_manager = get_tree().get_root().get_node("SceneManager/GameManager")
	var player = game_manager.get_node("PlayArea/Player")
	var _discard = player.connect("moved", self, "update_target")
	_discard = game_manager.get_node("PlayArea/KillZone").connect(
		"body_entered", self, "enter_killzone_callback")
	_discard = get_node("AnimatedSprite").connect(
		"animation_finished", self, "animation_finished_callback")
	_discard = connect("enemy_died", game_manager, "enemy_died_callback")
	target = player.get_global_position() + target_offset

func set_target_offset(new_offset):
	target_offset = new_offset

func update_target(player_position):
	target = player_position + target_offset

func enter_killzone_callback(body):
	if body == self:
		emit_signal("enemy_died", score)
		kill()

func set_idle_animation():
	$AnimatedSprite.play("idle")
	$AnimatedSprite.offset = Vector2(0,0)

func set_walk_animation():
	$AnimatedSprite.play("walk")
	$AnimatedSprite.offset = Vector2(0,0)

func animation_finished_callback():
	pass

func kill():
	queue_free()
