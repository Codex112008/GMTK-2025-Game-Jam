extends Control

@export var bubble : PackedScene

var ran : RandomNumberGenerator = RandomNumberGenerator.new()

func _on_spawn_timer_timeout() -> void:
	var new_bubble : Control = bubble.instantiate()
	new_bubble.position = Vector2(randf_range(-360, 360), 0)
	var new_scale : float = ran.randf_range(1, 2)
	new_bubble.scale = Vector2(new_scale, new_scale)

	new_bubble.z_index = -2
	add_child(new_bubble)
