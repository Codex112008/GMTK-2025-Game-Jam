extends CharacterBody2D


@export var speed : float = 300.0
@export var jump_strength : float = 400
@export var gravity : float = 1600

@export_group("References")
@export var coyote_timer : Timer
@export var prejump_timer : Timer

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		if velocity.y < 0:
			velocity += Vector2.DOWN * gravity * delta
		else:
			velocity += Vector2.DOWN * gravity * 2 * delta

	# Handle jump.
	if is_on_floor():
		coyote_timer.start()
	elif Input.is_action_just_pressed("jump"):
		prejump_timer.start()
	
	# for jump consistency
	if coyote_timer.time_left != 0 and Input.is_action_just_pressed("jump"):
		jump()
		coyote_timer.stop()
	if prejump_timer.time_left !=0 and is_on_floor():
		jump()
		prejump_timer.stop()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()

func jump():
	velocity.y = -jump_strength;
	# velocity.y = -jump_strength
