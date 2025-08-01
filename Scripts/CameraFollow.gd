extends Camera2D

@export var y_smooth_speed : float = 5.0
@export var target : Node2D

@export var level : TileMapLayer

const TILESIZE : float = 32

func _ready() -> void:
	var level_rect : Rect2i = level.get_used_rect()
	
	limit_top = (level_rect.position.y * TILESIZE) + (3 * TILESIZE)
	limit_bottom = ((level_rect.size.y + level_rect.position.y) * TILESIZE) - (3 * TILESIZE)

	

func _process(delta):
	global_position = Vector2(target.global_position.x, lerpf(global_position.y, target.global_position.y, y_smooth_speed * delta))
