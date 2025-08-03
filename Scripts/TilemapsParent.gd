extends Node2D

@export var main_tile_map : MainTliemap
@export var grass_spawner : GrassSpawner

var tilemap_clone : TileMapLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	# duplicate level
	for child in get_children(false):
		var tilemap : TileMapLayer = child.get_child(0) as TileMapLayer
		if tilemap != null:
			tilemap_clone = tilemap.duplicate()
			tilemap_clone.set_script(null)
			child.add_child(tilemap_clone)
			tilemap_clone.global_position.x -= main_tile_map.get_rect_world_pos_x()
			grass_spawner.tilemaps.append(tilemap_clone)
			
			tilemap_clone = tilemap.duplicate()
			tilemap_clone.set_script(null)
			child.add_child(tilemap_clone)
			tilemap_clone.global_position.x += main_tile_map.get_rect_world_pos_x()
			grass_spawner.tilemaps.append(tilemap_clone)
	
	grass_spawner.GenerateGrass()
