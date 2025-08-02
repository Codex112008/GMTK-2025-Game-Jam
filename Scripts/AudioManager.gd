extends AudioStreamPlayer2D
class_name AudioManager

@export var music_normal : AudioStream
@export var music_reverse : AudioStream

func _ready() -> void:
	stream = music_normal
	play()
	bus_effect(false)

func bus_effect(enable : bool):
	var current_time : float = get_playback_position()
	if enable && stream != music_reverse:
		stream = music_reverse
		play(current_time)
	elif !enable && stream != music_normal:
		stream = music_normal
		play(current_time)

	for effect in range(0, AudioServer.get_bus_effect_count(1)):
		AudioServer.set_bus_effect_enabled(1, effect, enable)

func _on_finished() -> void:
	play()
