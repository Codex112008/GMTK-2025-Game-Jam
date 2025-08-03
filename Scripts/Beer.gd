extends Area2D

@export var beer_strength : float = 0.5
@export var camera_offset_amount : float = 1

@export var anim_player : AnimationPlayer
@export var drink_sound : SoundPlayer
@export var wait_delete : Timer

func _ready():
	anim_player.play("sine")

func _on_body_entered(body):
	var player : PlayerController = body as PlayerController
	if player != null:
		player.curve_shader_strength += beer_strength
		player.camera.offset += Vector2.UP * camera_offset_amount
		player.max_health -= 1
		var reversed_health_ui_container_children = player.health_ui_container.get_children()
		reversed_health_ui_container_children.reverse()
		for health_icon : HealthIcon in reversed_health_ui_container_children:
			if health_icon.is_beer == false:
				health_icon.is_beer = true
				break
		for health_icon : HealthIcon in player.health_ui_container.get_children():
			health_icon.is_full = true
			
		player.current_health = player.max_health
		
		position = Vector2(100000, 0)

		drink_sound.global_position = player.global_position

		drink_sound.play_sound()
			
		player.drink()
		player.start_rewind()
		
		wait_delete.start()


func _on_wait_delete_timeout() -> void:
	queue_free()
