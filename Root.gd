extends Node2D

var enemy_scene = preload("res://enemy/Enemy.tscn")
var coffein_scene = preload("res://items/Coffein.tscn")

onready var tile_map = $TileMap
onready var enemy_spawner_position = $SpawnAreas/EnemySpawner.global_position
onready var item_spawn_areas = $SpawnAreas/ItemAreas
onready var items = $Items
onready var item_respawn_timer = $ItemRespawnTimer


func _ready():
	spawn_item()


func spawn_enemy():
	var enemy = enemy_scene.instance()
	enemy.global_position = enemy_spawner_position
	$Enemies.add_child(enemy)


func spawn_item():
	randomize()
	var spawn_areas = item_spawn_areas.get_children()
	var spawn_area: CollisionShape2D = spawn_areas[floor(rand_range(0, len(spawn_areas)))]
	var shape: RectangleShape2D = spawn_area.shape
	var extents = shape.extents
	var x = rand_range(-extents.x / 2, extents.x / 2) + spawn_area.global_position.x
	var y = rand_range(-extents.y / 2, extents.y / 2) + spawn_area.global_position.y
	var item = coffein_scene.instance()
	item.global_position = Vector2(x, y)
	item.connect("pickup", self, "on_Item_pickup")
	items.add_child(item)


func find_spawn_area():
	tile_map.get_cell()


func on_Item_pickup():
	item_respawn_timer.start(rand_range(1.0, 3.0))


func _on_ItemRespawnTimer_timeout():
	spawn_item()


func _on_AnimationPlayer_animation_finished(_anim_name):
	$Player.start()
