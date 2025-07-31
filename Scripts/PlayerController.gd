extends CharacterBody2D
class_name PlayerController

@export var speed : float = 300.0
@export var acceleration : float = 10.0
@export var jump_strength : float = 600.0
@export var gravity : float = 1600.0
@export var friction : float = 20.0 # Basically deceleration

@export var max_nut_count : int = 2
var nut_count : int = 0
var nutted_trees : Array[TreeNode] = []

@export var curve_speed : float = 5.0
var curve_shader_radius : float

@export_group("References")
@export var coyote_timer : Timer
@export var jump_buffer_timer : Timer
@export var short_jump_timer : Timer

@export_group("OOC References")
@export var curve_effect_rect : CanvasItem
@export var camera : Camera2D

func _ready():
	curve_shader_radius = (curve_effect_rect.material as ShaderMaterial).get_shader_parameter("radius")

func _process(delta : float) -> void:
	var shader_material : ShaderMaterial = curve_effect_rect.material as ShaderMaterial
	if shader_material != null:
		shader_material.set_shader_parameter("radius", max(0, lerpf(shader_material.get_shader_parameter("radius"), curve_shader_radius, curve_speed * delta)))

func _physics_process(delta : float) -> void:
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
	if Input.is_action_just_released("jump") && short_jump_timer.time_left != 0:
		velocity.y += jump_strength / 2 # this value can be tweaked
	
	if nut_count > 0 && not is_on_floor() && Input.is_action_just_pressed("jump"):
		jump()
		nutted_trees[0].has_nut = true
		nutted_trees.remove_at(0)
		nut_count -= 1
	


	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = lerpf(velocity.x, direction * speed, delta * acceleration)
	else:
		velocity.x = lerpf(velocity.x, 0, delta * friction)
		
	
	# Drop down one way platforms
	if Input.is_action_pressed("down") && is_on_floor():
		position.y += 1


	move_and_slide()
	
	# Gets nuts from trees
	for i in get_slide_collision_count():
		var collidingTree : TreeNode = get_slide_collision(i).get_collider() as TreeNode
		if collidingTree != null && collidingTree.has_nut && nutted_trees.size() < max_nut_count:
			nut_count = mini(nut_count + 1, max_nut_count)
			collidingTree.has_nut = false
			nutted_trees.append(collidingTree)

func jump():
	short_jump_timer.start()
	velocity.y = -jump_strength;
	# velocity.y = -jump_strength
