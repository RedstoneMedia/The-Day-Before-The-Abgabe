extends Node

var last_game_typed_text = ""
var last_game_killed_enemies = 0
var last_game_caffine_pickup_count = 0
var not_a_robot = false
var high_score = 10
var first_time_playing = false

const SETTINGS_FILENAME = "user://game_data.json"


func _ready():
	load_data()


func load_data():
	var save_file = File.new()
	if not save_file.file_exists(SETTINGS_FILENAME):
		return
	save_file.open(SETTINGS_FILENAME, File.READ)
	var data_dict = parse_json(save_file.get_line())
	high_score = float(int(data_dict["high_score"]) ^ -183) / 100
	first_time_playing = data_dict["first_time_playing"]
	save_file.close()


func save_data():
	var data_dict = {
		"high_score": int(floor(high_score * 100)) ^ -183, "first_time_playing": first_time_playing
	}
	var save_file = File.new()
	save_file.open(SETTINGS_FILENAME, File.WRITE)
	save_file.store_line(to_json(data_dict))
	save_file.close()
