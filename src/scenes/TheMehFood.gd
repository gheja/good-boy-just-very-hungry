extends Node2D

var bites_left = 3

func _ready():
	$Decoration.visible = false

func one_bite():
	bites_left -= 1
	
	if bites_left == 0:
		queue_free()

func show_decoration():
	$Decoration/AnimatedSprite.play("default")
	$Decoration/AnimatedSprite2.play("default")
	$Decoration.visible = true
