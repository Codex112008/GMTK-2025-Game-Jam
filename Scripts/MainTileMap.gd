extends TileMapLayer
class_name MainTliemap

@export var camera : Camera2D
@export var instantiated_nodes : Node2D
@export var player : PlayerController
@export var grass_spawner : GrassSpawner

var left_tilemap_clone : TileMapLayer
var right_tilemap_clone : TileMapLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	# duplicate level
	left_tilemap_clone = duplicate()
	left_tilemap_clone.position.x -= get_rect_world_pos_x()
	left_tilemap_clone.set_script(null)
	instantiated_nodes.add_child(left_tilemap_clone)
	grass_spawner.tilemaps.append(left_tilemap_clone)
	
	right_tilemap_clone = duplicate()
	right_tilemap_clone.position.x += get_rect_world_pos_x()
	right_tilemap_clone.set_script(null)
	instantiated_nodes.add_child(right_tilemap_clone)
	grass_spawner.tilemaps.append(right_tilemap_clone)
	
	grass_spawner.GenerateGrass()

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
