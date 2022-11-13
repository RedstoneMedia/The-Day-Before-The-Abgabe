extends Node2D

signal pickup

onready var player = get_tree().get_nodes_in_group("player")[0]
onready var sprite = $Sprite
onready var particles = $Particles
onready var free_timer = $FreeTimer
var is_picked_up = false


func _ready():
	connect("pickup", player, "_on_ItemPickup")
	set_process(false)


func _on_PickupArea_body_entered(_body):
	if is_picked_up:
		return
	is_picked_up = true
	sprite.hide()
	particles.lifetime *= 2
	particles.emitting = false
	free_timer.start()
	emit_signal("pickup")


func _on_FreeTimer_timeout():
	queue_free()
