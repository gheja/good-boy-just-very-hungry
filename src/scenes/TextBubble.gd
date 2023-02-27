extends Node2D

var sfx_bubble_1 : AudioStream = preload("res://data/sfx/nokia_soundpack_@trix/blip5.wav")
var sfx_bubble_2 : AudioStream = preload("res://data/sfx/nokia_soundpack_@trix/blip5.wav")
var sfx_bubble_3 : AudioStream = preload("res://data/sfx/nokia_soundpack_@trix/blip5.wav")

func _ready():
	Lib.silence($Timer.connect("timeout", self, "on_timer_timeout"))

func on_timer_timeout():
	queue_free()

func set_text(text, bubble_style = 0, mute_sound = false):
	$Label.text = text
	
	$Sprite.visible = (bubble_style == 1)
	$Sprite2.visible = (bubble_style == 2)
	$Sprite3.visible = (bubble_style == 3)
	
	if not mute_sound:
		if bubble_style == 1:
			AudioManager.play_sfx(sfx_bubble_1)
		elif bubble_style == 2:
			AudioManager.play_sfx(sfx_bubble_2)
		elif bubble_style == 3:
			AudioManager.play_sfx(sfx_bubble_3)
