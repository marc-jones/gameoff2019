extends Node2D

var sound_library = {
	"hit": ["res://assets/sounds/hit.wav",         -3],
	"jump": ["res://assets/sounds/jump.wav",       -10],
	"shape": ["res://assets/sounds/shape.wav",     -3],
	"gunshot": ["res://assets/sounds/gunshot.wav", -3],
	"bounce": ["res://assets/sounds/bounce.wav",   -10],
	"button_press": ["res://assets/sounds/button_press.wav",   -10],
	"swing": ["res://assets/sounds/swing.wav",   -10]
}

var music_volume = -10

var stream_library = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	for key in sound_library:
		var sound_node = AudioStreamPlayer.new()
		var stream  = load(sound_library[key][0])
		sound_node.set_stream(stream)
		sound_node.volume_db = sound_library[key][1]
		sound_node.set_bus("FX")
		add_child(sound_node)
		stream_library[key] = sound_node
	$Music.volume_db = music_volume

func play_sound(sound_str):
	if sound_str in stream_library:
		stream_library[sound_str].play()
