extends Path2D

@export var movespeed : float = 10

@export_group("References")
@export var path_follow : PathFollow2D

var timesincestart : float = 0

func _process(delta):
	timesincestart += movespeed * delta
	
	path_follow.progress_ratio = (sin(timesincestart + ((3 * PI) / 2)) + 1) / 2

	if timesincestart >= 2 * PI:
		timesincestart = 0
