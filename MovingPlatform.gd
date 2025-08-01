extends Path2D

@export var path_curve : Curve
var path_follow : PathFollow2D
var target_ratio : int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	path_follow = get_child(1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if abs(path_follow.progress_ratio - target_ratio) < 0.1:
		target_ratio = (target_ratio + 1) % 2
