extends AnimatedSprite2D

@export var player : PlayerController

func _process(delta: float) -> void:
	if player.is_on_floor() && Input.get_axis("left", "right") != 0:
		play("walk")
	elif player.is_on_floor():
		play("idle")
	elif !player.is_on_floor():
		if player.spin_timer.time_left != 0:
			play("spin")
		else:
			if player.velocity.y > 0:
				play("fall")
			else:
				play("rise")
