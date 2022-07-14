extends Node2D

var camera:Node

var activeBound :Node
var no_interp :bool = false
var bound_updated :bool = false
var misc_updated :bool = false

func _enter_tree():
	camera = get_tree().current_scene._get_player_camera()

func _physics_process(_delta):
	if !bound_updated:#updates bounds
		if activeBound && activeBound._switch():#all bounds check if they are new
			bound_updated = true
			return
		for node in get_children():
			if node._switch():
				bound_updated = true
				break#updated if a new bound is set
		
	if !misc_updated:#updates misc
		for node in get_tree().get_nodes_in_group("BoundBased"):
			node._bound_changed(activeBound)
		for n in get_tree().get_nodes_in_group("Resettable"):
			n._reset()
		misc_updated = true

func _switch_bound(node):#sets new bound
	if activeBound == node:#no change
		return
	if !activeBound or no_interp:#no active bound
		activeBound = node
		camera.position = node.position + Vector2(960, 540)
	else:#changes bound
		activeBound = node
		camera._interp(node)
	misc_updated = false

func _set_no_interp(b):
	no_interp = b
