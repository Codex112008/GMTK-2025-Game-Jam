extends CharacterBody2D

@export var spin_speed : float = 10
@export var gravity : float = 900
@export var start_fall_speed : float = 50

@export_group("references")
@export var my_sprite : AnimatedSprite2D

var do_spin : bool = true

func _ready() -> void:
	velocity = Vector2.DOWN * start_fall_speed
	my_sprite.play("default")

func _process(delta: float) -> void:
	# gravity
	velocity += Vector2.DOWN * gravity * delta

	# spin
	if do_spin:
		my_sprite.rotation += spin_speed * delta


	move_and_slide()

	# destroy on collision
	if get_slide_collision_count() > 0 && do_spin:
		do_spin = false
		my_sprite.rotation = 0
		my_sprite.play("destroy")


func _on_alive_timer_timeout() -> void:
	queue_free()
