extends Node

const STATE_NORMAL = 0
const STATE_CHASE = 1
const STATE_BUSTED = 2
const STATE_WON = 3
const STATE_ATTEMPT = 4

var state
var sus_value = 0
var food_bites_max = 80
var food_bites_left = 0
var intro_active = true
var took_the_food = false
var ate_the_food = false
var show_retry = false
var score = 0

var attempt_time_left = 0.0
var attempt_time_max = 4.0

func _ready():
	randomize()

func start():
	AudioManager.play_music(preload("res://data/music/main_based_on_mountain_man_by_avgvsta_on_opengameart.wav"))
	
	var player = Lib.get_player()
	var ui = Lib.get_ui()
	player.connect("reached", self, "on_player_reached")
	
	Lib.silence($SusUpdateTimer.connect("timeout", self, "on_sus_update_timer_timeout"))
	Lib.silence($BustedTimer.connect("timeout", self, "on_busted_timer_timeout"))
	Lib.silence($WonTimer.connect("timeout", self, "on_won_timer_timeout"))
	Lib.silence(ui.connect("action_pressed", self, "on_ui_action_pressed"))
	Lib.silence($SecondTimer.connect("timeout", self, "on_second_timer_timeout"))
	
	set_state(STATE_NORMAL)
	
	start_intro()

func finish_intro(reset_positions = false):
	var human = Lib.get_human()
	var player  = Lib.get_player()
	var level = $LevelHouse
	
	level.add_meh_food()
	level.add_food()
	level.show_decorations()
	
	if reset_positions:
		player.position = Vector2(136, -8)
		human.position = Vector2(190, -8)
	
	human.on_intro_finished()
	
	intro_active = false
	Lib.set_intro_already_played(true)

func start_intro():
	var human = Lib.get_human()
	var player  = Lib.get_player()
	var level = $LevelHouse
	
	human.target_position = Vector2(73, -8)
	yield(human, "seeing_the_player")
	if not intro_active:
		return
	
	Lib.create_text_popup("Hey buddy!", human.global_position + Vector2(1, -20), false, 1)
	yield(get_tree().create_timer(3.5), "timeout")
	if not intro_active:
		return
	
	Lib.create_text_popup("Dinner is\nalmost ready", human.global_position + Vector2(1, -20), false, 1)
	yield(get_tree().create_timer(4.5), "timeout")
	if not intro_active:
		return
	
	Lib.create_text_popup("*ding*", human.global_position + Vector2(-5, -25))
	AudioManager.play_sfx(preload("res://data/sfx/nokia_soundpack_@trix/blip12.wav"))
	yield(get_tree().create_timer(0.5), "timeout")
	if not intro_active:
		return
	
	Lib.create_text_popup("Oh! It's\nready!", human.global_position + Vector2(1, -20), false, 1)
	human.target_position = Vector2(52, -8)
	yield(human, "target_reached")
	if not intro_active:
		return
	
	yield(get_tree().create_timer(0.5), "timeout")
	if not intro_active:
		return
	
	human.target_position = Vector2(160, -8)
	yield(human, "target_reached")
	yield(get_tree().create_timer(0.5), "timeout")
	if not intro_active:
		return
	
	level.add_meh_food()
	AudioManager.play_sfx(preload("res://data/sfx/nokia_soundpack_@trix/blip14.wav"))
	yield(get_tree().create_timer(1.0), "timeout")
	if not intro_active:
		return
	
	Lib.create_text_popup("For you...", human.global_position + Vector2(1, -20), false, 1)
	yield(get_tree().create_timer(1.0), "timeout")
	if not intro_active:
		return
	
	human.target_position = Vector2(120, -8)
	yield(human, "target_reached")
	yield(get_tree().create_timer(0.5), "timeout")
	if not intro_active:
		return
	
	level.add_food()
	AudioManager.play_sfx(preload("res://data/sfx/nokia_soundpack_@trix/blip14.wav"))
	yield(get_tree().create_timer(1.0), "timeout")
	if not intro_active:
		return
	
	Lib.create_text_popup("And for\nme...", human.global_position + Vector2(1, -20), false, 1)
	yield(get_tree().create_timer(3.5), "timeout")
	if not intro_active:
		return
	
	Lib.create_text_popup("*ring-ring*", human.global_position + Vector2(0, -28))
	AudioManager.play_sfx(preload("res://data/sfx/nokia_soundpack_@trix/ring1.wav"))
	yield(get_tree().create_timer(1.0), "timeout")
	if not intro_active:
		return
	
	Lib.create_text_popup("Just a\nsecond...", human.global_position + Vector2(1, -20), false, 1)
	yield(get_tree().create_timer(3.5), "timeout")
	if not intro_active:
		return
	
	Lib.create_text_popup("Hello?", human.global_position + Vector2(1, -20), false, 2)
	yield(get_tree().create_timer(3.5), "timeout")
	if not intro_active:
		return
	
	Lib.create_text_popup("Yeah,\nit's me...", human.global_position + Vector2(1, -20), false, 2)
	yield(get_tree().create_timer(0.5), "timeout")
	if not intro_active:
		return
	
	human.target_position = Vector2(190, -8)
	yield(get_tree().create_timer(3.5), "timeout")
	if not intro_active:
		return
	
	Lib.create_text_popup("Mhm...\nsure...", human.global_position + Vector2(1, -20), false, 2)
	yield(human, "target_reached")
	if not intro_active:
		return
	
	Lib.create_text_popup("Well...", player.global_position + Vector2(1, -20), false, 3)
	yield(get_tree().create_timer(3.5), "timeout")
	if not intro_active:
		return
	
	Lib.create_text_popup("I got\nan idea", player.global_position + Vector2(1, -20), false, 3)
	yield(get_tree().create_timer(3.5), "timeout")
	if not intro_active:
		return
	
	finish_intro()

func reset():
	Lib.set_auto_start_game(true)
	Lib.silence(get_tree().change_scene("res://scenes/Main.tscn"))

func reset_to_title_screen():
	Lib.set_auto_start_game(false)
	Lib.silence(get_tree().change_scene("res://scenes/Main.tscn"))

func update_camera_position(delta):
	var camera = Lib.get_camera()
	var player = Lib.get_player()
	var target
	
	if player.move_vector.y != 0:
		target = player.global_position + Vector2(0, -6)
	else:
		target = player.global_position + Vector2(0, -9)
	
	camera.position = Lib.plerp(camera.position, target, 10, delta)

func add_score(value):
	score += value
	Lib.get_ui().update_score(score)

func _process(delta):
	if state == STATE_ATTEMPT:
		process_attempt(delta)
	
	update_camera_position(delta)
	update_ui()
	update_human_check()

func process_attempt(delta):
	if attempt_time_left > 0:
		attempt_time_left -= delta
	
	if attempt_time_left <= 0:
		# auto fail
		attempt_evaluate(true)

func attempt_start():
	set_state(STATE_ATTEMPT)

func attempt_evaluate(timed_out = false):
	set_state(STATE_NORMAL)
	
	if timed_out:
		print("timeout")
		return
	
	var player = Lib.get_player()
	var food = Lib.get_first_node_in_group("foods")
	var ui = Lib.get_ui()
	
	food.queue_free()
	
	took_the_food = true
	
	player.set_food_in_mouth(true)
	
	add_score(500)
	
	if ui.is_attempt_perfect_pass():
		add_score(2000)
		attempt_perfect_pass()
	elif ui.is_attempt_pass():
		add_score(500)
		attempt_pass()
	else:
		attempt_fail()

func attempt_fail():
	print("fail")
	on_human_noticed()
	on_attempt_failed()

func attempt_pass():
	print("pass")
	pass

func attempt_perfect_pass():
	print("perfect pass")
	var player = Lib.get_player()
	var human = Lib.get_human()
	
	Lib.create_text_popup("Like a\nshadow...", player.global_position + Vector2(1, -20), false, 3, true)
	
	AudioManager.play_sfx(preload("res://data/sfx/nokia_soundpack_@trix/good3.wav"))
	
	human.freeze_a_bit()

func update_human_check():
	if state != STATE_NORMAL:
		return
	
	var human = Lib.get_human()
	
	if human.is_frozen:
		return
	
	if human.can_see_the_table and took_the_food:
		on_human_noticed()
	
	if human.can_see_the_player:
		if took_the_food:
			on_human_noticed()

func set_state(new_state):
	state = new_state
	
	if state == STATE_NORMAL:
		# ui.set_gauge_text("Sus")
		sus_value = 0
		food_bites_left = food_bites_max
		took_the_food = false
		ate_the_food = false
		show_retry = false
		score = 0
	elif state == STATE_ATTEMPT:
		attempt_time_left = attempt_time_max
	elif state == STATE_CHASE:
		pass
	elif state == STATE_BUSTED:
		if score > Lib.get_high_score():
			Lib.save_high_score(score)
		
		$BustedTimer.start()
	elif state == STATE_WON:
		if score > Lib.get_high_score():
			Lib.save_high_score(score)
		
		$WonTimer.start()
	
	Lib.get_player().set_state(state)
	Lib.get_human().set_state(state)

func on_player_reached():
	if state != STATE_CHASE:
		return
	
	if food_bites_left > 0:
		set_state(STATE_BUSTED)
	else:
		set_state(STATE_WON)
	
	AudioManager.play_sfx(preload("res://data/sfx/nokia_soundpack_@trix/good2.wav"))

func on_ui_action_pressed(action_code):
	var ui = Lib.get_ui()
	var player = Lib.get_player()
	
	if action_code == 0:
		return
		
	elif action_code == 1:
		finish_intro(true)
		
	elif action_code == 3:
		var food = Lib.get_first_node_in_group("meh_foods")
		
		if food:
			food.one_bite()
			add_score(100)
			
			Lib.create_text_popup("nom", player.global_position + Vector2(0, -15), true)
		
		AudioManager.play_sfx(preload("res://data/sfx/nokia_soundpack_@trix/blip14.wav"))
		
	elif action_code == 4:
		attempt_start()
		
	elif action_code == 5:
		attempt_evaluate()
		
	elif action_code == 10:
		player.do_tail_wag()
		sus_value = clamp(sus_value - 0.2, 0, 1)
		
	elif action_code == 11:
		player.do_puppy_eyes()
		sus_value = clamp(sus_value - 0.3, 0, 1)
		
	elif action_code == 21:
		food_bites_left -= 1
		add_score(150)
		
		Lib.create_text_popup(Lib.random_pick([ "nom", "tasty", "wow", "mmmm", "juicy", "delicious", "yummie", "yummy"]), player.global_position + Vector2(0, -15), true)
		
		if food_bites_left == 0:
			player.set_food_in_mouth(false)
			ui.set_actions(0, "", 0, "")
			ate_the_food = true
			AudioManager.play_sfx(preload("res://data/sfx/nokia_soundpack_@trix/jingle1.wav"))
			add_score(1000)
		else:
			AudioManager.play_sfx(preload("res://data/sfx/nokia_soundpack_@trix/blip14.wav"))
		
	elif action_code == 30:
		reset()
		
	elif action_code == 31:
		reset_to_title_screen()

func on_attempt_failed():
	var human = Lib.get_human()
	
	set_state(STATE_CHASE)
	human.turbo()
	
	AudioManager.play_sfx(preload("res://data/sfx/nokia_soundpack_@trix/odd1.wav"))

func on_human_noticed():
	var player = Lib.get_player()
	
	sus_value = 1.0
	
	if state == STATE_NORMAL:
		set_state(STATE_CHASE)
	
	Lib.create_text_popup("Uh-oh!", player.global_position + Vector2(1, -20), false, 3, true)
	
	AudioManager.play_music(preload("res://data/music/main_but_faster_based_on_mountain_man_by_avgvsta_on_opengameart.wav"))
	AudioManager.play_sfx(preload("res://data/sfx/nokia_soundpack_@trix/odd1.wav"))

func update_ui():
	var ui = Lib.get_ui()
	var player = Lib.get_player()
	
	if intro_active:
		ui.set_attempt(false)
		ui.set_gauge_text("")
		ui.set_gauge_value(0)
		
		if Lib.intro_already_played:
			ui.set_actions(0, "", 1, "Skip intro")
		else:
			ui.set_actions(0, "", 0, "")
		
		return
	
	if state == STATE_BUSTED or state == STATE_WON:
		ui.set_attempt(false)
		ui.set_gauge_text("")
		ui.set_gauge_value(0)
		
		if show_retry:
			ui.set_actions(30, "Next day", 31, "Exit")
		else:
			ui.set_actions(0, "", 0, "")
		
		return
	
	if ate_the_food:
		ui.set_attempt(false)
		ui.set_gauge_text("")
		ui.set_gauge_value(0)
		ui.set_actions(0, "", 0, "")
		return
		
	if took_the_food:
		ui.set_attempt(false)
		
		if food_bites_left > 0:
			ui.set_gauge_text("Food")
			ui.set_gauge_value(1.0 * food_bites_left / food_bites_max)
		else:
			ui.set_gauge_text("")
		
		if state == STATE_CHASE:
			ui.set_actions(21, "Chew!", 21, "Chew faster!")
		else:
			ui.set_actions(21, "Chew!", 0, "")
		return
	
	if state == STATE_ATTEMPT:
		ui.set_gauge_text("Time")
		ui.set_gauge_value(attempt_time_left / attempt_time_max)
		ui.set_attempt(true)
		ui.set_actions(5, "Grab!", 0, "")
		return
	
	if state == STATE_NORMAL:
		ui.set_gauge_text("Sus")
		ui.set_gauge_value(sus_value)
		ui.set_attempt(false)
		
		if player.is_on_food and sus_value < 1:
			ui.set_actions(4, "Focus!", 0, "")
		elif player.is_on_meh_food:
			ui.set_actions(3, "Eat food", 0, "")
		else:
			if sus_value == 0:
				ui.set_actions(0, "", 0, "")
			else:
				ui.set_actions(10, "Tail wag", 11, "Puppy eyes")

func on_sus_changed(old_value, new_value):
	if state != STATE_NORMAL:
		return
	
	var human = Lib.get_human()
	
	if old_value != new_value:
		human.on_sus_changed(old_value, new_value)
	
	# if new_value >= 1:
	# 	set_state(STATE_CHASE)

func on_sus_update_timer_timeout():
	if state != STATE_NORMAL:
		return
	
	var player = Lib.get_player()
	var human = Lib.get_human()
	var old_sus_value = sus_value
	
	if human.is_frozen:
		return
	
	if human.can_see_the_player:
		if player.in_nom_area:
			sus_value += 0.2
		elif player.in_warn2_area:
			sus_value += 0.2
		elif player.in_warn2_area:
			sus_value += 0.1
	
	sus_value = clamp(sus_value, 0, 1)
	
	on_sus_changed(old_sus_value, sus_value)

func on_busted_timer_timeout():
	show_retry = true

func on_won_timer_timeout():
	show_retry = true

func on_second_timer_timeout():
	if state == STATE_NORMAL or state == STATE_CHASE:
		if took_the_food:
			add_score(50)
