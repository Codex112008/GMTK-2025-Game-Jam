extends Area2D

@export var strength : float = 800

func _on_body_entered(body:Node2D) -> void:
	if body is CharacterBody2D:
		body.velocity.y = -strength
