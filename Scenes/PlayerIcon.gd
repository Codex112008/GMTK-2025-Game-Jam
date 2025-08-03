extends TextureRect

@export var tilemap : TileMapLayer
@export var player : PlayerController

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = Vector2(tilemap.local_to_map(player.position)) + Vector2(34.5, 67)
