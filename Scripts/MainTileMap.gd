extends TileMapLayer
class_name MainTliemap

@export var camera : Camera2D
@export var player : PlayerController

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player.global_position.x > get_rect_world_pos_x() / 2:
		player.global_position.x -= get_rect_world_pos_x()
		camera.global_position.x -= get_rect_world_pos_x()
		camera.reset_physics_interpolation()
		move_thrown_nuts(false)
	elif player.global_position.x < -get_rect_world_pos_x() / 2:
		player.global_position.x += get_rect_world_pos_x()
		camera.global_position.x += get_rect_world_pos_x()
		camera.reset_physics_interpolation()
		move_thrown_nuts(true)

func get_rect_world_pos_x() -> float:
	return get_used_rect().size.x * 32
	
func move_thrown_nuts(left : bool) -> void:
	var thrown_nuts : Array[Node] = get_tree().get_nodes_in_group("ThrownNut")
	for nut in thrown_nuts:
		var nut_node = nut as Node2D
		if left:
			nut_node.position.x += get_rect_world_pos_x()
		else:
			nut_node.position.x -= get_rect_world_pos_x()
