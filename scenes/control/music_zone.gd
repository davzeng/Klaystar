extends Area2D

export var track :String
var player :Node#player

func _ready():
	player = get_tree().current_scene._get_player()#sets player
	
func _on_MusicZone_body_entered(body):
	if body == player:
		MusicPlayer._play(track)
		
func _on_MusicZone_body_exited(body):
	pass
	#if body == player:
	#	MusicPlayer.stop()
