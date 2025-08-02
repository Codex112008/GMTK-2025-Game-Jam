@tool
extends Node2D

@export_tool_button("Generate Grass", "Callable") var generate_action = GenerateGrass
@export_tool_button("Remove Grass", "Callable") var remove_action = RemoveGrass

@export var tilemap : MainTliemap
@export var grass_scene : PackedScene

func GenerateGrass():
	RemoveGrass()
		
	for tile : Vector2i in tilemap.get_used_cells():
		var cell_above : Vector2i = tilemap.get_neighbor_cell(tile, TileSet.CELL_NEIGHBOR_TOP_SIDE)
		if tilemap.get_cell_source_id(cell_above) == -1:
			var grass_instance : Area2D = grass_scene.instantiate()
			grass_instance.global_position = tile * 32 + Vector2i(8, 0)
			add_child(grass_instance)
			
			grass_instance = grass_scene.instantiate()
			grass_instance.global_position = tile * 32 + Vector2i(24, 0)
			add_child(grass_instance)

func RemoveGrass():
	for child in get_children():
		child.queue_free()
