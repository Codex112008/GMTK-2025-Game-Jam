extends Camera2D
class_name CameraFollow

@export var y_smooth_speed : float = 5.0
@export var target : Node2D

@export var level : MainTliemap

const TILESIZE : float = 32

func _ready() -> void:
	var level_rect : Rect2i = level.get_used_rect()
	
	limit_bottom = ((level_rect.size.y + level_rect.position.y) * TILESIZE) - (2 * TILESIZE)

	

func _physics_process(delta):
	global_position = global_position.lerp(target.global_position, y_smooth_speed * delta)


# screen shake
@export var rngStrength : float= 30;
@export var shakeFade : float = 5;
var shakeStrength : float = 0;

var rng : RandomNumberGenerator = RandomNumberGenerator.new();

func _process(delta):
	if (shakeStrength > 0): # actual shake
		shakeStrength = lerp(shakeStrength, 0.0, shakeFade * delta);
		offset = rng_offset();

	if (shakeStrength <= 1): # stop at really small values
		shakeStrength = 0;
		offset = Vector2(0, 0);


func apply_shake(multiplier : float) -> void:
	shakeStrength += rngStrength * multiplier

func reset_shake() -> void:
	shakeStrength = 0;

func rng_offset() -> Vector2:
	return Vector2(rng.randf_range(-shakeStrength, shakeStrength), rng.randf_range(-shakeStrength, shakeStrength))
