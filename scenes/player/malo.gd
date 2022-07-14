extends AnimatedSprite

var klay:Node

const STOP_DIST:int = 100
const FOLLOW_DIST:int = 300

var stop:bool = false
var target:Vector2
var start:Vector2
var speed:int
var tweening:bool = false
var done:bool = false

var spawns_manager:Node# = get_tree().current_scene._get_spawns_manager()
var action_queue:Action_Queue
var death_animation :Resource = preload("res://scenes/player/death_animation.tscn") # Will load when parsing the script
var time_passed:float = 0.0
var count_down:float = 0.3

var flip:bool
var anim:String
var on_floor:bool
var dist:Vector2


func _ready():
	playing = true
	spawns_manager = get_tree().current_scene._get_spawns_manager()

func _Malo(queue, node):
	action_queue = queue
	klay = node

func _malo_physics_process(delta):#called by player obj
	if klay.burb or klay.ball:#go to klay
		_on_klay()
	elif stop:#check if klay has left
		if (position - klay.position).length() > FOLLOW_DIST or not klay.is_on_floor():
			stop = false
			target = Vector2(klay.position.x, position.y)
			klay._restart_action_queue()
			time_passed = 0
			start = position
			tweening = true
			speed = 400
	elif tweening:#$Tween.is_active():#follow tween
		position = position + (target-start).normalized()*speed*delta
		if ((start.x < target.x && target.x < position.x) or
			(start.x > target.x && target.x > position.x) or
			target.x == position.x):
			if ((start.y < target.y && target.y < position.y) or
				(start.y > target.y && target.y > position.y) or
				target.y == position.y):
				position = target#stops over shoot
				tweening = false
				done = true
	else:#follow queue
		while action_queue.head and (position-action_queue.head.position).length() < 0.2:
			action_queue._dequeue()
		_get_queued_actions(delta)
		if (klay.is_on_floor()
			and abs(position.x - klay.position.x) < STOP_DIST
			and on_floor and abs(klay.position.y - position.y) < 4):
			stop = true
	_animation()

func _get_queued_actions(delta):#takes info from queue
	time_passed += delta
	while action_queue._check(time_passed):
		var link:Link = action_queue._dequeue()
		while position == link.position:
			link = action_queue._dequeue()
			if not link:
				return
		time_passed -= link.time
		flip = link.flip
		anim = link.anim
		on_floor = link.on_floor
		position = link.position


func _animation():#controls anim
	if klay.transition:
		stop()
	else:
		play()
	
	if anim == "warp":
		play("warp")
		set_flip_h(false)
		rotation_degrees = klay.get_node("Sprite").rotation_degrees
		return
	else:
		rotation_degrees = 0
	
	if animation == "to_boi" or animation == "to_burb":
		return
		
	if klay.burb:
		set_flip_h(klay.get_node("Sprite").is_flipped_h())
		if klay.is_on_floor():
			play("burb_floor")
		else:
			play("burb_air")
		return
	
	if klay.ball:
		set_flip_h(klay.get_node("Sprite").is_flipped_h())
		if not $Tween.is_active():
			if is_flipped_h():
				dist.x = 8
			else:
				dist.x = -8
		play("on_klay")
		return
	
	if stop:
		set_flip_h(_center().x > klay._center().x)
		play("idle")
		return
	
	if tweening or done:#$Tween.is_active():
		set_flip_h(_center().x > klay._center().x)
		done = false
		if start.y == target.y:
			play("running")
		else:
			play("up")
		return
	
	set_flip_h(flip)
	if anim == "idle":
		play("idle")
	elif anim == "swimming":
		play("swimming")
	elif anim == "running":
		play("running")
	elif anim == "up":
		play("up")
	elif anim == "down":
		play("down")

func _on_Malo_animation_finished():
	if animation == "to_boi":
		play("idle")
		_animation()
	elif animation == "to_burb":
		play("burb_air")

func _die():
	var node = death_animation.instance()
	node.offset.x = position.x
	node.offset.y = position.y
	get_tree().get_root().add_child(node)
	
	_reset(spawns_manager.currentSpawn._SpawnCoordinates())

func _on_klay():
	position = klay.position + dist

func _into_ball():
	stop = false
	_update_tween()

func _outof_ball(vector_pos, _vector_vel):
	_update_tween()
	
func _into_burb():
	stop = false
	_update_tween()
	play("to_burb")

func _outof_burb(vector_pos, _vector_vel):
	_update_tween()
	play("to_boi")

func _update_tween():#updates position tween
	$Tween.remove_all()
	if klay.burb:#burb takes priority
		dist = position - klay.position
		$Tween.interpolate_property(self, "dist", dist, Vector2(0,-16), 
			0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.start()
	elif klay.ball:
		dist = position - klay.position
		$Tween.interpolate_property(self, "dist",dist, Vector2(-8,-28), 
			0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.start()
	else:
		target = klay.position
		start = position
		tweening = true
		speed = 800

func _go_to(x):
	target = x;

func _set_tween(x, t):
	$Tween.interpolate_property(self, "position", position, x, 
		t, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()

func _reset(vector_pos):#resets position
	position = vector_pos#move
	anim = ""
	stop = false
	
	count_down = 0.3
	time_passed = 0

func _center() -> Vector2:
	return position + Vector2(16, 26)
