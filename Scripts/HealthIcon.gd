extends TextureRect
class_name HealthIcon

@export var full : Texture2D
@export var empty : Texture2D

var is_full : bool = true

func _ready() -> void:
	texture = full


func _process(delta: float) -> void:
	if is_full:
		texture = full
	else:
		texture = empty
