extends Node

const STATE_NORMAL = 0
const STATE_CHASE = 1
const STATE_BUSTED = 2
const STATE_WON = 3
const STATE_ATTEMPT = 4
const STATE_ATTEMPT_RESULT = 5

var game
var player
var human
var ui

var state

func _ready():
	pass

func set_state(new_state):
	state = new_state
	
	game.set_state()
	player.set_state()
	human.set_state()

func update():
	game = Lib.get_game()
	player = Lib.get_player()
	human = Lib.get_human()
	ui = Lib.get_ui()
