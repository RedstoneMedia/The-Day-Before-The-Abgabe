class_name Enemy
extends KinematicBody2D

export(float) var speed = 10.0

onready var navigation = $NavigationAgent
onready var death_particales = $DeathParticles2D
onready var player = get_tree().get_nodes_in_group("player")[0]
onready var use_avoidance = OS.get_name() != "HTML5" # Avoidanve does not seem to work for web builds

var velocity = Vector2.ZERO
var is_dead = false


func _ready():
	$NavigationAgent.avoidance_enabled = use_avoidance


func mark_dead():
	is_dead = true
	collision_mask = 0
	collision_layer = 0
	$Polygon2D.hide()
	death_particales.emitting = true


func follow_player():
	navigation.set_target_location(player.global_position)
	var next_location = navigation.get_next_location()
	velocity += global_position.direction_to(next_location) * speed
	rotation = velocity.angle()
	if not use_avoidance:
		velocity = move_and_slide(velocity)
	else:
		navigation.set_velocity(velocity)


func _physics_process(delta):
	if is_dead:
		if not death_particales.emitting:
			queue_free()
	else:
		follow_player()

func _on_NavigationAgent_velocity_computed(safe_velocity):
	velocity = move_and_slide(safe_velocity)


func _on_DespwanTimer_timeout():
	mark_dead()
