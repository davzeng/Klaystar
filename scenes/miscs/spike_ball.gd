extends Area2D

func _on_Area2D_body_entered(body):
	if body.name == "Klay":#kills player
		if get_node("..") && get_node("..").is_processing():
			body.dead = true
