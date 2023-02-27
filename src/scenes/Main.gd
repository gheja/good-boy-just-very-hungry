extends Node

var game_started = false

func _ready():
	Lib.load_config()
	
	if Lib.auto_start_game:
		start_game()

func start_game():
	$ViewportContainer/Viewport/TitleScreen.queue_free()
	
	var game = preload("res://scenes/Game.tscn").instance()
	var ui = preload("res://scenes/UI.tscn").instance()
	
	$ViewportContainer/Viewport.add_child(game)
	$ViewportContainer/Viewport.add_child(ui)
	
	game.start()
	game_started = true

func _unhandled_key_input(event):
	if event.is_action_pressed("action_left"):
		if not game_started:
			start_game()
	elif event.is_action_pressed("action_mute"):
		AudioManager.toggle_music_mute()
