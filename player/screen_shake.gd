class_name ScreenShake
extends Node

const TRANS = Tween.TRANS_SINE
const EASE = Tween.EASE_IN_OUT

onready var camera: Camera2D = get_parent()
onready var duration_timer = $Duration
onready var frequency_timer = $Frequency
onready var shake_tween: Tween = $ShakeTween

var amplitude = 0
var priority = 0


func start(duration = 0.5, frequency = 15, amplitude = 16, priority = 0):
	if priority >= self.priority:
		self.priority = priority
		self.amplitude = amplitude

		duration_timer.wait_time = duration
		frequency_timer.wait_time = 1 / float(frequency)
		duration_timer.start()
		frequency_timer.start()
		_new_shake()


func _new_shake():
	var rand = Vector2()
	rand.x = rand_range(-amplitude, amplitude)
	rand.y = rand_range(-amplitude, amplitude)

	var frequency_wait_time = frequency_timer.wait_time
	shake_tween.interpolate_property(
		camera, "offset", camera.offset, rand, frequency_wait_time, TRANS, EASE
	)
	shake_tween.start()


func _reset():
	var frequency_wait_time = frequency_timer.wait_time
	shake_tween.interpolate_property(
		camera, "offset", camera.offset, Vector2(), frequency_wait_time, TRANS, EASE
	)
	shake_tween.start()
	priority = 0


func _on_Frequency_timeout():
	_new_shake()


func _on_Duration_timeout():
	_reset()
	$Frequency.stop()
