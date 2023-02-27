extends KinematicBody2D

signal target_reached
signal seeing_the_player

const STATE_NORMAL = 0
const STATE_CHASE = 1
const STATE_BUSTED = 2
const STATE_WON = 3

var direction = Vector2.LEFT
var move_vector = Vector2.ZERO
var facing_direction = Vector2.LEFT
var speed = 0
var target_position = Vector2.ZERO
var seconds_elapsed = 0
var seconds_elapsed_changed = true
var gravity = Vector2(0, 20)
var can_see_the_player = false
var can_see_the_table = false
var intro_active = true

var state

func _ready():
	target_position = global_position
	Lib.silence($SecondTimer.connect("timeout", self, "on_second_timer_timeout"))
	Lib.silence($SightLeftCollision.connect("area_entered", self, "on_sight_area_entered"))
	Lib.silence($SightLeftCollision.connect("area_exited", self, "on_sight_area_exited"))
	Lib.silence($SightRightCollision.connect("area_entered", self, "on_sight_area_entered"))
	Lib.silence($SightRightCollision.connect("area_exited", self, "on_sight_area_exited"))
	set_state(STATE_NORMAL)

func _process(delta):
	if state == STATE_NORMAL:
		process_normal(delta)
	elif state == STATE_CHASE:
		process_chase(delta)
	elif state == STATE_BUSTED:
		process_busted(delta)
	elif state == STATE_WON:
		process_won(delta)
	
	move_vector = speed * direction
	# move_vector = speed * direction + gravity
	
	global_position += move_vector * delta
	# move_vector = move_and_slide(move_vector)
	
	
	if move_vector.x > 0.01 and facing_direction != Vector2.RIGHT:
		facing_direction = Vector2.RIGHT
		$AnimatedSprite.flip_h = true
		can_see_the_player = false
		$SightLeftCollision/CollisionShape2D.disabled = true
		$SightRightCollision/CollisionShape2D.disabled = false
	elif move_vector.x < -0.01 and facing_direction != Vector2.LEFT:
		facing_direction = Vector2.LEFT
		$AnimatedSprite.flip_h = false
		can_see_the_player = false
		$SightLeftCollision/CollisionShape2D.disabled = false
		$SightRightCollision/CollisionShape2D.disabled = true
	# otherwise stay
	
	update_animation()
	
	seconds_elapsed_changed = false

func set_direction_to_target():
	direction = (target_position - global_position).normalized()
	
	if (target_position - global_position).length() < 1:
		emit_signal("target_reached")
		direction = Vector2.ZERO

func process_normal(_delta):
	if not intro_active:
		if seconds_elapsed_changed:
			update_target_position_normal()
	
	set_direction_to_target()

func process_chase(_delta):
	update_target_position_chase()
	set_direction_to_target()
	
	if seconds_elapsed_changed:
		speed = speed * 1.025

func process_busted(_delta):
	global_position = Lib.get_player().global_position + Vector2(-12, 0)

func process_won(_delta):
	global_position = Lib.get_player().global_position + Vector2(-12, 0)

func set_state(new_state):
	state = new_state
	
	if state == STATE_NORMAL:
		speed = 10
		intro_active = true
	elif state == STATE_CHASE:
		Lib.create_text_popup("Stop!", global_position + Vector2(0, -20), false, 1)
		speed = 30
	elif state == STATE_BUSTED:
		# just to move to the correct position
		process_busted(0)
		Lib.create_text_popup(Lib.random_pick([ "Got you!", "Almost!", "Nice try!", "Maybe\nnext time" ]), global_position + Vector2(0, -20), false, 1)
		speed = 0
	elif state == STATE_WON:
		# just to move to the correct position
		process_won(0)
		Lib.create_text_popup(Lib.random_pick([ "Good one!", "Impressive." ]), global_position + Vector2(0, -20), false, 1)
		speed = 0

func update_target_position_normal():
	var positions = get_tree().get_nodes_in_group("human_goals")
	
	assert(positions.size() >= 2)
	
	var t = (seconds_elapsed % 12)
	
	if seconds_elapsed % 14 == 0:
		Lib.create_text_popup(Lib.random_pick(["...mhm...", "...yes...", "...sure...", "...I see...", "...hmm..."]), global_position + Vector2(1, -20), false, 2)
	
	if t == 2:
		target_position = positions[0].global_position
	elif t == 8:
		target_position = positions[1].global_position

func update_target_position_chase():
	var player = Lib.get_player()
	var positions = Lib.get_first_node_in_group("player_positions_container").get_children()
	
	if positions.size() > 0:
		if (positions[0].global_position - global_position).length() < 3:
			positions[0].queue_free()
			positions.remove(0)
	
	if positions.size() > 0:
		target_position = positions[0].global_position
	else:
		target_position = player.global_position

func update_animation():
	if abs(move_vector.x) > 10:
		$AnimatedSprite.play("run")
	elif abs(move_vector.x) > 1:
		$AnimatedSprite.play("walk")
	else:
		$AnimatedSprite.play("idle")

func on_second_timer_timeout():
	seconds_elapsed += 1
	seconds_elapsed_changed = true

func on_sight_area_entered(area):
	if area.name == "TableSightCollision":
		can_see_the_table = true
	else:
		emit_signal("seeing_the_player")
		can_see_the_player = true

func on_sight_area_exited(area):
	if area.name == "TableSightCollision":
		can_see_the_table = false
	else:
		can_see_the_player = false

func on_sus_changed(old_value, new_value):
	var s
	
	if old_value > 0 and new_value == 0:
		Lib.create_text_popup("Good boy!", global_position + Vector2(0, -20), false, 1)
	else:
		if old_value < new_value:
			if new_value < 0.25:
				s = "Hey!"
			elif new_value < 0.5:
				s = "That's\nmy food!"
			elif new_value < 0.75:
				s = "Don't!"
			else:
				s = "No!"
			
			Lib.create_text_popup(s, global_position + Vector2(1, -20), false, 1)

func on_intro_finished():
	intro_active = false
	seconds_elapsed = 0

func turbo():
	speed = 50
