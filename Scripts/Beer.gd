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
			player.health_ui_container.get_child(-1).queue_free()
		else:
			for i in range(player.current_health, player.max_health):
				var health_icon : TextureRect = player.health_ui_container.get_child(0).duplicate()
				player.health_ui_container.add_child(health_icon)
		player.current_health = player.max_health
			
		player.drink()
		player.start_rewind()
		queue_free()
