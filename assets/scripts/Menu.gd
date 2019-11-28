extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	var scene_manager = get_tree().get_root().get_node("SceneManager")
	var _discard = get_node("MenuContainer/StartButton").connect("button_up",
		scene_manager, "start_button_callback")
	_discard = get_node("MenuContainer/TutorialButton").connect("button_up",
		scene_manager, "tutorial_button_callback")
	_discard = get_node("MenuContainer/CreditsButton").connect("button_up",
		scene_manager, "credits_button_callback")
	_discard = get_node("MenuContainer/MusicToggle").connect("toggled",
		scene_manager, "music_toggle_callback")
	_discard = get_node("MenuContainer/SoundToggle").connect("toggled",
		scene_manager, "sound_toggle_callback")
