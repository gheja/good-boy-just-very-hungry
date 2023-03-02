extends Node2D

var the_food
var the_meh_food

func _ready():
	Lib.silence($PlayerTrackingTimer.connect("timeout", self, "on_player_tracking_timer_timeout"))

func on_player_tracking_timer_timeout():
	var player = Lib.get_player()
	
	if G.state != G.STATE_CHASE:
		return
	
	var obj = Position2D.new()
	
	$RecentPlayerPositions.add_child(obj)
	obj.global_position = player.global_position

func add_food():
	# might be called multiple times
	if the_food:
		return
	
	the_food = preload("res://scenes/TheFood.tscn").instance()
	the_food.position = Vector2(105, -20)
	$Objects.add_child(the_food)

func add_meh_food():
	# might be called multiple times
	if the_meh_food:
		return
	
	the_meh_food = preload("res://scenes/TheMehFood.tscn").instance()
	the_meh_food.position = Vector2(172, -12)
	$Objects.add_child(the_meh_food)

func show_decorations():
	the_food.show_decoration()
	the_meh_food.show_decoration()
