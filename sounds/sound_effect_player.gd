class_name SoundEffectsPlayer
extends Node

var sound_effects = {
	"bump":
	[
		preload("res://sounds/bump_1.wav"),
		preload("res://sounds/bump_2.wav"),
		preload("res://sounds/bump_3.wav"),
		preload("res://sounds/bump_4.wav")
	],
	"click": [preload("res://sounds/tap.wav")],
	"text": [preload("res://sounds/text.wav")],
	"enemy_spawn":
	[
		preload("res://sounds/enemy_spawn.wav"),
		preload("res://sounds/enemy_spawn_2.wav"),
	]
}


func play_sound_effect(name: String, loudness: float = 0.0):
	randomize()
	var streams = sound_effects[name]
	var audio_stream_player = AudioStreamPlayer.new()
	audio_stream_player.stream = streams[floor(rand_range(0, len(streams)))]
	audio_stream_player.name = "StreamAudio_" + name
	audio_stream_player.pitch_scale = rand_range(0.8, 1.2)
	audio_stream_player.volume_db = rand_range(-1 + loudness, 0.0 + loudness)
	audio_stream_player.connect("finished", self, "_on_audio_finished", [audio_stream_player])
	add_child(audio_stream_player)
	audio_stream_player.call_deferred("play")


func _on_audio_finished(player: AudioStreamPlayer):
	player.queue_free()
