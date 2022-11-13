extends Control

var main_menu_scene = preload("res://menu/main_menu/MainMenu.tscn")

const CONTROLER_ONLY_CHARS = ["B", "A", "X", "Y"]

onready var typed_text = $MarginContainer/VBoxContainer/HBoxContainer/TypedText
onready var points = $CanvasLayer/MarginContainer/CenterContainer/Points
onready var mock_text = $CanvasLayer/MarginContainer/CenterContainer/MockText
onready var new_high_score_text = $MarginContainer/VBoxContainer/HBoxContainer2/NewHighscore

var mock_texts_good = ["Einmal ist keinmal", "Nächstes mal\nwirds schlechter", "War Glück"]
var mock_texts_mid = [
	"Das geht\naber\nschon besser oder ?",
	"Die top\n1 %\nsehen anders aus ...",
	"Ohne Fleiß\nkein Preis",
	"Gib dir\nmal mehr Mühe",
	"Mittelmäßigkeit\nist eine\nKrankheit"
]
var mock_texts_bad = [
	"Wow,\ndass war schlecht",
	"Ich glaube\nmein Schwein\npfeift",
	"Du hättest auch\ngar nichts\nabgeben können",
	"Durchgefallen"
]


# Make repeating charters worth less points (disscurages holding down one key)
func get_weighted_char_count(text: String) -> float:
	var weighted_count = 0.0
	var last_char = ""
	var is_using_controler = true
	for i in range(len(text)):
		var current_char = text[i]
		if last_char == current_char:
			weighted_count += 0.5
		else:
			weighted_count += 1.0
		if not current_char in CONTROLER_ONLY_CHARS:
			is_using_controler = false
	# Using a controler grants double the points since it's harder to "type" fast
	weighted_count = weighted_count * 2 if is_using_controler else weighted_count
	return weighted_count


func compute_and_display_score():
	var score = min(get_weighted_char_count(GameData.last_game_typed_text) / (18 * 10), 15)
	if score > GameData.high_score:
		new_high_score_text.show()
		GameData.high_score = floor(score)
	points.text = "Punkte: " + str(floor(score))
	if score > 13:
		mock_text.text = mock_texts_good[floor(rand_range(0, len(mock_texts_good)))]
	elif score > 5.5:
		mock_text.text = mock_texts_mid[floor(rand_range(0, len(mock_texts_mid)))]
	else:
		mock_text.text = mock_texts_bad[floor(rand_range(0, len(mock_texts_bad)))]


func _ready():
	randomize()
	$AnimationPlayer.play("Load")
	typed_text.text = GameData.last_game_typed_text
	compute_and_display_score()
	GameData.first_time_playing = false
	GameData.save_data()
	$MarginContainer/VBoxContainer/HBoxContainer2/HBoxContainer/NextButton.grab_focus()


func _on_NextButton_button_up():
	$SoundEffectsPlayer.play_sound_effect("click")
	$NextTimer.start()


func _on_NextTimer_timeout():
	get_tree().change_scene_to(main_menu_scene)
