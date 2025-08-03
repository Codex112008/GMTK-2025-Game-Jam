extends Control

@export var player : PlayerController
@export var offset : Vector2
@export var nut_scale : int = 3
@export var nut_icon : PackedScene

const NUTSIZE : float = 10

var num_nuts = 0

var nuts : Array = []

func _process(delta: float) -> void:
	# go to correct position
	position = player.get_global_transform_with_canvas().origin + offset

	# update number of nuts
	if num_nuts != player.nut_count:
		create_nuts()
	num_nuts = player.nut_count

	# make nuts swing
	for nut in range(0, nuts.size()):
		var current : TextureRect = nuts[nut]
		current.position = Vector2(clamp((-player.velocity.x / 35) * (2 * nut), -pow(2 * nut, 2), pow(2 * nut, 2)) - player.velocity.x / 50, current.position.y)


func create_nuts():
	for nut in nuts:
		var my_nut : Control = nut
		my_nut.queue_free()
	
	nuts.clear()

	for nut_on in range(0, player.nut_count):
		var new_icon : TextureRect = nut_icon.instantiate()
		new_icon.scale = Vector2(nut_scale, nut_scale)

		new_icon.position = Vector2(0, -nut_on * NUTSIZE * nut_scale)

		nuts.append(new_icon)
		add_child(new_icon)
