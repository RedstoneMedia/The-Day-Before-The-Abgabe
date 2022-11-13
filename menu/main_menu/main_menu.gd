extends Control

var game_scene = load("res://Root.tscn")
onready var play_button = $MarginContainer/VBoxContainer2/PlayButton
onready var high_score_label = $MarginContainer/VBoxContainer/Highscore
onready var not_a_robot_check_box = $MarginContainer/VBoxContainer2/NotARobot


func _ready():
	set_not_a_robot(GameData.not_a_robot)
	not_a_robot_check_box.set_block_signals(true)
	not_a_robot_check_box.pressed = GameData.not_a_robot
	not_a_robot_check_box.set_block_signals(false)
	if GameData.high_score > -1:
		high_score_label.text = "Highscore: " + str(GameData.high_score)
		high_score_label.show()


func set_not_a_robot(not_a_robot: bool):
	GameData.not_a_robot = not_a_robot
	if not_a_robot:
		play_button.show()
	else:
		play_button.hide()


func _on_PlayButton_button_up():
	$SoundEffectsPlayer.play_sound_effect("click")
	$AnimationPlayer.play("play")


func _on_ExitButton_button_up():
	get_tree().quit()


func _on_NotARobot_toggled(button_pressed):
	$SoundEffectsPlayer.play_sound_effect("click")
	set_not_a_robot(button_pressed)


func _on_MainMenu_resized():
	var title = $MarginContainer/VBoxContainer/Title
	title.rect_pivot_offset = title.rect_size / 2 * title.rect_scale


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "play":
		get_tree().change_scene_to(game_scene)
	elif anim_name == "load":
		set_process(false)
