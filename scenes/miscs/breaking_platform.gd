extends KinematicBody2D

export var area:Vector2 = Vector2(1,1)
var broken:bool = false
var player :Node
var pos:Vector2

func _ready():
	$CollisionShape2D.position = Vector2(32*area.x,32*area.y)
	$CollisionShape2D.scale = area
	
	player = get_tree().current_scene._get_player()
	pos = position
	
func _physics_process(delta):
	var collision = false
	
	var col = move_and_collide(Vector2(0,-1))
	position = pos
	if col && col.collider == player:
		collision = true
	
	if collision:#top
		if not broken && $Timer.is_stopped():
			if player.ball:
				player._y_amplify()
				$Timer.set_wait_time(0.2)
				$Timer.start()
			else:
				$Timer.set_wait_time(0.8)
				$Timer.start()
	else:
		col = move_and_collide(Vector2(1,0))
		position = pos
		if col && col.collider == player:
			collision = true
		
		col = move_and_collide(Vector2(-1,0))
		position = pos
		if col && col.collider == player:
			collision = true
		
		if collision:#side
			if not broken && $Timer.is_stopped():
				if player.ball:
					player._x_amplify()
					$Timer.set_wait_time(0.05)
					$Timer.start()
				else:
					$Timer.set_wait_time(0.8)
					$Timer.start()
	position = pos
	
func _reset():#sets position and state
	$Timer.stop()
	
	set_collision_layer_bit(1, true)#enable
	broken = false
	$Sprite.visible = true;
	$CollisionShape2D.visible = true;
	for n in get_children():
		n.set_process(true)
		n.set_physics_process(true)
		if not n is Timer:
			n.visible = true

func _on_Timer_timeout():
	if broken:#repair
		set_collision_layer_bit(1, true)#enable
		broken = false
		$Sprite.visible = true;
		$CollisionShape2D.visible = true;
		for n in get_children():
			n.set_process(true)
			n.set_physics_process(true)
			if not n is Timer:
				n.visible = true
		var col = move_and_collide(Vector2(0,-1))
		position = pos
		if col && col.collider == player:
			player.dead = true
		
	else:#break
		set_collision_layer_bit(1, false)#disable 
		broken = true
		$Sprite.visible = false;
		$CollisionShape2D.visible = false;
		for n in get_children():
			n.set_process(false)
			n.set_physics_process(false)
			if not n is Timer:
				n.visible = false
		$Timer.set_wait_time(4)#set time
		$Timer.start()
		
