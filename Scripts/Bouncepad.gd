extends Area2D

@export var strength : float = 800

@export var my_sprite : AnimatedSprite2D

func _on_body_entered(body:Node2D) -> void:
	if body is PlayerController:
		body.velocity.y = -strength
		my_sprite.play("bounce")
		body.camera.apply_shake(0.1)
