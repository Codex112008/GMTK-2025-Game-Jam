extends Button

@export var un_muted_icon : Texture2D
@export var muted_icon : Texture2D

var muted : bool = false

func _process(delta):
	if muted:
		icon = muted_icon
	else:
		icon = un_muted_icon


func _on_pressed() -> void:
	release_focus()
	muted = !muted
	AudioServer.set_bus_mute(0, muted)
