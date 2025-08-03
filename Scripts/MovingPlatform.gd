extends Path2D

@export var move_speed : float = 1
@export var move_on_touch : bool = false

@export var tutorial = false

@export_group("References")
@export var path_follow : PathFollow2D
@export var move_sound : SoundPlayer

var moving : bool = true

func _ready():
	if move_on_touch:
		moving = false
	
	if !tutorial:
		var tilemap : MainTliemap = get_tree().get_nodes_in_group("MainTileMap")[0]
		var dupe = duplicate()
		dupe.set_script(null)
		add_child(dupe)
		dupe.position.x = tilemap.get_rect_world_pos_x()
		
		dupe = duplicate()
		dupe.set_script(null)
		add_child(dupe)
		dupe.position.x = -tilemap.get_rect_world_pos_x()

func _process(delta):
	if moving:
		path_follow.progress_ratio += move_speed * delta

	if path_follow.progress_ratio >= 0.98 && move_speed > 0:
		move_speed = -move_speed
		move_sound.play_sound()
	if path_follow.progress_ratio <= 0.02 && move_speed < 0:
		move_speed = -move_speed
		if move_on_touch:
			moving = false
		else:
			move_sound.play_sound()


func _on_player_check_body_entered(body:Node2D) -> void:
	if move_on_touch:
		move_sound.play_sound()
		moving = true
