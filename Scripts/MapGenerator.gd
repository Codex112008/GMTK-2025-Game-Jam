@tool extends Node

@export_tool_button("generatemap", "Callable") var map_action = generatetilemap

@export var savepath : String
@export var mycolor : Color = Color(1, 1, 1, 1)
var tilemapimage : Image

var width : int
var height : int

@export var tilemaps : Array[TileMapLayer]

var offsetx : int = 0 # also functions as minx
var offsety : int = 0 # also functions as miny

func generatetilemap():
	for i in tilemaps[0].get_used_cells():
		if i.x < offsetx:
			offsetx = i.x
		if i.y < offsety:
			offsety = i.y
	
	width = tilemaps[0].get_used_rect().size.x
	height = tilemaps[0].get_used_rect().size.y
	
	# make even on pixel grid
	if width % 2 != 0:
		width += 1
	if height % 2 != 0:
		height += 1
	tilemapimage = Image.create(width, height, false, Image.FORMAT_RGBA8)
	
	# add actual map pixels
	for tilemap : TileMapLayer in tilemaps:
		if tilemap.enabled:
			for tile : Vector2i in tilemap.get_used_cells():
				if tilemap.get_cell_tile_data(tile).get_custom_data("IsSpike"):
					tilemapimage.set_pixel(tile.x + (offsetx * -1), tile.y + (offsety * -1), Color.RED)
				else:
					tilemapimage.set_pixel(tile.x + (offsetx * -1), tile.y + (offsety * -1), mycolor)
	
	# save image
	tilemapimage.save_png(savepath + "map.png")
	print("done generating " + savepath + "map.png")
