@tool
extends Node2D
class_name GrassSpawner

@export_tool_button("Generate Grass", "Callable") var generate_action = GenerateGrass
@export_tool_button("Remove Grass", "Callable") var remove_action = RemoveGrass

@export var tilemaps : Array[TileMapLayer]
@export var grass_scene : PackedScene

func GenerateGrass():
	RemoveGrass()
	
	var rng : RandomNumberGenerator = RandomNumberGenerator.new()
	randomize()
	
	for i in range(0, tilemaps.size()):
		if i % 3 == 0 && tilemaps[i].enabled:
			for tile : Vector2i in tilemaps[i].get_used_cells():
				var cell_above : Vector2i = tilemaps[i].get_neighbor_cell(tile, TileSet.CELL_NEIGHBOR_TOP_SIDE)
				if tilemaps[i].get_cell_source_id(cell_above) == -1 && tilemaps[i].get_cell_tile_data(tile).get_custom_data("IsGrassy"):
					var sprite_frame : Array[int] = [rng.randi() % 6, rng.randi() % 6]
					var wind_offset : Array[int] = [rng.randi() % 3, rng.randi() % 3]
					for tilemap : TileMapLayer in tilemaps:
						var grass_instance : Area2D = grass_scene.instantiate()
						grass_instance.global_position = Vector2(tile * 32 + Vector2i(8, 0)) + tilemap.global_position
						grass_instance.anim_sprite.frame = sprite_frame[0]
						grass_instance.anim_sprite.material.set("shader_parameter/offset", wind_offset[0])
						add_child(grass_instance)
						
						grass_instance = grass_scene.instantiate()
						grass_instance.global_position = Vector2(tile * 32 + Vector2i(24, 0)) + tilemap.global_position
						grass_instance.anim_sprite.frame = sprite_frame[1]
						grass_instance.anim_sprite.material.set("shader_parameter/offset", wind_offset[1])
						add_child(grass_instance)
		

func RemoveGrass():
	for child in get_children():
		child.queue_free()
