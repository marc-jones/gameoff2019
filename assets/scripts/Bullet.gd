extends KinematicBody2D

var speed = 150
var velocity : Vector2

var speed_up_amount = 30

var reflected_bullet = preload("res://assets/images/bullet_reflected.png")

signal enemy_hit

func _ready():
	add_to_group('enemy')
	add_to_group('bullet')

func _enter_tree():
	var game_manager = get_tree().get_root().get_node("SceneManager/GameManager")
	var player = game_manager.get_node("PlayArea/Player")
	var _discard = game_manager.get_node("PlayArea/KillZone").connect(
		"body_entered", self, "enter_killzone_callback")
	_discard = $VisibilityNotifier2D.connect("screen_exited", self, "destroy")
	_discard = connect("enemy_hit", player, "register_hit")

func _physics_process(delta):
	rotation = velocity.angle() - PI/2
	var collision = move_and_collide(velocity * delta)
	if not collision == null:
		if collision.collider.is_in_group("trail"):
			convert_to_reflected_bullet()
			speed += speed_up_amount
			velocity = velocity.bounce(collision.normal).normalized()*speed
		if collision.collider.is_in_group("enemy"):
			collision.collider.register_shot()
			destroy()
		if collision.collider.is_in_group("player"):
			emit_signal("enemy_hit")
			destroy()

func set_dir(input_vector:Vector2):
	velocity = input_vector.normalized()*speed

func enter_killzone_callback(body):
	if body == self:
		queue_free()

func convert_to_reflected_bullet():
	# Register hits on enemies
	set_collision_mask_bit(2, true)
	$Sprite.set_texture(reflected_bullet)

func destroy():
	queue_free()
