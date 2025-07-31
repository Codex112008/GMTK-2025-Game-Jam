extends CharacterBody2D


@export var speed : float = 300.0
@export var acceleration : float = 10.0
@export var jump_strength : float = 400.0
@export var gravity : float = 1600.0
@export var friction : float = 20.0 # Basically deceleration

@export_group("References")
@export var coyote_timer : Timer
@export var jump_buffer_timer : Timer
@export var short_jump_timer : Timer

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		if velocity.y < 0:
			velocity += Vector2.DOWN * gravity * delta
		else: # Fast gravity if already moving down
			velocity += Vector2.DOWN * gravity * 2 * delta
	
	
	# Start coyote time before walking off edges and buffer timer if jump is clicked before landing
	if is_on_floor():
		coyote_timer.start()
	elif Input.is_action_just_pressed("jump"):
		jump_buffer_timer.start()
	
	# Still jump if have cyote time or buffered jump
	if coyote_timer.time_left != 0 and Input.is_action_just_pressed("jump"):
		jump()
		coyote_timer.stop()
	if jump_buffer_timer.time_left != 0 and is_on_floor():
		jump()
		jump_buffer_timer.stop()
	
	# If release jump quiclky then add downward force for variable jump height
	# mark brown told me to do this i did the platformer toolkit thingie
	if (Input.is_action_just_released("jump") && short_jump_timer.time_left != 0):
		velocity.y += jump_strength / 2 # this value can be tweaked


	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = lerpf(velocity.x, direction * speed, delta * acceleration)
	else:
		velocity.x = lerpf(velocity.x, 0, delta * friction)

	move_and_slide()

func jump():
	short_jump_timer.start()
	velocity.y = -jump_strength;
	# velocity.y = -jump_strength
