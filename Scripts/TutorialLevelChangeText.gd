extends RichTextLabel

@export var player : PlayerController
@export var circle_transition : AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player.max_health != 6:
		visible = true
		if player.max_health < 5 && !player.rewinding:
			circle_transition.play("scale_up")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "scale_up":
		get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
