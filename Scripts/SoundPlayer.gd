extends AudioStreamPlayer2D
class_name SoundPlayer

@export var sounds : Array
@export var sound_wait : float = 0.2
@export var base_pitch : float = 1
@export var wait_play_timer : Timer

var ran : RandomNumberGenerator = RandomNumberGenerator.new()

func _ready():
	wait_play_timer.wait_time = sound_wait

func play_sound():
	if wait_play_timer.time_left == 0:
		pitch_scale = base_pitch + ran.randf_range(-0.15, 0.15)

		var sound : AudioStream = sounds.pick_random()
		stream = sound

		play()
		wait_play_timer.start()
