extends Camera2D

@export var y_smooth_speed: float = 5.0
@export var target: Node2D

func _process(delta):
	global_position = Vector2(target.global_position.x, lerpf(global_position.y, target.global_position.y, y_smooth_speed * delta))
