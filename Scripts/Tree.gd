extends StaticBody2D
class_name TreeNode

var has_nut : bool = true

@export var anim_player : AnimationPlayer

func _process(delta):
	# Omega band aid tb changed
	if !anim_player.current_animation == "grow":
		if (has_nut):
			anim_player.play("swing")
		elif (!has_nut && anim_player.current_animation != "empty"):
			anim_player.play("empty")

func grow():
	has_nut = true
	anim_player.play("grow")
