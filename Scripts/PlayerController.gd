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
@export var dash_spritesheet : Texture2D
@export var jump_spritesheet : Texture2D

@export var max_nut_count : int = 2
@export var nut_count : int = 0
@export var nutted_trees : Array[TreeNode] = []
@export var thrown_nut : PackedScene

@export var curve_speed : float = 5.0
var curve_shader_strength : float = 1

var rewinding : bool = false
@export var rewindAcceleration : float = 10
var starting_point : Vector2
var passed_out : bool = false

var last_frame_on_floor : bool
var last_frame_y_velocity : float

var dir : int

@export var flash_color : Color
@export var health_icon_scene : PackedScene
@export var starting_max_health : int = 6
var max_health : int
var current_health : int

var next_tilemap_index : int = 1

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
@export var collect_sound : SoundPlayer
@export var win_sound : SoundPlayer

@export_group("OOC References")
@export var curve_effect_rect : CanvasItem
@export var camera : CameraFollow
@export var instantiated_nodes : Node2D
@export var health_ui_container : Control
@export var crt_canvas_layer : CanvasLayer
@export var audio_manager : AudioManager
@export var tilemaps_parent : TilemapsParent
@export var win_screen : Control
@export var map_icons : Array[CompressedTexture2D]
@export var map : TextureRect

func _ready():
	Engine.time_scale = 1
	curve_shader_strength = (curve_effect_rect.material as ShaderMaterial).get_shader_parameter("distortion_strength")
	
	starting_point = position
	
	max_health = starting_max_health
	current_health = max_health
	for i in range(0, starting_max_health):
		var health_icon : HealthIcon = health_icon_scene.instantiate()
		health_icon.position = Vector2(i * 42, 0)
		health_icon.z_index = -i
		health_ui_container.add_child(health_icon)
	
	if map != null:
		map.texture = map_icons[0]

func _process(delta : float) -> void:
	var shader_material : ShaderMaterial = curve_effect_rect.material as ShaderMaterial
	if shader_material != null:
		shader_material.set_shader_parameter("distortion_strength", max(0, lerpf(shader_material.get_shader_parameter("distortion_strength"), curve_shader_strength, curve_speed * delta)))
	
	if max_health <= 0 && !passed_out:
		passed_out = true
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
		
	# Nut dash
	if nut_count > 0 && Input.is_action_just_pressed("dash") && !rewinding && drink_timer.time_left == 0:
		jump_sound.play_sound()
		
		camera.apply_shake(0.2)
		remove_oldest_nut()
		dashing = true
		velocity_before_dash = velocity.x
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
		dashing = false
	
	if dashing:
		velocity.y = 0
	
	# Nut jump
	if nut_count > 0 && not is_on_floor() && Input.is_action_just_pressed("jump") && !did_coyote:
		#afterimage_particles.emitting = true
		spin_timer.start()
		jump()
		remove_oldest_nut()

		camera.apply_shake(0.1)

		# Throw nut downward for visual feedback
		var new_nut : ThrownNutScript = thrown_nut.instantiate()
		new_nut.global_position = global_position
		instantiated_nodes.add_child(new_nut)
	
	if spin_timer.time_left == 0 && not dashing:
		afterimage_particles.texture = dash_spritesheet
		afterimage_particles.emitting = false
	
	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("left", "right")
	run_particles.emitting = direction && is_on_floor() # if moving have running particles
	if direction && pre_rewind_timer.time_left == 0 && !dashing:
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
	
	velocity = Vector2(clamp(velocity.x, -3000, 3000), clamp(velocity.y, -5000, 1250))
	
	move_and_slide()
	
	# Gets nuts from trees
	for i in get_slide_collision_count():
		var collidingTree : TreeNode = get_slide_collision(i).get_collider() as TreeNode
		if collidingTree != null && collidingTree.has_nut && nutted_trees.size() < max_nut_count:
			collect_sound.play_sound()
			nut_count = mini(nut_count + 1, max_nut_count)
			collidingTree.has_nut = false
			collidingTree.empty = true
			nutted_trees.append(collidingTree)
		
		if i_frame_timer.time_left == 0:
			var colliding_tilemap : TileMapLayer = get_slide_collision(i).get_collider() as TileMapLayer
			if colliding_tilemap != null:
				var collision_point : Vector2 = get_slide_collision(i).get_position()
				var tile_coords : Vector2i = colliding_tilemap.local_to_map(colliding_tilemap.to_local(collision_point))
				var tile_data : TileData = colliding_tilemap.get_cell_tile_data(tile_coords)
				if tile_data != null && tile_data.get_custom_data("IsSpike") == true:
					take_damage(tile_coords * 32 + Vector2i(16, 16))

	# set audio bus effect
	audio_manager.bus_effect(rewinding)

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
	
	if dashing:
		dashing = false
		velocity.x *= 1.4
		print(str(velocity.x))
		dash_timer.stop()
		if spin_timer.time_left == 0:
			afterimage_particles.texture = jump_spritesheet
			afterimage_particles.emitting = true
			spin_timer.start()
	
func remove_oldest_nut():
	nutted_trees[0].grow()
	nutted_trees.remove_at(0)
	nut_count -= 1

func start_rewind():
	Engine.time_scale = 0.5
	if Settings.crt_on:
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
	if i_frame_timer.time_left == 0 && !rewinding:
		# juice
		hurt_sound.play_sound()
		camera.apply_shake(3)
		hit_particles.restart()
		hit_particles.emitting = true

		i_frame_timer.start()
		current_health -= 1
		var icon : HealthIcon = health_ui_container.get_child(current_health)
		icon.is_full = false
		if current_health <= 0:
			current_health = max_health
			for health_icon : HealthIcon in health_ui_container.get_children():
				health_icon.is_full = true
			start_rewind()
		else:
			var dir_to_spike : Vector2 = -global_position.direction_to(spike_pos)
			var dir : Vector2i = Vector2i(roundi(dir_to_spike.x), roundi(dir_to_spike.y))
			velocity = dir * jump_strength

func drink():
	if map != null and next_tilemap_index < map_icons.size():
		map.texture = map_icons[next_tilemap_index]
	if next_tilemap_index < tilemaps_parent.get_child_count():
		for tilemap in tilemaps_parent.get_child(next_tilemap_index).get_children():
			tilemap.enabled = true
		next_tilemap_index += 1
	tilemaps_parent.grass_spawner.GenerateGrass()
	drink_timer.start()

func pass_out():
	win_sound.play_sound()
	var win_animplayer : AnimationPlayer = win_screen.get_child(-1) as AnimationPlayer
	win_animplayer.play("win_anim")

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
