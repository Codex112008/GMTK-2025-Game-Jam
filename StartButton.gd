extends TextureButton

@export var main_scene : PackedScene
@export var circle_transition : AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_pressed():
	(circle_transition.get_parent() as TextureRect).set_global_position(get_global_mouse_position() + Vector2(24, 24))
	circle_transition.play("scale_up")


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "scale_up":
		get_tree().change_scene_to_packed(main_scene)
