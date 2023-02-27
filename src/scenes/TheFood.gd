extends Node2D

func _ready():
	$Decoration.visible = false

func show_decoration():
	$Decoration/AnimatedSprite.play("default")
	$Decoration/AnimatedSprite2.play("default")
	$Decoration.visible = true
