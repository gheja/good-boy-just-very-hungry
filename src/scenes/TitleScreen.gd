extends Node2D

var text_step = 0

func _ready():
	AudioManager.play_music(preload("res://data/music/intro_based_on_valentine_1_by_avgvsta_on_opengameart.wav"))
	
	$AnimatedSprite.frame = 0
	$StartTextContainer.visible = false
	
	Lib.silence($CreditsTimer.connect("timeout", self, "on_credits_timer_timeout"))
	Lib.silence($StartTextTimer.connect("timeout", self, "on_start_text_timer_timeout"))
	
	if not Lib.title_already_played:
		$AnimatedSprite.play("default")
		Lib.silence($AnimatedSprite.connect("animation_finished", self, "on_animation_finished"))
		$CreditsLabel.visible = false
	else:
		$AnimatedSprite.play("loop")
		$StartTextTimer.start()
		start_credits_timer()
	
	Lib.set_title_already_played(true)

func on_animation_finished():
	if $AnimatedSprite.animation != "default":
		return
	
	$AnimatedSprite.play("loop")
	start_credits_timer()

func start_credits_timer():
	$CreditsTimer.start()
	on_credits_timer_timeout()

func on_credits_timer_timeout():
	$CreditsLabel.visible = true
	
	if text_step == 0:
		$CreditsLabel.text = "Best score:\n" + str(Lib.get_high_score())
	elif text_step == 1:
		$CreditsLabel.text = "Sounds:\nTrix"
	elif text_step == 2:
		$CreditsLabel.text = "Music:\nAvgvsta, gheja"
	elif text_step == 3:
		$CreditsLabel.text = "Small font:\nBrian Swetland"
	elif text_step == 4:
		$CreditsLabel.text = "Big font:\nEeeve Somepx"
	elif text_step == 5:
		$CreditsLabel.text = "Code, graphics:\ngheja"
	
	text_step += 1
	
	if text_step >= 6:
		if $StartTextTimer.time_left == 0:
			$StartTextTimer.start()
		text_step = 0

func on_start_text_timer_timeout():
	$StartTextContainer.visible = !$StartTextContainer.visible
