extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	var _discard = get_node("StartButton").connect("button_up",
		get_tree().get_root().get_node("SceneManager"), "start_new_game")
