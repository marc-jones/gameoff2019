extends Node2D


const GameScene = preload("res://assets/scenes/Game.tscn")
const MenuScene = preload("res://assets/scenes/Menu.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	start_menu()
	
func start_new_game():
	call_deferred("deferred_new_game")

func deferred_new_game():
	for child in get_children():
		child.free()
	var new_game = GameScene.instance()
	add_child(new_game)

func start_menu():
	call_deferred("deferred_start_menu")

func deferred_start_menu():
	for child in get_children():
		child.free()
	var menu = MenuScene.instance()
	add_child(menu)
