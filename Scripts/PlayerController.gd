extends CharacterBody2D
class_name PlayerController

@export var speed : float = 300.0
@export var acceleration : float = 10.0
@export var jump_strength : float = 600.0
@export var gravity : float = 1600.0
@export var friction : float = 20.0 # Basically deceleration

@export var max_nut_count : int = 2
@export var nut_count : int = 0
@export var nutted_trees : Array[TreeNode] = []
@export var thrown_nut : PackedScene

@export var curve_speed : float = 5.0
var curve_shader_strength : float

@export var beer_needed : int = 6
var beer_collected : int = 0

var rewinding : bool = false
@export var rewindAcceleration : float = 10
var starting_point : Vector2

var last_frame_on_floor : bool

@export_group("References")
@export var coyote_timer : Timer
@export var jump_buffer_timer : Timer
@export var short_jump_timer : Timer
@export var spin_timer : Timer
@export var my_sprite : AnimatedSprite2D
@export var time_rewinder : Rewinder
@export var collision_shape : CollisionShape2D

@export_subgroup("Particles")
@export var drunk_particles : CPUParticles2D
@export var jump_particles : CPUParticles2D
@export var land_particles : CPUParticles2D
@export var run_particles : CPUParticles2D

@export_group("OOC References")
@export var curve_effect_rect : CanvasItem
@export var camera : Camera2D
@export var instantiated_nodes : Node2D

func _ready():
	curve_shader_strength = (curve_effect_rect.material as ShaderMaterial).get_shader_parameter("distortion_strength")
	
	time_rewinder.done_rewinding.connect(enable_inputs)
	
	starting_point = position

func _process(delta : float) -> void:
	var shader_material : ShaderMaterial = curve_effect_rect.material as ShaderMaterial
	if shader_material != null:
		shader_material.set_shader_parameter("distortion_strength", max(0, lerpf(shader_material.get_shader_parameter("distortion_strength"), curve_shader_strength, curve_speed * delta)))
	
	if beer_collected >= 6:
		pass_out()

	# drunk particles
	if drunk_particles.amount != 1 + beer_collected:
		drunk_particles.amount = 1 + beer_collected
		drunk_particles.speed_scale = 0.5 + (0.5 * beer_collected)

func _physics_process(delta : float) -> void:
	# Add the gravity.
	if not is_on_floor() && !rewinding:
		if velocity.y < 0:
			velocity += Vector2.DOWN * gravity * delta
		else: # Fast gravity if already moving down
			velocity += Vector2.DOWN * gravity * 1.5 * delta
	
	
	# Start coyote time before walking off edges and buffer timer if jump is clicked before landing
	if is_on_floor():
		coyote_timer.start()
	elif Input.is_action_just_pressed("jump"):
		jump_buffer_timer.start()
	
	# Normal jump
	if Input.is_action_just_pressed("jump") && is_on_floor():
		jump()
		coyote_timer.stop()
	
	# Still jump if have cyote time or buffered jump
	var did_coyote : bool = false
	if coyote_timer.time_left != 0 and Input.is_action_just_pressed("jump") && !is_on_floor():
		jump()
		coyote_timer.stop()
		did_coyote = true
	if jump_buffer_timer.time_left != 0 and is_on_floor():
		jump()
		jump_buffer_timer.stop()
	
	# If release jump quiclky then add downward force for variable jump height
	# mark brown told me to do this i did the platformer toolkit thingie
	if Input.is_action_just_released("jump") && short_jump_timer.time_left != 0:
		velocity.y += jump_strength / 2 # this value can be tweaked
	
	if nut_count > 0 && not is_on_floor() && Input.is_action_just_pressed("jump") && !did_coyote:
		spin_timer.start()
		jump()
		remove_oldest_nut()

		# Throw nut downward for visual feedback
		var new_nut : ThrownNutScript = thrown_nut.instantiate()
		new_nut.global_position = global_position
		instantiated_nodes.add_child(new_nut)
	
	velocity = Vector2(clamp(velocity.x, -1000, 1000), clamp(velocity.y, -5000, 750))
	
	
	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("left", "right")
	run_particles.emitting = direction && is_on_floor() # if moving have running particles
	if direction:
		velocity.x = lerpf(velocity.x, direction * speed, delta * acceleration)
		my_sprite.flip_h = direction != 1 # flip sprite
	else:
		velocity.x = lerpf(velocity.x, 0, delta * friction)
	
	# Rewind
	if rewinding:
		velocity = Vector2.ZERO
		collision_shape.disabled = true
		motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
		position = lerp(position, starting_point, delta * rewindAcceleration)
		if position.distance_squared_to(starting_point) < 4.0:
			motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED
			collision_shape.disabled = false
			rewinding = false
			enable_inputs()
	
	# Drop down one way platforms
	if Input.is_action_pressed("down") && is_on_floor():
		position.y += 1
		
	# SQUISH
	if scale.x > 1.25 && scale.y < 0.75:
		scale = scale.lerp(Vector2.ONE, delta * 15)
	else:
		scale = scale.lerp(Vector2.ONE, delta * 5)
	if (!last_frame_on_floor && is_on_floor()):
		scale = Vector2(1.25, 0.75)
		land_particles.restart()
		land_particles.emitting = true
	if (!is_on_floor() && absf(velocity.y) > 500):
		scale = Vector2(0.75, 1.25)
	if (is_on_floor() && Input.is_action_pressed("down")):
		scale = Vector2(1.5, 0.5)
	last_frame_on_floor = is_on_floor()

	move_and_slide()
	
	# Gets nuts from trees
	for i in get_slide_collision_count():
		var collidingTree : TreeNode = get_slide_collision(i).get_collider() as TreeNode
		if collidingTree != null && collidingTree.has_nut && nutted_trees.size() < max_nut_count:
			nut_count = mini(nut_count + 1, max_nut_count)
			collidingTree.has_nut = false
			nutted_trees.append(collidingTree)

func jump():
	jump_particles.restart()
	jump_particles.emitting = true
	short_jump_timer.start()
	velocity.y = -jump_strength;
	# velocity.y = -jump_strength
	
func remove_oldest_nut():
	nutted_trees[0].grow()
	nutted_trees.remove_at(0)
	nut_count -= 1

func start_rewind():
	set_process_input(false)
	set_process_unhandled_input(false)
	for tree : TreeNode in nutted_trees:
		remove_oldest_nut()
	#time_rewinder.rewind()
	
	rewinding = true
	
func enable_inputs():
	set_process_input(true)
	set_process_unhandled_input(true)

func pass_out():
	print("LMAO good job drunkard")
	# win screen anims
