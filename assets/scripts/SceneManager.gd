extends Node2D


const GameScene = preload("res://assets/scenes/Game.tscn")
const MenuScene = preload("res://assets/scenes/Menu.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	start_menu()
	
func start_new_game():
	var new_game = GameScene.instance()
	for child in get_children():
		child.queue_free()
	add_child(new_game)

func start_menu():
	var menu = MenuScene.instance()
	add_child(menu)
	menu.get_node("StartButton").connect("button_up", self, "start_new_game")
