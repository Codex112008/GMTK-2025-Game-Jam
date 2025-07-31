extends TileMapLayer

@export var tilemap_parent : Node2D
@export var player : PlayerController

var camera : Camera2D
var left_tilemap_clone : TileMapLayer
var right_tilemap_clone : TileMapLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	camera = player.get_child(-1) as Camera2D
	
	left_tilemap_clone = duplicate()
	left_tilemap_clone.position.x -= get_rect_world_pos_x()
	left_tilemap_clone.set_script(null)
	tilemap_parent.add_child(left_tilemap_clone)
	
	right_tilemap_clone = duplicate()
	right_tilemap_clone.position.x += get_rect_world_pos_x()
	right_tilemap_clone.set_script(null)
	tilemap_parent.add_child(right_tilemap_clone)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player.position.x > get_rect_world_pos_x() / 2:
		player.position.x = -get_rect_world_pos_x() / 2
		move_thrown_nuts(false)
	elif player.position.x < -get_rect_world_pos_x() / 2:
		player.position.x = get_rect_world_pos_x() / 2
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
