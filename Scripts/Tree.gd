extends StaticBody2D
class_name TreeNode

@export_group("Temp vars until animation stuff")
@export var nutSprite : Texture2D
@export var noNutSprite : Texture2D

var has_nut : bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Omega band aid tb changed
	if (has_nut):
		get_child(0).texture = nutSprite
	else:
		get_child(0).texture = noNutSprite
		
