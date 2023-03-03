extends Node

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
	G.update()
	G.set_state(G.STATE_NORMAL)
	
	AudioManager.play_music(preload("res://data/music/main_based_on_mountain_man_by_avgvsta_on_opengameart.wav"))
	
	G.player.connect("reached", self, "on_player_reached")
	
	Lib.silence($SusUpdateTimer.connect("timeout", self, "on_sus_update_timer_timeout"))
	Lib.silence($BustedTimer.connect("timeout", self, "on_busted_timer_timeout"))
	Lib.silence($WonTimer.connect("timeout", self, "on_won_timer_timeout"))
	Lib.silence(G.ui.connect("action_pressed", self, "on_ui_action_pressed"))
	Lib.silence($SecondTimer.connect("timeout", self, "on_second_timer_timeout"))
	start_intro()

func finish_intro(reset_positions = false):
	var level = $LevelHouse
	
	level.add_meh_food()
	level.add_food()
	level.show_decorations()
	
	if reset_positions:
		G.player.position = Vector2(136, -8)
		G.human.position = Vector2(190, -8)
	
	G.human.on_intro_finished()
	
	intro_active = false
	Lib.set_intro_already_played(true)

func start_intro():
	var level = $LevelHouse
	
	G.human.target_position = Vector2(73, -8)
	yield(G.human, "seeing_the_player")
	if not intro_active:
		return
	
	Lib.create_text_popup("Hey buddy!", G.human.global_position + Vector2(1, -20), false, 1)
	yield(get_tree().create_timer(3.5), "timeout")
	if not intro_active:
		return
	
	Lib.create_text_popup("Dinner is\nalmost ready", G.human.global_position + Vector2(1, -20), false, 1)
	yield(get_tree().create_timer(4.5), "timeout")
	if not intro_active:
		return
	
	Lib.create_text_popup("*ding*", G.human.global_position + Vector2(-5, -25))
	AudioManager.play_sfx(preload("res://data/sfx/nokia_soundpack_@trix/blip12.wav"))
	yield(get_tree().create_timer(0.5), "timeout")
	if not intro_active:
		return
	
	Lib.create_text_popup("Oh! It's\nready!", G.human.global_position + Vector2(1, -20), false, 1)
	G.human.target_position = Vector2(52, -8)
	yield(G.human, "target_reached")
	if not intro_active:
		return
	
	yield(get_tree().create_timer(0.5), "timeout")
	if not intro_active:
		return
	
	G.human.target_position = Vector2(160, -8)
	yield(G.human, "target_reached")
	yield(get_tree().create_timer(0.5), "timeout")
	if not intro_active:
		return
	
	level.add_meh_food()
	AudioManager.play_sfx(preload("res://data/sfx/nokia_soundpack_@trix/blip14.wav"))
	yield(get_tree().create_timer(1.0), "timeout")
	if not intro_active:
		return
	
	Lib.create_text_popup("For you...", G.human.global_position + Vector2(1, -20), false, 1)
	yield(get_tree().create_timer(1.0), "timeout")
	if not intro_active:
		return
	
	G.human.target_position = Vector2(120, -8)
	yield(G.human, "target_reached")
	yield(get_tree().create_timer(0.5), "timeout")
	if not intro_active:
		return
	
	level.add_food()
	AudioManager.play_sfx(preload("res://data/sfx/nokia_soundpack_@trix/blip14.wav"))
	yield(get_tree().create_timer(1.0), "timeout")
	if not intro_active:
		return
	
	Lib.create_text_popup("And for\nme...", G.human.global_position + Vector2(1, -20), false, 1)
	yield(get_tree().create_timer(3.5), "timeout")
	if not intro_active:
		return
	
	Lib.create_text_popup("*ring-ring*", G.human.global_position + Vector2(0, -28))
	AudioManager.play_sfx(preload("res://data/sfx/nokia_soundpack_@trix/ring1.wav"))
	yield(get_tree().create_timer(1.0), "timeout")
	if not intro_active:
		return
	
	Lib.create_text_popup("Just a\nsecond...", G.human.global_position + Vector2(1, -20), false, 1)
	yield(get_tree().create_timer(3.5), "timeout")
	if not intro_active:
		return
	
	Lib.create_text_popup("Hello?", G.human.global_position + Vector2(1, -20), false, 2)
	yield(get_tree().create_timer(3.5), "timeout")
	if not intro_active:
		return
	
	Lib.create_text_popup("Yeah,\nit's me...", G.human.global_position + Vector2(1, -20), false, 2)
	yield(get_tree().create_timer(0.5), "timeout")
	if not intro_active:
		return
	
	G.human.target_position = Vector2(190, -8)
	yield(get_tree().create_timer(3.5), "timeout")
	if not intro_active:
		return
	
	Lib.create_text_popup("Mhm...\nsure...", G.human.global_position + Vector2(1, -20), false, 2)
	yield(G.human, "target_reached")
	if not intro_active:
		return
	
	Lib.create_text_popup("Well...", G.player.global_position + Vector2(1, -20), false, 3)
	yield(get_tree().create_timer(3.5), "timeout")
	if not intro_active:
		return
	
	Lib.create_text_popup("I got\nan idea", G.player.global_position + Vector2(1, -20), false, 3)
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
	var target
	
	if G.player.move_vector.y != 0:
		target = G.player.global_position + Vector2(0, -6)
	else:
		target = G.player.global_position + Vector2(0, -9)
	
	camera.position = Lib.plerp(camera.position, target, 10, delta)

func add_score(value):
	score += value
	G.ui.update_score(score)

func _process(delta):
	if G.state == G.STATE_ATTEMPT:
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
	G.set_state(G.STATE_ATTEMPT)
	G.ui.attempt_start()

func attempt_evaluate(timed_out = false):
	if G.state != G.STATE_ATTEMPT:
		return
	
	var result
	var food = Lib.get_first_node_in_group("foods")
	
	G.set_state(G.STATE_ATTEMPT_RESULT)
	
	
	### the animation
	
	if timed_out:
		result = 1
		G.ui.attempt_fail()
		AudioManager.play_sfx(preload("res://data/sfx/nokia_soundpack_@trix/blip3.wav"))
	elif G.ui.is_attempt_perfect_pass():
		result = 2
		G.ui.attempt_perfect_pass()
		AudioManager.play_sfx(preload("res://data/sfx/nokia_soundpack_@trix/good3.wav"))
	elif G.ui.is_attempt_pass():
		result = 3
		G.ui.attempt_pass()
		AudioManager.play_sfx(preload("res://data/sfx/nokia_soundpack_@trix/blip1.wav"))
	else:
		result = 4
		G.ui.attempt_fail()
		AudioManager.play_sfx(preload("res://data/sfx/nokia_soundpack_@trix/blip3.wav"))
	
	yield(get_tree().create_timer(1.0), "timeout")
	
	G.ui.attempt_run()
	yield(get_tree().create_timer(1.0), "timeout")
	
	
	### the actual work
	
	G.set_state(G.STATE_NORMAL)
	add_score(500)
	food.queue_free()
	G.player.set_food_in_mouth(true)
	took_the_food = true
	
	if result == 1:
		attempt_fail()
	elif result == 2:
		add_score(2000)
		attempt_perfect_pass()
	elif result == 3:
		add_score(500)
		attempt_pass()
	elif result == 4:
		attempt_fail()

func attempt_fail():
	print("fail")
	on_human_noticed()
	on_attempt_failed()

func attempt_pass():
	pass

func attempt_perfect_pass():
	print("perfect pass")
	
	Lib.create_text_popup("Like a\nshadow...", G.player.global_position + Vector2(1, -20), false, 3, true)
	
	G.human.freeze_a_bit()

func update_human_check():
	if G.state != G.STATE_NORMAL:
		return
	
	if G.human.is_frozen:
		return
	
	if G.human.can_see_the_table and took_the_food:
		on_human_noticed()
	
	if G.human.can_see_the_player:
		if took_the_food:
			on_human_noticed()

func set_state():
	if G.state == G.STATE_NORMAL:
		sus_value = 0
		food_bites_left = food_bites_max
		took_the_food = false
		ate_the_food = false
		show_retry = false
		score = 0
	elif G.state == G.STATE_ATTEMPT:
		attempt_time_left = attempt_time_max
	elif G.state == G.STATE_CHASE:
		pass
	elif G.state == G.STATE_BUSTED:
		if score > Lib.get_high_score():
			Lib.save_high_score(score)
		
		$BustedTimer.start()
	elif G.state == G.STATE_WON:
		if score > Lib.get_high_score():
			Lib.save_high_score(score)
		
		$WonTimer.start()

func on_player_reached():
	if G.state != G.STATE_CHASE:
		return
	
	if food_bites_left > 0:
		G.set_state(G.STATE_BUSTED)
	else:
		G.set_state(G.STATE_WON)
	
	AudioManager.play_sfx(preload("res://data/sfx/nokia_soundpack_@trix/good2.wav"))

func on_ui_action_pressed(action_code):
	if action_code == 0:
		return
		
	elif action_code == 1:
		finish_intro(true)
		
	elif action_code == 3:
		var food = Lib.get_first_node_in_group("meh_foods")
		
		if food:
			food.one_bite()
			add_score(100)
			
			Lib.create_text_popup("nom", G.player.global_position + Vector2(0, -15), true)
		
		AudioManager.play_sfx(preload("res://data/sfx/nokia_soundpack_@trix/blip14.wav"))
		
	elif action_code == 4:
		attempt_start()
		
	elif action_code == 5:
		attempt_evaluate()
		
	elif action_code == 10:
		G.player.do_tail_wag()
		sus_value = clamp(sus_value - 0.2, 0, 1)
		
	elif action_code == 11:
		G.player.do_puppy_eyes()
		sus_value = clamp(sus_value - 0.3, 0, 1)
		
	elif action_code == 21:
		food_bites_left -= 1
		add_score(150)
		
		Lib.create_text_popup(Lib.random_pick([ "nom", "tasty", "wow", "mmmm", "juicy", "delicious", "yummie", "yummy"]), G.player.global_position + Vector2(0, -15), true)
		
		if food_bites_left == 0:
			G.player.set_food_in_mouth(false)
			G.ui.set_actions(0, "", 0, "")
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
	G.set_state(G.STATE_CHASE)
	G.human.turbo()
	
	AudioManager.play_sfx(preload("res://data/sfx/nokia_soundpack_@trix/odd1.wav"))

func on_human_noticed():
	sus_value = 1.0
	
	if G.state == G.STATE_NORMAL:
		G.set_state(G.STATE_CHASE)
	
	Lib.create_text_popup("Uh-oh!", G.player.global_position + Vector2(1, -20), false, 3, true)
	
	AudioManager.play_music(preload("res://data/music/main_but_faster_based_on_mountain_man_by_avgvsta_on_opengameart.wav"))
	AudioManager.play_sfx(preload("res://data/sfx/nokia_soundpack_@trix/odd1.wav"))

func update_ui():
	if intro_active:
		G.ui.set_attempt(false)
		G.ui.set_gauge_text("")
		G.ui.set_gauge_value(0)
		
		if Lib.intro_already_played:
			G.ui.set_actions(0, "", 1, "Skip intro")
		else:
			G.ui.set_actions(0, "", 0, "")
		
		return
	
	if G.state == G.STATE_BUSTED or G.state == G.STATE_WON:
		G.ui.set_attempt(false)
		G.ui.set_gauge_text("")
		G.ui.set_gauge_value(0)
		
		if show_retry:
			G.ui.set_actions(30, "Next day", 31, "Exit")
		else:
			G.ui.set_actions(0, "", 0, "")
		
		return
	
	if ate_the_food:
		G.ui.set_attempt(false)
		G.ui.set_gauge_text("")
		G.ui.set_gauge_value(0)
		G.ui.set_actions(0, "", 0, "")
		return
		
	if took_the_food:
		G.ui.set_attempt(false)
		
		if food_bites_left > 0:
			G.ui.set_gauge_text("Food")
			G.ui.set_gauge_value(1.0 * food_bites_left / food_bites_max)
		else:
			G.ui.set_gauge_text("")
		
		if G.state == G.STATE_CHASE:
			G.ui.set_actions(21, "Chew!", 21, "Chew faster!")
		else:
			G.ui.set_actions(21, "Chew!", 0, "")
		return
	
	if G.state == G.STATE_ATTEMPT:
		G.ui.set_gauge_text("Time")
		G.ui.set_gauge_value(attempt_time_left / attempt_time_max)
		G.ui.set_attempt(true)
		G.ui.set_actions(5, "Grab!", 0, "")
		return
	
	if G.state == G.STATE_ATTEMPT_RESULT:
		G.ui.set_gauge_text("Food")
		G.ui.set_gauge_value(1.0)
		G.ui.set_actions(0, "", 0, "")
		return
	
	if G.state == G.STATE_NORMAL:
		G.ui.set_gauge_text("Sus")
		G.ui.set_gauge_value(sus_value)
		G.ui.set_attempt(false)
		
		if G.player.is_on_food and sus_value == 0:
			G.ui.set_actions(4, "Focus!", 0, "")
		elif G.player.is_on_meh_food:
			G.ui.set_actions(3, "Eat food", 0, "")
		else:
			if sus_value == 0:
				G.ui.set_actions(0, "", 0, "")
			else:
				G.ui.set_actions(10, "Tail wag", 11, "Puppy eyes")

func on_sus_changed(old_value, new_value):
	if G.state != G.STATE_NORMAL:
		return
	
	if old_value != new_value:
		G.human.on_sus_changed(old_value, new_value)

func on_sus_update_timer_timeout():
	if G.state != G.STATE_NORMAL:
		return
	
	var old_sus_value = sus_value
	
	if G.human.is_frozen:
		return
	
	if G.human.can_see_the_player:
		if G.player.in_nom_area:
			sus_value += 0.2
		elif G.player.in_warn2_area:
			sus_value += 0.2
		elif G.player.in_warn2_area:
			sus_value += 0.1
	
	sus_value -= 0.01
	
	sus_value = clamp(sus_value, 0, 1)
	
	on_sus_changed(old_sus_value, sus_value)

func on_busted_timer_timeout():
	show_retry = true

func on_won_timer_timeout():
	show_retry = true

func on_second_timer_timeout():
	if G.state == G.STATE_NORMAL or G.state == G.STATE_CHASE:
		if took_the_food:
			add_score(50)
