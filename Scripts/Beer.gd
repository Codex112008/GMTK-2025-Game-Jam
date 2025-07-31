extends Area2D

@export var beer_strength : float = 0.5
@export var camera_offset_amount : float = 1

func _on_body_entered(body):
	var player : PlayerController = body as PlayerController
	if player != null:
		player.curve_shader_radius -= beer_strength
		player.camera.offset += Vector2.UP * camera_offset_amount
		queue_free()
