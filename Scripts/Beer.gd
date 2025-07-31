extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_body_entered(body):
	print("HGaeuygrfa")
	var player = body as PlayerController
	if player != null:
		player.increase_curve_effect(0.5)
