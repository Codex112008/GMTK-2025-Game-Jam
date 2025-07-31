extends StaticBody2D
class_name TreeNode

var has_nut : bool = true
var empty : bool = false

@export var anim_player : AnimationPlayer

func _process(delta):
	# Omega band aid tb changed
	if (!anim_player.current_animation == "grow"):
		if (has_nut):
			anim_player.play("swing")
		elif (empty):
			anim_player.play("empty")
			empty = false

func grow():
	has_nut = true
	anim_player.play("grow")
