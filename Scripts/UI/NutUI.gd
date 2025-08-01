extends Control

@export var player : PlayerController
@export var offset : Vector2
@export var nut_icon : PackedScene

const NUTSIZE : float = 12

var num_nuts = 0

var nuts : Array = []

func _process(delta: float) -> void:
	# go to correct position
	position = player.get_global_transform_with_canvas().origin + offset

	# update number of nuts
	if num_nuts != player.nut_count:
		create_nuts()
	num_nuts = player.nut_count

func create_nuts():
	for nut in nuts:
		var my_nut : Control = nut
		my_nut.queue_free()
	
	nuts.clear()

	for nut_on in range(0, player.nut_count):
		var new_icon : TextureRect = nut_icon.instantiate()
		var offset_num : int = nut_on - player.nut_count

		new_icon.position = Vector2(0, offset_num * NUTSIZE)

		nuts.append(new_icon)
		add_child(new_icon)
