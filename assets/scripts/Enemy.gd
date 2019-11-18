extends KinematicBody2D

var target : Vector2
var max_speed = 50
var player_in_range = false

var hit_register_threshold = 0.6
var player_in_range_time = 0.0

signal enemy_hit

func _ready():
	new_random_target()
	add_to_group('enemy')
	set_walk_animation()

func _enter_tree():
	var _discard = get_node("../../Player").connect("moved", self, "update_target")
	_discard = get_node("../../KillZone").connect("body_entered", self, "enter_killzone_callback")
	_discard = get_node("HitTrigger").connect("body_entered", self, "hit_box_entered_callback")
	_discard = get_node("HitTrigger").connect("body_exited", self, "hit_box_exited_callback")
	_discard = get_node("AnimatedSprite").connect("animation_finished", self, "animation_finished_callback")
	_discard = connect("enemy_hit", get_node("../../Player"), "register_hit")

func new_random_target():
	var viewport = get_viewport_rect().size
	target = Vector2(randi() % int(viewport.x), randi() % int(viewport.y))
	
func _physics_process(_delta):
	var _linear_velocity = move_and_slide(max_speed * position.direction_to(target))

func update_target(new_target):
	target = new_target

func enter_killzone_callback(body):
	if body == self:
		queue_free()

func _process(delta):
	if position.direction_to(target).x < 0:
		$AnimatedSprite.set_flip_h(true)
	else:
		$AnimatedSprite.set_flip_h(false)
	if player_in_range:
		if not $AnimatedSprite.animation == "hit":
			set_hit_animation()
			player_in_range_time = 0.0
		else:
			player_in_range_time += delta
		if hit_register_threshold <= player_in_range_time:
			player_in_range_time = 0.0
			emit_signal("enemy_hit")

func set_idle_animation():
	$AnimatedSprite.play("idle")
	$AnimatedSprite.offset = Vector2(0,0)

func set_walk_animation():
	$AnimatedSprite.play("walk")
	$AnimatedSprite.offset = Vector2(0,0)

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
		set_idle_animation()
	if $AnimatedSprite.animation == "hit" and player_in_range:
		player_in_range_time = 0.0

