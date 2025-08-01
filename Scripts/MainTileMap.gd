extends TileMapLayer
class_name MainTliemap

@export var instantiated_nodes : Node2D
@export var player : PlayerController

@export_group("Background")
@export var parallax_background : CanvasLayer

var camera : Camera2D
var left_tilemap_clone : TileMapLayer
var right_tilemap_clone : TileMapLayer

var left_parallax_clone : CanvasLayer
var right_parallax_clone : CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	camera = player.get_child(-1) as Camera2D
	
	# duplicate level
	left_tilemap_clone = duplicate()
	left_tilemap_clone.position.x -= get_rect_world_pos_x()
	left_tilemap_clone.set_script(null)
	instantiated_nodes.add_child(left_tilemap_clone)
	
	right_tilemap_clone = duplicate()
	right_tilemap_clone.position.x += get_rect_world_pos_x()
	right_tilemap_clone.set_script(null)
	instantiated_nodes.add_child(right_tilemap_clone)

	# duplicate background
	#left_parallax_clone = parallax_background.duplicate()
	#left_parallax_clone.offset.x -= get_rect_world_pos_x()
	#instantiated_nodes.add_child(left_parallax_clone)
#
	#right_parallax_clone = parallax_background.duplicate()
	#right_parallax_clone.offset.x += get_rect_world_pos_x()
	#instantiated_nodes.add_child(right_parallax_clone)


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
