extends CanvasLayer


func _ready():
	pass # Replace with function body.

func fade_in():
	$AnimationPlayer.play("Fade_In")

func fade_out():
	$AnimationPlayer.play("Fade_Out")



func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Fade_Out":
		return
