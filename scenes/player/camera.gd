extends Camera2D

var player:Node

func _ready():
	player = get_tree().current_scene._get_player()

func _interp(node):
	#moves camera
	player.transition = true
	if $Tween.is_active():
		$Tween.remove_all()
	var new = node.position + Vector2(960, 540)

	$Tween.interpolate_property(self, "position", position, new, 1.0, Tween.TRANS_QUAD, Tween.EASE_IN)
	$Tween.start()
	

func _on_Tween_tween_all_completed():
	#unpauses player transition
	player.transition = false
