extends Node

const CONFIG_FILE_NAME = "user://config.tres"

var text_bubble_scene = preload("res://scenes/TextBubble.tscn")
var intro_already_played = false
var title_already_played = false
var auto_start_game = false
var config = ConfigFile.new()

func reset_config():
	config.clear()
	config.set_value("save", "high_score", 0)
	save_config()

func load_config():
	var a = config.load(CONFIG_FILE_NAME)
	
	if a != OK:
		reset_config()

func save_config():
	config.save(CONFIG_FILE_NAME)

func save_high_score(value):
	config.set_value("save", "high_score", value)
	save_config()

func get_high_score():
	return config.get_value("save", "high_score", 0)

func get_camera():
	var cameras = get_tree().get_nodes_in_group("cameras")
	
	assert(cameras.size() > 0)
	
	for camera in cameras:
		if camera.current:
			return camera
	
	return null

func get_first_node_in_group(group_name):
	var objects = get_tree().get_nodes_in_group(group_name)
	
	if objects.size() == 0:
		return null
	
	return objects[0]

func get_game():
	return get_first_node_in_group("games")

func get_player():
	return get_first_node_in_group("players")

func get_human():
	return get_first_node_in_group("humans")

func get_ui():
	return get_first_node_in_group("uis")

func plerp(a, b, power, delta):
	return lerp(b, a, pow(2, (-1 * power) * delta))

func silence(_value):
	return

func create_text_popup(text, position, random_offset = false, bubble_style = 0, mute_sound = false):
	var obj
	obj = text_bubble_scene.instance()
	
	get_first_node_in_group("levels").add_child(obj)
	obj.global_position = position
	
	if random_offset:
		obj.global_position.x += (randi() % 20) - 10
		obj.global_position.y += (randi() % 10) - 5
	
	obj.set_text(text, bubble_style, mute_sound)

func random_pick(array):
	return array[ randi() % array.size() ]

func set_intro_already_played(value):
	intro_already_played = value

func set_title_already_played(value):
	title_already_played = value

func set_auto_start_game(value):
	auto_start_game = value
