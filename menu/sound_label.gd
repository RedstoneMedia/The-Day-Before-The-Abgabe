extends Label

export(NodePath) var sound_effects_player_path
export(float) var loudness = 0.0

onready var sound_effects_player : SoundEffectsPlayer = get_node(sound_effects_player_path)

onready var last_visible_char_count = visible_characters

func _physics_process(_delta):
	if visible_characters > last_visible_char_count:
		last_visible_char_count = visible_characters
		sound_effects_player.play_sound_effect("text", loudness)
	last_visible_char_count = visible_characters
