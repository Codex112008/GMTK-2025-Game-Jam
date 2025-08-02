extends Node

var crt_on : bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	print(OS.get_name())
	if OS.has_feature("web_macos"):
		crt_on = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
