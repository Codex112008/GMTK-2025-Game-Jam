extends StaticBody2D
class_name TreeNode

var has_nut : bool = true
var empty : bool = false

@export var tutorial = false
@export var anim_player : AnimationPlayer

func _ready():
	if !tutorial:
		var tilemap : MainTliemap = get_tree().get_nodes_in_group("MainTileMap")[0]
		var dupe_1 = duplicate()
		dupe_1.set_script(null)
		add_child(dupe_1)
		dupe_1.position = Vector2(tilemap.get_rect_world_pos_x(), 0)
		
		var dupe_2 = dupe_1.duplicate()
		add_child(dupe_2)
		dupe_2.position = Vector2(-tilemap.get_rect_world_pos_x(), 0)

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
