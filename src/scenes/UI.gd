extends Node2D

signal action_pressed

var current_action_list

var attempt_n
var attempt_position
var current_action_left_code = 0
var current_action_right_code = 0

func _ready():
	attempt_n = 0
	
	$ActionGroup.visible = false
	$ActionGroup/AnimatedSprite.play("default")
	$ActionGroup/AnimatedSprite2.play("default")

func _unhandled_input(event):
	if event.is_action_pressed("action_left"):
		emit_signal("action_pressed", current_action_left_code)
	elif event.is_action_pressed("action_right"):
		emit_signal("action_pressed", current_action_right_code)

func _process(delta):
	global_position = Vector2(-42, -24) + Lib.get_camera().global_position
	
	if G.state != G.STATE_ATTEMPT_RESULT:
		process_attempt(delta)

func process_attempt(delta):
	attempt_n += 0.06
	attempt_position = pow(cos(attempt_n), 2)
	$ActionGroup/SpriteAttemptArrow.position.x = 7 + attempt_position * 72
	

func set_actions(action_left_code, action_left_text, action_right_code, action_right_text):
	current_action_left_code = action_left_code
	$ActionLeftLabel.text = action_left_text
	
	current_action_right_code = action_right_code
	$ActionRightLabel.text= action_right_text

func set_gauge_text(text):
	var a = (text != "")
	
	$GaugeLabel.text = text
	$GaugeLabel.visible = a
	$SpriteGauge.visible = a
	$GaugeFilled.visible = a

func set_gauge_value(value):
	$GaugeFilled.rect_size.x = clamp(value, 0, 1) * 64

func attempt_start():
	$ActionGroup/ResultPassSprite.visible = false
	$ActionGroup/ResultPerfectPassSprite.visible = false
	$ActionGroup/ResultFailSprite.visible = false
	$ActionGroup/RunSprite.visible = false
	
	$AnimationPlayer.play("default")

func attempt_pass():
	$ActionGroup/ResultPassSprite.visible = true

func attempt_perfect_pass():
	$ActionGroup/ResultPerfectPassSprite.visible = true

func attempt_fail():
	$ActionGroup/ResultFailSprite.visible = true

func attempt_run():
	$ActionGroup/RunSprite.visible = true

func set_attempt(value):
	$ActionGroup.visible = value

func is_attempt_pass():
	if attempt_position > 0.27 and attempt_position < 0.73:
		return true
	
	return false

func is_attempt_perfect_pass():
	if attempt_position > 0.44 and attempt_position < 0.56:
		return true
	
	return false

func update_score(value):
	$ScoreLabel.text = str(value)
