extends Node2D


const GameScene = preload("res://assets/scenes/Game.tscn")
const MenuScene = preload("res://assets/scenes/Menu.tscn")
const TutorialScene = preload("res://assets/scenes/Tutorial.tscn")
const CreditsScene = preload("res://assets/scenes/Credits.tscn")
const AudioManager = preload("res://assets/scenes/AudioManager.tscn")

var audio_manager

var music_on = true
var sound_on = true

# Called when the node enters the scene tree for the first time.
func _ready():
	audio_manager = AudioManager.instance()
	add_child(audio_manager)
	start_menu()
	
func start_new_game():
	call_deferred("deferred_new_game")

func deferred_new_game():
	clear_scene()
	var new_game = GameScene.instance()
	add_child(new_game)

func start_tutorial():
	call_deferred("deferred_tutorial")

func deferred_tutorial():
	clear_scene()
	var tutorial = TutorialScene.instance()
	add_child(tutorial)

func start_credits():
	call_deferred("deferred_credits")

func deferred_credits():
	clear_scene()
	var credits = CreditsScene.instance()
	add_child(credits)

func start_menu():
	call_deferred("deferred_start_menu")

func deferred_start_menu():
	clear_scene()
	var menu = MenuScene.instance()
	add_child(menu)
	var menu_container = get_node("Menu/MenuContainer")
	menu_container.get_node("MusicToggle").set_pressed(music_on)
	menu_container.get_node("SoundToggle").set_pressed(sound_on)
	update_audio_manager()

func clear_scene():
	for child in get_children():
		if not child == audio_manager:
			child.free()
			
func start_button_callback():
	audio_manager.play_sound("button_press")
	start_new_game()

func tutorial_button_callback():
	audio_manager.play_sound("button_press")
	start_tutorial()

func credits_button_callback():
	audio_manager.play_sound("button_press")
	start_credits()

func music_toggle_callback(pressed):
	music_on = pressed
	update_audio_manager()
	audio_manager.play_sound("button_press")

func sound_toggle_callback(pressed):
	sound_on = pressed
	update_audio_manager()
	audio_manager.play_sound("button_press")

func update_audio_manager():
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), not music_on)
	AudioServer.set_bus_mute(AudioServer.get_bus_index("FX"), not sound_on)
