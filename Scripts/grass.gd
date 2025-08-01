extends Area2D

var min_skew := -200
var max_skew := 200

@export var anim_sprite : AnimatedSprite2D

func _ready() -> void:
	randomize()
	anim_sprite.material.set("shader_param/offset", randi() % 3)
	anim_sprite.frame = randi() % 2
	var rng : RandomNumberGenerator = RandomNumberGenerator.new();
	$Pivot.position.y = randf_range(0, 5)


func _on_Grass_body_entered(body: Node) -> void:
	if body as CharacterBody2D != null:
		var direction = global_position.direction_to(body.global_position)
		var skew = clamp(remap(body.velocity.length() * sign(-direction.x), -body.velocity.x, body.velocity.x, min_skew, max_skew), min_skew, max_skew)
		var tween = create_tween()
		tween.tween_property(anim_sprite.material, "shader_parameter/skew", skew, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(anim_sprite.material, "shader_parameter/skew", 0.0, 3.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
