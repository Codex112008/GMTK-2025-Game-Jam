extends TextureButton

@export var circle_transition : AnimationPlayer
@export var sound_player : SoundPlayer

var starting_pos : Vector2
var was_pressed : bool = false

# shake
@export var rngStrength : float= 30;
@export var shakeFade : float = 5;
var shakeStrength : float = 0;

var rng : RandomNumberGenerator = RandomNumberGenerator.new();

func _ready():
	Engine.time_scale = 1
	starting_pos = position

func _process(delta):
	if (shakeStrength > 0): # actual shake
		shakeStrength = lerp(shakeStrength, 0.0, shakeFade * delta);
		position = starting_pos + rng_offset()

	if (shakeStrength <= 1): # stop at really small values
		shakeStrength = 0;
		position = starting_pos


func apply_shake(multiplier : float) -> void:
	shakeStrength += rngStrength * multiplier

func reset_shake() -> void:
	shakeStrength = 0;

func rng_offset() -> Vector2:
	return Vector2(rng.randf_range(-shakeStrength, shakeStrength), rng.randf_range(-shakeStrength, shakeStrength))


func _on_pressed():
	(circle_transition.get_parent() as TextureRect).set_global_position(get_global_mouse_position() + Vector2(24, 24))
	circle_transition.play("scale_up")
	apply_shake(0.5)
	sound_player.play_sound()
	was_pressed = true


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "scale_up" && was_pressed:
		get_tree().reload_current_scene()
