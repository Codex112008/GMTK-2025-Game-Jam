extends CanvasLayer

@export var star_types : Array = []

@export var star_scene : PackedScene

@export var foreground_stars : int = 15
@export var midground_stars : int = 25
@export var background_stars : int = 50

@export_group("References")
@export var frontmost : ParallaxLayer
@export var midground : ParallaxLayer
@export var backmost : ParallaxLayer

var ran : RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	for i in range(0, foreground_stars):
		var new_star = create_star()
		frontmost.add_child(new_star)

	for i in range(0, midground_stars):
		var new_star = create_star()
		midground.add_child(new_star)
	
	for i in range(0, background_stars):
		var new_star = create_star()
		backmost.add_child(new_star)


func create_star() -> Sprite2D:
	var new_star : Sprite2D = star_scene.instantiate()
	new_star.texture = star_types.pick_random()
	new_star.position = Vector2(ran.randi_range(-640, 640), ran.randi_range(-360, 360))
	new_star.z_index = -1

	return new_star
