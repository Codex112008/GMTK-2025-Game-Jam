extends Camera2D

@export var y_smooth_speed : float = 5.0
@export var target : Node2D

@export var level : MainTliemap

const TILESIZE : float = 32

func _ready() -> void:
	var level_rect : Rect2i = level.get_used_rect()
	
	limit_top = (level_rect.position.y * TILESIZE) + (3 * TILESIZE)
	limit_bottom = ((level_rect.size.y + level_rect.position.y) * TILESIZE) - (2 * TILESIZE)

	

func _physics_process(delta):
	global_position = global_position.lerp(target.global_position, y_smooth_speed * delta)
