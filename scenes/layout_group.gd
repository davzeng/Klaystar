extends Node2D

func _update_group(var boolean):#updates each node
	visible = boolean
	for node in get_children():
		if node is TileMap:
			node.set_collision_layer_bit(1, boolean)
			node.visible = boolean
		elif node is Node2D:
			for n in node.get_children():
				n.set_process(boolean)
				n.set_physics_process(boolean)
				n.visible = boolean
				if n.has_method("_update_node"):
					n._update_node(boolean)
			node.set_process(boolean)
			node.set_physics_process(boolean)
			node.visible = boolean
