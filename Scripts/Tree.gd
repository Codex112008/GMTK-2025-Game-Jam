extends StaticBody2D
class_name TreeNode

var has_nut : bool = true
var empty : bool = false

@export var anim_player : AnimationPlayer

func _ready():
	var tilemap : MainTliemap = get_tree().get_nodes_in_group("MainTileMap")[0]
	var dupe = duplicate()
	dupe.set_script(null)
	add_child(dupe)
	dupe.position.x = tilemap.get_rect_world_pos_x()
	dupe.get_child(2).play("sine")
	
	dupe = duplicate()
	dupe.set_script(null)
	add_child(dupe)
	dupe.position.x = -tilemap.get_rect_world_pos_x()
	dupe.get_child(2).play("sine")

func _process(delta):
	# Omega band aid tb changed
	if (!anim_player.current_animation == "grow"):
		if (has_nut):
			anim_player.play("swing")
		elif (empty):
			anim_player.play("empty")
			empty = false

func grow():
	has_nut = true
	anim_player.play("grow")
