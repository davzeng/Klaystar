extends Area2D


var player :Node#player
var active :bool = false

func _ready():
	player = get_tree().current_scene._get_player()#sets player
	
func _physics_process(_delta):
	if not active:#checks if the bound is active
		return
	if get_node("..").activeBound != self:#deactives bound if active bound has changed
		active = false
		return
	if not overlaps_area(player.get_node("BoundDetect")):#detects player exiting
		get_node("..").bound_updated = false
	
func _switch() -> bool:#sees if this is the new bound
	if overlaps_area(player.get_node("BoundDetect")):
		get_node("..")._switch_bound(self)
		active = true
		return true
	return false

#getters
func _Rect() -> Node:
	return $Rect
