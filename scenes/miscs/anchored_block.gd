extends KinematicBody2D
#area
export var area :Vector2 = Vector2(1, 1)
#forces
var MAX_UP_SPEED:float = 600.0
var MAX_DOWN_SPEED:float = 300.0
var gravity:float = 700.0

var velocity:Vector2 = Vector2(0,0)
#nodes
var player :Node
var init_pos :Vector2
#state
var reseted :bool

var state:int = 0
const STILL:int = 0
const UP:int = 1
const TOP:int = 2
const DOWN:int = 3
const Spike = preload("res://scenes/miscs/surface_spikes.gd") 

func _ready():
	set_physics_process(false)#pauses the node
	init_pos = position
	#sets children
	$Sprite.scale = area
	
	$Rect.position = Vector2(32*area.x, 32*area.y-0.05)
	$Rect.shape = $Rect.shape.duplicate()
	$Rect.shape.set_extents(Vector2(32*area.x-0.1, 32*area.y-0.05))
	
	$Top/Rect.position = Vector2(32*area.x, -0.5)
	$Top/Rect.shape = $Top/Rect.shape.duplicate()
	$Top/Rect.shape.set_extents(Vector2(32*area.x-0.1, 0.5))
	
	$Bottom/Rect.position = Vector2(32*area.x, 64*area.y+0.5)
	$Bottom/Rect.shape = $Top/Rect.shape.duplicate()
	$Bottom/Rect.shape.set_extents(Vector2(32*area.x-0.1, 0.5))
	
	player = get_tree().current_scene._get_player()

func _top_hit() -> bool:#checks if top is hit
	for node in $Top.get_overlapping_bodies():
		if node != self and node.get_collision_layer_bit(1):
			return true
	return false

func _bottom_hit() -> bool:#checks if bottom is hit
	for node in $Bottom.get_overlapping_bodies():
		if node != self and node.get_collision_layer_bit(1):
			return true
	return false

func _physics_process(delta) -> void:
	if state == UP:#up
		velocity.y -= gravity * delta#move
		velocity.y = max(velocity.y, -1*MAX_UP_SPEED)
		
		var col = move_and_collide(velocity*delta, true, true, true)
		
		if _top_hit():#if top hit _ stop and timer
			col = move_and_collide(velocity*delta, true, true, false)
			if col == null:
				position.y = 64*int(position.y/64)-64
			velocity = Vector2(0,0)
			state = TOP
			if $Timer.is_stopped():
				$Timer.start()
		elif $Top.overlaps_body(player) or (col and col.collider == player):#moves plater
			position.y += velocity.y*delta
			if not player.ball and player.velocity.y > velocity.y:
				player.on_floor_window = Actor.WINDOW
				player.velocity.y = velocity.y
		else:# if collide with ceiling
			move_and_collide(velocity*delta, true, true, false)

	elif state == DOWN:
		velocity.y += gravity * delta#move
		velocity.y = min(velocity.y, MAX_DOWN_SPEED)
		
		var col = move_and_collide(velocity*delta, true, true, true)
		
		if position.y > init_pos.y:#if past limit
			velocity = Vector2(0,0)
			position = init_pos
			state = STILL
		elif _bottom_hit():#if bottom hit stop
			move_and_collide(velocity*delta, true, true, false)
			velocity = Vector2(0,0)
		elif $Bottom.overlaps_body(player) or (col and col.collider == player):#player interact
			position.y += velocity.y*delta
			if not player.ball and player.velocity.y < velocity.y:
				player.velocity.y = velocity.y
		elif col:#collide
			move_and_collide(velocity*delta, true, true, false)
		else:#move
			position.y += velocity.y*delta
	elif state == STILL:#wait for player
		if $Top.overlaps_body(player) and not reseted:
			if $Timer.is_stopped():
				$Timer.start()
	reseted = false


func _bound_changed(bound):#calls when bound is changed
	if bound == null:
		return
	_reset()
	if bound.overlaps_body(self):
		set_physics_process(true)
		show()
	else:
		set_physics_process(false)
		hide()
	
func _reset():#sets position and state
	$Timer.stop()
	state = STILL
	position = init_pos
	velocity = Vector2(0, 0)
	reseted = true
	
func _update_node(boolean):#pauses and unpauses node
	set_collision_layer_bit(1, boolean)
	set_collision_mask_bit(1, boolean)
	visible = boolean
	for n in get_children():
		if n is Spike:
			n.set_process(boolean)
			n.set_physics_process(boolean)
			n.visible = boolean
	
func _on_Timer_timeout():#go down on end
	$Timer.stop()
	if state == STILL:
		state = UP
	else:
		state = DOWN
