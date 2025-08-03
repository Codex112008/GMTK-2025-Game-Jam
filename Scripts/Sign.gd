extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var tilemap : MainTliemap = get_tree().get_nodes_in_group("MainTileMap")[0]
	var dupe_1 = duplicate()
	dupe_1.set_script(null)
	add_child(dupe_1)
	dupe_1.global_position = global_position + Vector2(tilemap.get_rect_world_pos_x(), 0)
	dupe_1.global_rotation = global_rotation
	
	var dupe_2 = dupe_1.duplicate()
	add_child(dupe_2)
	dupe_2.global_position = global_position - Vector2(-tilemap.get_rect_world_pos_x(), 0)
	dupe_2.global_rotation = global_rotation
