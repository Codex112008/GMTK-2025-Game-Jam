extends Area2D

@export var strength : float = 800

@export var my_sprite : AnimatedSprite2D
@export var bounce_sound : SoundPlayer

@export var tutorial = false

func _ready():
	if !tutorial:
		var tilemap : MainTliemap = get_tree().get_nodes_in_group("MainTileMap")[0]
		var dupe = duplicate()
		dupe.set_script(null)
		add_child(dupe)
		dupe.position.x = tilemap.get_rect_world_pos_x()
		
		dupe = duplicate()
		dupe.set_script(null)
		add_child(dupe)
		dupe.position.x = -tilemap.get_rect_world_pos_x()

func _on_body_entered(body:Node2D) -> void:
	if body is PlayerController:
		bounce_sound.play_sound()
		body.velocity.y = -strength
		my_sprite.play("bounce")
		body.camera.apply_shake(0.1)
