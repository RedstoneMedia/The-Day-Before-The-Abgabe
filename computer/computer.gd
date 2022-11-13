signal typed(chars)
extends Node2D

onready var lable = $Label
onready var player = get_tree().get_nodes_in_group("player")[0]
var current_body
var hint_shown = false


func on_type(c: String):
	lable.text += c
	var line_count = lable.get_line_count()
	lable.lines_skipped = 0.0 if line_count <= 2 else line_count - 2
	var char_count = len(lable.text.replace(" ", ""))
	GameData.last_game_typed_text += c
	emit_signal("typed", char_count)


func _ready():
	set_process_input(false)
	connect("typed", player, "_on_Typed")


func _input(event):
	if event is InputEventKey:
		if event.pressed:
			on_type(char(event.unicode))
	elif event is InputEventJoypadButton:
		if event.pressed:
			var button_name = ""
			match event.button_index:
				0:
					button_name = "B"
				1:
					button_name = "A"
				2:
					button_name = "Y"
				3:
					button_name = "X"
			on_type(button_name)


func _on_InteractArea_body_entered(body):
	if GameData.first_time_playing and not hint_shown:
		player.hint_texts.append("Am Computer verrichtest du deine Arbeit")
		player.hint_texts.append("Das machst du, indem du tippst")
		player.show_next_hint()
		hint_shown = true
	current_body = body
	set_process_input(true)


func _on_InteractArea_body_exited(_body):
	current_body = null
	set_process_input(false)


func _on_AudioStreamPlayer2D_finished():
	$AudioStreamPlayer2D.play()
