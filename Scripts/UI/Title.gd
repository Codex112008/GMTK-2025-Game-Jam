extends TextureRect

var starting_pos : Vector2

func _ready():
	starting_pos = position

var time_since_start : float = 0

func _process(delta: float) -> void:
	time_since_start += delta
	position.y = starting_pos.y + (5 * sin(time_since_start))

	if time_since_start > 2 * PI:
		time_since_start = 0
