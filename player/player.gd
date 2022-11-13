class_name Player
extends KinematicBody2D

export(float) var base_player_speed = 4000.0

onready var screen_shake: ScreenShake = $Camera2D/ScreenShake
onready var collision_shape = $CollisionShape
onready var dash_hurt_box = $DashHurtBox
onready var touch_reset_timer = $TouchResetTimer
onready var dash_hurt_timer = $DashHurtTimer
onready var game_over_timer = $GameOverTimer
onready var touch_debounce_timer = $TouchDebounceTimer
onready var remaing_time_lable = $UI/MarginContainer/VBoxContainer/ReamaingTimeLable
onready var hint_text = $UI/MarginContainer/HBoxContainer/VBoxContainer/HintText
onready var hint_hide_timer = $UI/MarginContainer/HBoxContainer/VBoxContainer/HintHideTimer
onready var hint_animation = $UI/MarginContainer/HBoxContainer/VBoxContainer/HintShowAnimation
onready var score_lable = $UI/MarginContainer/VBoxContainer/Score
onready var vignette = $UI/Vignette
onready var sound_effects_player = $SoundEffectsPlayer
onready var root = get_parent()

var velocity = Vector2.ZERO
var wall_touch_count = 0
var last_did_touch_wall = false
var can_dash = false
var speed_multiplier = 1.0
var is_dashing = false
var game_over_scene = preload("res://menu/game_end/GameEnd.tscn")
var hint_texts = []
var did_show_sleepy_hint = false
var did_show_enemy_hint = false
var kps = 0.0  # Keys per second. Used for screen shake amplutude
var last_kps = 0.0


func get_input_velocity() -> Vector2:
	var vx = Input.get_action_strength("right") - Input.get_action_strength("left")
	var vy = Input.get_action_strength("down") - Input.get_action_strength("up")
	return Vector2(vx, vy)


func show_next_hint():
	if hint_animation.is_playing() or not hint_hide_timer.is_stopped():
		return
	var next_hint = hint_texts.pop_front()
	if next_hint != null:
		show_hint(next_hint)


func show_hint(text: String):
	hint_text.text = text
	hint_animation.play("ShowHint")


func dash_remove_enemies():
	var killed_enemy_count = 0
	for enemy in dash_hurt_box.get_overlapping_bodies():
		enemy.mark_dead()
		killed_enemy_count += 1
	if killed_enemy_count > 0:
		# Klling an enemy grants two seconds back
		game_over_timer.start(game_over_timer.time_left + 2)
		$SoundEffectsPlayer.play_sound_effect("bump")
		GameData.last_game_killed_enemies += killed_enemy_count
		screen_shake.call_deferred("start", 0.3, 9, 3 * killed_enemy_count, 2)


func handle_dash():
	if is_dashing:
		dash_remove_enemies()
		return
	var can_actually_dash = (
		can_dash
		and velocity.length_squared() > 0
		and game_over_timer.time_left > 5.0
	)
	if Input.is_action_just_pressed("dash") and can_actually_dash:
		velocity *= 20
		can_dash = false
		game_over_timer.start(game_over_timer.time_left - 5.0)
		is_dashing = true
		set_collision_mask_bit(2, false)
		set_collision_layer_bit(1, false)
		set_collision_layer_bit(3, true)
		dash_remove_enemies()
		dash_hurt_timer.start()
		screen_shake.call_deferred("start", 0.3, 8, 1, 0)


func maybe_spawn_enemy():
	wall_touch_count += 1
	var enemy_spawn_chance = exp(0.056 * wall_touch_count) - 1
	if randf() < enemy_spawn_chance:
		if not did_show_enemy_hint:
			hint_texts.append("Ach ja übrigens")
			hint_texts.append("Versuch nicht\ndie Wände zu berühren :)")
			show_next_hint()
			did_show_enemy_hint = true
		$SoundEffectsPlayer.play_sound_effect("enemy_spawn")
		root.spawn_enemy()


func is_touching_wall() -> bool:
	for i in get_slide_count():
		var collision_shape = get_slide_collision(i)
		if collision_shape.collider.name == "TileMap":
			return true
	return false


func did_touch_wall() -> bool:
	var is_touching = is_touching_wall()
	if is_touching:
		touch_reset_timer.start()
	var did_touch = is_touching and not last_did_touch_wall and touch_debounce_timer.is_stopped()
	if is_touching:
		touch_debounce_timer.start()
	last_did_touch_wall = is_touching
	return did_touch


func update_ui():
	var remaning_time = game_over_timer.time_left
	# Show sleepy hint, if needed
	if remaning_time < 30 and not did_show_sleepy_hint:
		hint_texts.append("Du wirst müde")
		hint_texts.append("Siehe dich mal um")
		hint_texts.append("Vielleicht findest du etwas\n, was dich aufmuntert")
		show_next_hint()
		did_show_sleepy_hint = true
	# Update lables
	remaing_time_lable.text = "Schlafenszeit: " + str(round(remaning_time)) + "s"
	var vignette_strength = 0.2 * exp(-0.08 * (remaning_time - 45))
	vignette.material.set_shader_param("strength", vignette_strength)


func start():
	if GameData.first_time_playing:
		hint_texts.append("Gehe mit WASD zum Computer")
		show_next_hint()
		hint_text.show()


func _process(_delta):
	update_ui()


func _physics_process(delta):
	velocity += get_input_velocity() * base_player_speed * speed_multiplier
	handle_dash()
	velocity = move_and_slide(velocity * delta)
	if did_touch_wall():
		maybe_spawn_enemy()
	if speed_multiplier > 1.0:
		speed_multiplier *= 0.99965
	else:
		speed_multiplier = 1.0


func _on_TouchResetTimer_timeout():
	wall_touch_count = 0


func _on_ItemPickup():
	can_dash = true
	game_over_timer.start(game_over_timer.time_left + 10)
	speed_multiplier += 0.5
	screen_shake.call_deferred("start", 0.2, 6, 3, 1)
	if GameData.last_game_caffine_pickup_count == 0:
		hint_texts.append("Das ist Coffein")
		hint_texts.append("Damit kannst du\nlänger an deiner Arbeit arbeiten")
		hint_texts.append("Coffein verleiht dir auch eine Fähigkeit")
		hint_texts.append("Mit Coffein kannst du\n durch das Drücken von SHIFT dashen")
		show_next_hint()
	$SoundEffectsPlayer.play_sound_effect("bump")
	GameData.last_game_caffine_pickup_count += 1


func _on_Typed(char_count: int):
	kps += 2
	score_lable.text = "Seiten: " + str(ceil(char_count / 200.0 * 10) / 10)
	var shake_strength = max(3, last_kps) / 8
	if char_count == 10:
		hint_texts.append("Weiter so")
		hint_texts.append("Deine ausreichende Punktzahl ist nah!")
		show_next_hint()
	screen_shake.call_deferred("start", 0.1, 10, shake_strength, 0)


func _on_GameOverTimer_timeout():
	print("game_over")
	vignette.material.set_shader_param("strength", 1000)
	get_tree().change_scene_to(game_over_scene)


func _on_DashHurtTimer_timeout():
	is_dashing = false
	set_collision_mask_bit(2, true)
	set_collision_layer_bit(1, true)
	set_collision_layer_bit(3, false)


func _on_HalfSecondTimer_timeout():
	last_kps = kps
	kps = 0


func _on_HintShowAnimation_animation_finished(anim_name):
	if anim_name == "ShowHint":
		var wait_time = 0.5 if hint_texts.empty() else 0.3
		hint_hide_timer.start(wait_time)
	elif anim_name == "HideHint":
		show_next_hint()


func _on_HintShowTimer_timeout():
	hint_animation.play("HideHint")
