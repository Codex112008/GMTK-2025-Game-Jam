extends TextureRect

@export var speed_scale : int = 50

const MAXSCALE = 3

func _process(delta: float) -> void:
	position.y -= (MAXSCALE - scale.x) * speed_scale * delta

	if position.y < -450:
		queue_free()


func _on_timer_timeout() -> void:
	queue_free()
