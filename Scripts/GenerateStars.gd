extends CanvasLayer

@export var star_types : Array[Texture2D] = []

@export var star_scene : PackedScene

@export var foreground_stars : int = 15
@export var midground_stars : int = 25
@export var background_stars : int = 50

@export_group("References")
@export var frontmost : Parallax2D
@export var midground : Parallax2D
@export var backmost : Parallax2D

var ran : RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	for i in range(0, foreground_stars):
		var texture = star_types.pick_random()
		var position = Vector2(ran.randi_range(-440, 1240), ran.randi_range(-360, 360))
		var new_star = create_star(texture, position)
		frontmost.add_child(new_star)
		new_star.position = position

	for i in range(0, midground_stars):
		var texture = star_types.pick_random()
		var position = Vector2(ran.randi_range(-440, 1240), ran.randi_range(-360, 360))
		var new_star = create_star(texture, position)
		midground.add_child(new_star)
		new_star.position = position
		
	for i in range(0, background_stars):
		var texture = star_types.pick_random()
		var position = Vector2(ran.randi_range(-440, 1240), ran.randi_range(-360, 360))
		var new_star = create_star(texture, position)
		backmost.add_child(new_star)
		new_star.position = position


func create_star(texture : Texture2D, position : Vector2) -> Sprite2D:
	var new_star : Sprite2D = star_scene.instantiate()
	new_star.texture = texture
	new_star.z_index = -1

	return new_star
