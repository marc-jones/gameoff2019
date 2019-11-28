extends Node2D

var audio_manager

func _ready():
	var scene_manager = get_tree().get_root().get_node("SceneManager")
	audio_manager = scene_manager.get_node("AudioManager")
	var _discard = get_node("MenuContainer/QuitToMenu").connect("button_up",
		self, "quit_button_press")

func quit_button_press():
	audio_manager.play_sound("button_press")
	get_tree().get_root().get_node("SceneManager").start_menu()
