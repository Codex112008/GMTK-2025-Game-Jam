extends AnimatedSprite2D

@export var player : PlayerController
@export var cheeks : Sprite2D

var show_cheeks : bool = true

func _process(delta: float) -> void:
	if player.drink_timer.time_left != 0:
		play("drink")
		show_cheeks = true
	else:
		if player.is_on_floor() && Input.get_axis("left", "right") != 0:
			play("walk")
			show_cheeks = true;
		elif player.is_on_floor():
			play("idle")
			show_cheeks = true;
		elif !player.is_on_floor():
			if player.spin_timer.time_left != 0:
				play("spin")
				show_cheeks = false;
			elif player.dash_timer.time_left != 0:
				play("dash")
				show_cheeks = false;
			else:
				if player.velocity.y > 0:
					play("fall")
					show_cheeks = true;
				else:
					play("rise")
					show_cheeks = true;
	
	cheeks.visible = show_cheeks && player.nut_count > 0

	flip_h = (player.dir != 1) # flip sprite
	cheeks.flip_h = flip_h
