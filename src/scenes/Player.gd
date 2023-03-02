extends KinematicBody2D

signal reached

var direction = Vector2.LEFT
var move_vector = Vector2.ZERO
var facing_direction = Vector2.RIGHT
var player_input_vector = Vector2.ZERO
var player_just_pressed_jump = false
var jumping = false
var max_speed = 25
var speed = 55
var jump_speed = 40
var deceleration_n = 15
var target_position = Vector2.ZERO
var seconds_elapsed = 0
var seconds_elapsed_changed = true
var gravity = Vector2(0, 40)
var movement_paused = false

var in_warn1_area = false
var in_warn2_area = false
var in_nom_area = false

var is_on_food = false
var is_on_meh_food = false

onready var sprite = $AnimatedSprite

func _ready():
	Lib.silence($HumanCollision.connect("area_entered", self, "on_human_collision_area_entered"))
	Lib.silence($NomCollision.connect("area_entered", self, "on_nom_collision_area_entered"))
	Lib.silence($NomCollision.connect("area_exited", self, "on_nom_collision_area_exited"))
	Lib.silence($ResumeTimer.connect("timeout", self, "on_resume_timer_timeout"))

func _process(delta):
	if G.state == G.STATE_ATTEMPT:
		return
	
	if G.state == G.STATE_NORMAL or G.state == G.STATE_CHASE:
		process_normal_and_chase(delta)
	elif G.state == G.STATE_BUSTED:
		process_busted(delta)
	elif G.state == G.STATE_WON:
		process_won(delta)
	
	if player_input_vector.x == 0:
		move_vector.x = Lib.plerp(move_vector.x, 0, deceleration_n, delta)
	
	move_vector += gravity * delta
	
	move_vector = move_and_slide(move_vector, Vector2.UP)
	
	if is_on_floor():
		jumping = false
	
	if move_vector.x > 1:
		facing_direction = Vector2.RIGHT
	elif move_vector.x < -1:
		facing_direction = Vector2.LEFT
	# otherwise stay
	
	update_animation()
	
	seconds_elapsed_changed = false

func process_normal_and_chase(delta):
	handle_player_input()
	
	if not movement_paused:
		if player_input_vector.x != 0:
			move_vector.x = Lib.plerp(move_vector.x, player_input_vector.x * speed, 15, delta)
		
		# note: this enables a single jump in air as well
		if player_input_vector.y < 0 and player_just_pressed_jump:
			if not jumping:
				move_vector.y += - jump_speed
				jumping = true

func process_busted(_delta):
	player_input_vector = Vector2.ZERO
	move_vector = Vector2.ZERO

func process_won(_delta):
	player_input_vector = Vector2.ZERO
	move_vector = Vector2.ZERO

func set_state():
	movement_paused = false
	
	if G.state == G.STATE_NORMAL:
		speed = 25
	elif G.state == G.STATE_CHASE:
		speed = 50
	elif G.state == G.STATE_BUSTED:
		speed = 0
	elif G.state == G.STATE_WON:
		speed = 0

func update_animation():
	if movement_paused:
		return
	
	if facing_direction == Vector2.RIGHT:
		$AnimatedSprite.flip_h = true
	else:
		$AnimatedSprite.flip_h = false
	
	$FoodInMouthSprite.flip_h = $AnimatedSprite.flip_h
	
	if move_vector.y < -0.5:
		$AnimatedSprite.play("jump")
	elif move_vector.y > 0.5:
		$AnimatedSprite.play("fall")
	elif abs(move_vector.x) > 25:
		$AnimatedSprite.play("run")
	elif abs(move_vector.x) > 1:
		$AnimatedSprite.play("walk")
	else:
		$AnimatedSprite.play("idle")

func on_second_timer_timeout():
	seconds_elapsed += 1
	seconds_elapsed_changed = true

func handle_player_input():
	player_just_pressed_jump = false
	
	player_input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	if Input.is_action_pressed("action_jump"):
		player_input_vector.y = -1
	
	if Input.is_action_just_pressed("action_jump"):
		player_just_pressed_jump = true

func on_human_collision_area_entered(_area):
	emit_signal("reached")

func on_nom_collision_area_entered(area):
	if area.name == "Warn1Collision":
		in_warn1_area = true
	elif area.name == "Warn2Collision":
		in_warn2_area = true
	elif area.name == "NomCollision":
		in_nom_area = true
		is_on_food = true
	elif area.name == "MehFoodCollision":
		is_on_meh_food = true

func on_nom_collision_area_exited(area):
	if area.name == "Warn1Collision":
		in_warn1_area = false
	elif area.name == "Warn2Collision":
		in_warn2_area = false
	elif area.name == "NomCollision":
		in_nom_area = false
		is_on_food = false
	elif area.name == "MehFoodCollision":
		is_on_meh_food = false

func on_resume_timer_timeout():
	movement_paused = false

func do_tail_wag():
	movement_paused = true
	$AnimatedSprite.play("wag")
	$ResumeTimer.start()

func do_puppy_eyes():
	movement_paused = true
	$AnimatedSprite.play("puppy_eyes")
	$ResumeTimer.start()

func set_food_in_mouth(value):
	$FoodInMouthSprite.visible = value
