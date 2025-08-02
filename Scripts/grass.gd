extends Area2D

var min_skew := -200
var max_skew := 200

@export var anim_sprite : AnimatedSprite2D
@export var pivot : Marker2D

func _ready() -> void:
	var rng : RandomNumberGenerator = RandomNumberGenerator.new()
	randomize()
	anim_sprite.material.set("shader_parameter/offset", rng.randi() % 3)
	anim_sprite.frame = rng.randi() % 6


func _on_Grass_body_entered(body: Node) -> void:
	if body as PlayerController != null:
		var direction = global_position.direction_to(body.global_position)
		var skew = clamp(remap(body.velocity.length() * sign(-direction.x), -body.velocity.x, body.velocity.x, min_skew, max_skew), min_skew, max_skew)
		var tween = create_tween()
		tween.tween_property(anim_sprite.material, "shader_parameter/skew", skew, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(anim_sprite.material, "shader_parameter/skew", 0.0, 3.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
