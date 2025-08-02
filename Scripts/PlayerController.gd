extends CharacterBody2D
class_name PlayerController

@export var speed : float = 300.0
@export var acceleration : float = 10.0
@export var jump_strength : float = 600.0
@export var dash_strength : float = 1000.0
@export var gravity : float = 1600.0
@export var friction : float = 20.0 # Basically deceleration
var velocity_before_dash : float
var dashing : bool = false

@export var max_nut_count : int = 2
@export var nut_count : int = 0
@export var nutted_trees : Array[TreeNode] = []
@export var thrown_nut : PackedScene

@export var curve_speed : float = 5.0
var curve_shader_strength : float = 1

var rewinding : bool = false
@export var rewindAcceleration : float = 10
var starting_point : Vector2

var last_frame_on_floor : bool
var last_frame_y_velocity : float

var dir : int

@export var flash_color : Color
@export var starting_max_health : int = 6
var max_health : int
var current_health : int

@export_group("References")
@export var coyote_timer : Timer
@export var jump_buffer_timer : Timer
@export var short_jump_timer : Timer
@export var spin_timer : Timer
@export var i_frame_timer : Timer
@export var drink_timer : Timer
@export var pre_rewind_timer : Timer
@export var dash_timer : Timer
@export var my_sprite : AnimatedSprite2D
@export var time_rewinder : Rewinder
@export var collision_shape : CollisionShape2D
@export var animation_player : AnimationPlayer

@export_subgroup("Particles")
@export var drunk_particles : CPUParticles2D
@export var jump_particles : CPUParticles2D
@export var land_particles : CPUParticles2D
@export var run_particles : CPUParticles2D
@export var hit_particles : CPUParticles2D
@export var afterimage_particles : GPUParticles2D

@export_subgroup("Sounds")
@export var footsteps_sound : SoundPlayer
@export var landing_sound : SoundPlayer
@export var hurt_sound : SoundPlayer
@export var jump_sound : SoundPlayer

@export_group("OOC References")
@export var curve_effect_rect : CanvasItem
@export var camera : CameraFollow
@export var instantiated_nodes : Node2D
@export var health_ui_text : RichTextLabel
@export var crt_canvas_layer : CanvasLayer

func _ready():
	curve_shader_strength = (curve_effect_rect.material as ShaderMaterial).get_shader_parameter("distortion_strength")
	
	time_rewinder.done_rewinding.connect(enable_inputs)
	
	starting_point = position
	
	max_health = starting_max_health
	current_health = max_health
	health_ui_text.text = str(current_health)

func _process(delta : float) -> void:
	var shader_material : ShaderMaterial = curve_effect_rect.material as ShaderMaterial
	if shader_material != null:
		shader_material.set_shader_parameter("distortion_strength", max(0, lerpf(shader_material.get_shader_parameter("distortion_strength"), curve_shader_strength, curve_speed * delta)))
	
	if max_health <= 0:
		pass_out()

	# drunk particles
	if drunk_particles.amount != 1 + starting_max_health - max_health:
		drunk_particles.amount = 1 + starting_max_health - max_health
		drunk_particles.speed_scale = 0.5 + (0.5 * (starting_max_health - max_health))

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
		afterimage_particles.emitting = true
		spin_timer.start()
		jump()
		remove_oldest_nut()

		camera.apply_shake(0.1)

		# Throw nut downward for visual feedback
		var new_nut : ThrownNutScript = thrown_nut.instantiate()
		new_nut.global_position = global_position
		instantiated_nodes.add_child(new_nut)
	
	if spin_timer.time_left == 0 && not dashing:
		afterimage_particles.emitting = false
	
	velocity = Vector2(clamp(velocity.x, -1000, 1000), clamp(velocity.y, -5000, 1250))
	
	
	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("left", "right")
	run_particles.emitting = direction && is_on_floor() # if moving have running particles
	if direction && pre_rewind_timer.time_left == 0:
		dir = direction
		if is_on_floor(): # footstep sounds
			footsteps_sound.play_sound()
		velocity.x = lerpf(velocity.x, direction * speed, delta * acceleration)
		
		if direction  < 0:
			afterimage_particles.scale.x = -1
		else:
			afterimage_particles.scale.x = 1
		
	else:
		velocity.x = lerpf(velocity.x, 0, delta * friction)
	
	# Rewind
	if rewinding:
		velocity = Vector2.ZERO
		collision_shape.disabled = true
		motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
		position = lerp(position, starting_point, delta * rewindAcceleration)
		if position.distance_squared_to(starting_point) < 4.0:
			Engine.time_scale = 1
			crt_canvas_layer.visible = false
			motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED
			collision_shape.disabled = false
			rewinding = false
			enable_inputs()
	
	# Drop down one way platforms
	if Input.is_action_pressed("down") && is_on_floor():
		position.y += 1
	
	# Nut dash
	if nut_count > 0 && Input.is_action_just_pressed("dash") && !rewinding && drink_timer.time_left == 0:
		camera.apply_shake(0.2)
		remove_oldest_nut()
		dashing = true
		velocity_before_dash = velocity.x
		set_process_input(false)
		set_process_unhandled_input(false)
		afterimage_particles.emitting = true
		dash_timer.start()
		
		var new_nut : ThrownNutScript = thrown_nut.instantiate()
		new_nut.global_position = global_position
		instantiated_nodes.add_child(new_nut)
		if !my_sprite.flip_h:
			new_nut.velocity.x = -new_nut.start_fall_speed
		else:
			new_nut.velocity.x = new_nut.start_fall_speed
			
		if !my_sprite.flip_h:
			velocity.x = dash_strength
		else:
			velocity.x = -dash_strength
	
	if dash_timer.time_left == 0 && dashing:
		velocity.x = velocity_before_dash
		afterimage_particles.emitting = false
		enable_inputs()
		dashing = false
	
	if dashing:
		velocity.y = 0
	
	# SQUISH
	if scale.x > 1.25 && scale.y < 0.75:
		scale = scale.lerp(Vector2.ONE, delta * 15)
	else:
		scale = scale.lerp(Vector2.ONE, delta * 5)
	if (!last_frame_on_floor && is_on_floor()):
		scale = Vector2(1.25, 0.75)
		land_particles.restart()
		landing_sound.play_sound()
		land_particles.emitting = true
	if (!is_on_floor() && absf(velocity.y) > 500):
		scale = Vector2(0.75, 1.25)
	if (is_on_floor() && Input.is_action_pressed("down")):
		scale = Vector2(1.5, 0.5)
	
	# Juice when hitting ground fast
	if !last_frame_on_floor && is_on_floor() && last_frame_y_velocity >= 1100:
		camera.apply_shake(0.3)
	
	# Flashing red
	if i_frame_timer.time_left != 0:
		animation_player.play("damage_flash")
	
	last_frame_on_floor = is_on_floor()
	last_frame_y_velocity = velocity.y
	
	move_and_slide()
	
	# Gets nuts from trees
	for i in get_slide_collision_count():
		var collidingTree : TreeNode = get_slide_collision(i).get_collider() as TreeNode
		if collidingTree != null && collidingTree.has_nut && nutted_trees.size() < max_nut_count:
			nut_count = mini(nut_count + 1, max_nut_count)
			collidingTree.has_nut = false
			collidingTree.empty = true
			nutted_trees.append(collidingTree)
		
		if i_frame_timer.time_left == 0:
			var colliding_tilemap : MainTliemap = get_slide_collision(i).get_collider() as MainTliemap
			if colliding_tilemap != null:
				var collision_point : Vector2 = get_slide_collision(i).get_position()
				var tile_coords : Vector2i = colliding_tilemap.local_to_map(colliding_tilemap.to_local(collision_point))
				var tile_data : TileData = colliding_tilemap.get_cell_tile_data(tile_coords)
				if tile_data != null && tile_data.get_custom_data("IsSpike") == true:
					take_damage(tile_coords * 32 + Vector2i(16, 16))

func jump():
	if !rewinding && drink_timer.time_left == 0:
		jump_particles.restart()
		jump_particles.emitting = true
		short_jump_timer.start()
		velocity.y = -jump_strength;
	jump_sound.play_sound()
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
	Engine.time_scale = 0.5
	crt_canvas_layer.visible = true
	velocity = Vector2.ZERO
	set_process_input(false)
	set_process_unhandled_input(false)
	pre_rewind_timer.start()
	# go to _on_pre_rewind_timeout() to see rewind code
	
func enable_inputs():
	set_process_input(true)
	set_process_unhandled_input(true)
	
func take_damage(spike_pos : Vector2):
	# juice
	hurt_sound.play_sound()
	camera.apply_shake(3)
	hit_particles.restart()
	hit_particles.emitting = true

	i_frame_timer.start()
	current_health -= 1
	health_ui_text.text = ": " + str(current_health)
	if current_health <= 0:
		start_rewind()
		current_health = max_health
		health_ui_text.text = ": " + str(current_health)
	else:
		var dir_to_spike : Vector2 = -global_position.direction_to(spike_pos)
		var dir : Vector2i = Vector2i(roundi(dir_to_spike.x), roundi(dir_to_spike.y))
		#print(":player pos: " + str(global_position) + " Spike pos: " + str(spike_pos))
		velocity = dir * jump_strength

func drink():
	drink_timer.start()

func pass_out():
	print("LMAO good job drunkard")
	# win screen anims

func _on_pre_rewind_timeout() -> void:
	set_process_input(false)
	set_process_unhandled_input(false)
	# reset number of nuts
	for tree in nutted_trees:
		var current_tree : TreeNode = tree as TreeNode
		current_tree.grow()
	nutted_trees.clear()
	nut_count = 0

	rewinding = true
