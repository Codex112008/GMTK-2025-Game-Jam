extends AudioStreamPlayer2D
class_name AudioManager

@export var master_bus : AudioBusLayout

func _ready() -> void:
	bus_effect(false)

func bus_effect(enable : bool):
	for effect in range(0, AudioServer.get_bus_effect_count(1)):
		AudioServer.set_bus_effect_enabled(1, effect, enable)

func _on_finished() -> void:
	play()
