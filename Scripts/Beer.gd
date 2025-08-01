extends Area2D

@export var beer_strength : float = 0.5
@export var camera_offset_amount : float = 1

@export var anim_player : AnimationPlayer

func _ready():
	anim_player.play("sine")

func _on_body_entered(body):
	var player : PlayerController = body as PlayerController
	if player != null:
		player.curve_shader_strength += beer_strength
		player.camera.offset += Vector2.UP * camera_offset_amount
		player.max_health -= 1
		if player.current_health > player.max_health:
			player.current_health = player.max_health
			player.health_ui_text.text = str(player.current_health)
		player.start_rewind()
		queue_free()
