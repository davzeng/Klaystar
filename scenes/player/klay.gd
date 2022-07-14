extends Actor

var malo:Node#scenes/nodes
const ACTION_QUEUE = preload("res://scenes/player/action_queue.gd")
const DEATH_ANIMATION = preload("res://scenes/player/death_animation.gd")

var spawns_manager:Node
var action_queue:Action_Queue = ACTION_QUEUE.new()
var death_animation :Resource = preload("res://scenes/player/death_animation.tscn") 

var shards :int = 0

var time_passed:float = 0.0#state
var burb:bool = false
var ball:bool = false
var warp:bool = false
var shoot:bool = false
var on_rough_wall_r:bool = false
var on_rough_wall_l:bool = false
var new_velocity:Vector2
var charged:bool = false
var jump_vel:float

var in_air:bool = false

var transition:bool = false
#transitions and anims
var go_to:bool = false
var target:Vector2
var smol:bool = false
var y_amp:bool = false

var in_cs:bool = false
var dialouge:bool = false
var dead:bool = false

export var malo_active:bool = true

var swimming:bool

const player_rect:PoolVector2Array = PoolVector2Array([Vector2(0, 4), Vector2(32, 4), Vector2(32, 52), Vector2(0, 52)])
const ball_rect:PoolVector2Array = PoolVector2Array([Vector2(0, 4), Vector2(32, 4), Vector2(32, 36), Vector2(0, 36)])

func _ready():
	$Sprite.playing = true
	
	$HitBox.shape.points = player_rect#sets the player's hitbox
	
	malo = get_parent().get_node("Malo")#prepares malo and spawn manager
	malo._Malo(action_queue, self)
	spawns_manager = get_tree().current_scene._get_spawns_manager()
	#saves
	if Save.dict.has("chapter") and not Save.dict["chapter"] == "" and not Save.dict["chapter"] == null:
		if Save.dict.has("spawn"):
			position = spawns_manager.get_node(Save.dict["spawn"])._SpawnCoordinates()
		else:
			if Save.dict.has("player_x"):
				position.x = Save.dict["player_x"]
			if Save.dict.has("player_y"):
				position.y = Save.dict["player_y"]
		if Save.dict.has("malo_active"):
			malo_active = Save.dict["malo_active"]
		if Save.dict.has("shard_count"):
			shards = Save.dict["shard_count"]
		if Save.dict.has("smol"):
			smol = Save.dict["smol"]
	malo.visible = malo_active;

func _physics_process(delta):#loop
	if not delta:#no time has passed
		return
	
	if transition:#moving between bounds
		_animation_and_sound()
		malo._animation()
		return
	
	if go_to:#incut scene
		velocity.x = 0
		_queue(delta)
		if position == target or (target == Vector2(0,0) and is_on_floor()):#disables physics
			if $Sprite.animation != "smol_fall":
				$Sprite.play("idle")
			if malo.stop or !malo_active:
				set_physics_process(false)
				
				go_to = false
				return
		elif not $Tween.is_active():
			if ball:
				ball = false
				if malo_active:
					malo._outof_ball(position, velocity)#resets malo and queue
				_restart_action_queue()
				_update_box()
			if burb:
				burb = false
				malo._outof_burb(position, velocity)#resets malo and queue
				_restart_action_queue()
			if is_on_floor():
				$Sprite.set_flip_h(position.x > target.x)
				$Tween.interpolate_property(self, "position", position, target, 
				min((position - target).length()/400, 0.7), Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
				$Tween.start()
				velocity = Vector2(0,0)
				$Sprite.play("running")
			else:
				_gravity(delta)#physics
				_deceleration(delta)
				_cap(delta)
				velocity = move_and_slide(velocity, UP)
				_animation_and_sound()
		if malo_active:
			malo._malo_physics_process(delta)
		return
	
	if dialouge:#if the player is in the middle of dialouge
		_queue(delta)
		_gravity(delta)#physics
		_deceleration(delta)
		velocity = move_and_slide(velocity, UP)
		_animation_and_sound()
		if malo_active:
			malo._malo_physics_process(delta)#controls malo
		return
	
	if warp:#if warped in chapter 4
		_queue(delta)
		_animation_and_sound()
		if not $Tween.is_active():
			warp = false
			velocity = new_velocity
		if malo_active:
			malo._malo_physics_process(delta)#controls malo
		if dead:#dying
			_die()
		return
	if shoot:#shot in chapter eight
		_queue(delta)
		_animation_and_sound()
		if $Timer.is_stopped():
			if not $Tween.is_active():
				shoot = false
				velocity = new_velocity
		if dead:
			_die()
		if shoot:
			return
	#start of regular loop
	_queue(delta)#queues state
	
	if $Sprite.animation == "revive":#reviving
		return
	_transform(delta)
	
	if ball:#ball mode
		if swimming:
			_swim(delta)
		else:
			_run(delta)
		_gravity(delta)
		_deceleration(delta)
		_cap(delta)
		
		move_and_slide(velocity, UP)#move and bounce
		if is_on_floor() or is_on_ceiling():
			if y_amp:#for breaking platforms
				velocity.y = -sqrt(2*velocity.y*velocity.y)
				y_amp = false
			else:
				velocity.y = -velocity.y
			$Jump.play()
		if is_on_wall():
			velocity.x = -(velocity.x*1.2)
	else:#boi mode
		if swimming:
			_swim(delta)
		else:
			_jump(delta)
			_run(delta)
		_gravity(delta)
		_deceleration(delta)
		_cap(delta)
		velocity = move_and_slide(velocity, UP)#move
	_animation_and_sound()
	
	if malo_active:#runs malo's loop
		malo._malo_physics_process(delta)
	#might not be needed?
	var node = move_and_collide(Vector2(0,0.1),true,true,true)
	if node:
		node = move_and_collide(Vector2(0,-0.1),true,true,true)
		if node:
			dead = true
	if dead:#dying
		_die()
	
func _queue(delta):#inserts state into action queue
	time_passed += delta
	action_queue._enqueue(time_passed, position, $Sprite.is_flipped_h(), $Sprite.animation, is_on_floor())
	time_passed = 0
		
func _transform(_delta):#turns into ball
	if malo_active and Input.is_action_just_pressed("ui_back"):#turns into bird
		burb = !burb
		if burb:#runs malo functions
			malo._into_burb()
		else:
			malo._outof_burb(position, velocity)
			_restart_action_queue()
	
	if not in_cs and Input.is_action_just_pressed("ui_select"):#turns into ball
		ball = !ball
		if ball:
			if malo_active:
				malo._into_ball()
			if is_on_floor():
				velocity.y = -500
			if smol:
				$Sprite.play("smol_to_ball")
			else:
				$Sprite.play("to_ball")
			
			on_floor_window = 0
			jump_pressed_window = 0
			jump_extend_window = 0
		else:
			if malo_active:
				malo._outof_ball(position, velocity)#resets malo and queue
			_restart_action_queue()
			if smol:
				$Sprite.play("smol_to_boi")
			else:
				$Sprite.play("to_boi")
		_update_box()
	in_cs = false

func _jump(delta):
	#windows
	if is_on_floor():
		on_floor_window = WINDOW
	if Input.is_action_just_pressed("ui_up"):
		jump_pressed_window = WINDOW
		
	on_floor_window = max(on_floor_window - delta, 0)
	jump_pressed_window = max(jump_pressed_window - delta, 0)
	jump_extend_window = max(jump_extend_window - delta, 0)
	wall_jump_stun_window = max(wall_jump_stun_window - delta, 0)
	
	#jump
	if on_floor_window > 0 and jump_pressed_window > 0:
		#if velocity.y > 0:
		#	velocity.y = JUMP_Y
		#else:
		#	velocity.y += JUMP_Y
		velocity.y = JUMP_Y
		jump_vel = velocity.y
		jump_extend_window = JUMP_EXTEND_TIME

		on_floor_window = 0
		jump_pressed_window = 0
		
		$Jump.play()
	elif (Input.is_action_pressed("ui_right") && on_rough_wall_r 
		&& is_on_wall() and jump_pressed_window > 0):
		
		velocity.y = WALL_JUMP.y
		velocity.x = -WALL_JUMP.x
		wall_jump_stun_window = WALL_JUMP_STUN_TIME
		stun_right = true
		on_floor_window = 0
		jump_pressed_window = 0
		$Jump.play()
	elif (Input.is_action_pressed("ui_left") && on_rough_wall_l
		&& is_on_wall() and jump_pressed_window > 0):
		
		velocity.y = WALL_JUMP.y
		velocity.x = WALL_JUMP.x
		wall_jump_stun_window = WALL_JUMP_STUN_TIME
		stun_right = false
		on_floor_window = 0
		jump_pressed_window = 0
		$Jump.play()
	if jump_extend_window > 0:#extends
		if Input.is_action_pressed("ui_up"):
			velocity.y = jump_vel#JUMP_Y
		else:
			jump_extend_window = 0

func _run(delta):
	#running
	if velocity.x < -MAX_RUN_SPEED :
		if !(wall_jump_stun_window > 0 && stun_right):
			if Input.is_action_pressed("ui_right"):
				velocity.x = min(velocity.x+delta*RUN_ACCEL,MAX_RUN_SPEED)
	elif velocity.x > MAX_RUN_SPEED:
		if !(wall_jump_stun_window > 0 && !stun_right):
			if Input.is_action_pressed("ui_left"):
				velocity.x = max(velocity.x-delta*RUN_ACCEL,-MAX_RUN_SPEED)
	else:
		if Input.is_action_pressed("ui_right"):
			if !(wall_jump_stun_window > 0 && stun_right):
				velocity.x = min(velocity.x+delta*RUN_ACCEL,MAX_RUN_SPEED)
		elif Input.is_action_pressed("ui_left"):
			if !(wall_jump_stun_window > 0 && !stun_right):
				velocity.x = max(velocity.x-delta*RUN_ACCEL,-MAX_RUN_SPEED)

func _swim(delta):
	on_floor_window = 0
	jump_pressed_window = 0
	jump_extend_window = 0
	
	if velocity.x < -MAX_SWIM_SPEED :
		if Input.is_action_pressed("ui_right"):
			velocity.x = min(velocity.x+delta*SWIM_ACCEL,MAX_SWIM_SPEED)
	elif velocity.x > MAX_SWIM_SPEED:
		if Input.is_action_pressed("ui_left"):
			velocity.x = max(velocity.x-delta*SWIM_ACCEL,-MAX_SWIM_SPEED)
	else:
		if Input.is_action_pressed("ui_right"):
			velocity.x = min(velocity.x+delta*SWIM_ACCEL,MAX_SWIM_SPEED)
		elif Input.is_action_pressed("ui_left"):
			velocity.x = max(velocity.x-delta*SWIM_ACCEL,-MAX_SWIM_SPEED)
	if ball:
		velocity.y += WATER_BALL_ACCEL*delta
	else:
		if velocity.y > -MAX_SWIM_SPEED:
			if Input.is_action_pressed("ui_up"):
				velocity.y = max(velocity.y-delta*SWIM_ACCEL,-MAX_SWIM_SPEED)
func _gravity(delta):
	if swimming:#in water
		if not Input.is_action_pressed("ui_up") and not ball:
			velocity.y = min(velocity.y+delta*WATER_GRAVITY, MAX_WATER_SPEED.y)
	else:
		if (on_rough_wall_r || on_rough_wall_l) && is_on_wall():
			velocity.y = min(velocity.y+delta*GRAVITY,MAX_ROUGH_WALL_SPEED)
		else:
			velocity.y = min(velocity.y+delta*GRAVITY, MAX_SPEED.y)
		

func _deceleration(delta):
	if dialouge:
		if velocity.x > 0:
			velocity.x = max(velocity.x-delta*DECEL,0)
		elif velocity.x < 0:
			velocity.x = min(velocity.x+delta*DECEL,0)
		return
	
	if Input.is_action_pressed("ui_right"): #over cap decel
		if swimming:
			if velocity.x > MAX_SWIM_SPEED:
				velocity.x = max(velocity.x-delta*SWIM_DECEL/3,0)
		else:
			if velocity.x > MAX_RUN_SPEED:
				velocity.x = max(velocity.x-delta*DECEL/3,0)
	elif Input.is_action_pressed("ui_left"):
		if swimming:
			if velocity.x < -MAX_SWIM_SPEED:
				velocity.x = min(velocity.x+delta*SWIM_DECEL/3,0)
		else:
			if velocity.x < -MAX_RUN_SPEED:
				velocity.x = min(velocity.x+delta*DECEL/3,0)
	else:#stopping
		if velocity.x > 0:
			if swimming:
				velocity.x = max(velocity.x-delta*SWIM_DECEL,0)
			else:
				velocity.x = max(velocity.x-delta*DECEL,0)
		if velocity.x < 0:
			if swimming:
				velocity.x = max(velocity.x-delta*SWIM_DECEL,0)
			else:
				velocity.x = min(velocity.x+delta*DECEL,0)

func _cap(delta):#cap speed(doesn't handle y)
	if burb:
		velocity.y = min(velocity.y, MAX_SPEED.y)
		if velocity.y > MAX_GLIDE_SPEED:#slows player if falling too fast
			velocity.y = max(velocity.y-2*delta*GRAVITY, MAX_GLIDE_SPEED)
		
		#velocity.y = min(velocity.y, MAX_GLIDE_SPEED)
		
		#velocity.y = max(velocity.y, -MAX_SPEED.y)
		velocity.x = min(velocity.x, MAX_SPEED.x)
		velocity.x = max(velocity.x, -MAX_SPEED.x)
	elif swimming:
		velocity.y = min(velocity.y, MAX_WATER_SPEED.y)
		if not ball:
			velocity.y = max(velocity.y, -MAX_WATER_SPEED.y)
		#else:
		#	velocity.y = max(velocity.y, -MAX_SPEED.y)
		velocity.x = min(velocity.x, MAX_WATER_SPEED.x)
		velocity.x = max(velocity.x, -MAX_WATER_SPEED.x)
	else:
		velocity.y = min(velocity.y, MAX_SPEED.y)
		#velocity.y = max(velocity.y, -MAX_SPEED.y)
		velocity.x = min(velocity.x, MAX_SPEED.x)
		velocity.x = max(velocity.x, -MAX_SPEED.x)

func _animation_and_sound():
	if $Sprite.animation == "running" or $Sprite.animation == "smol_running":
		if not $Step.is_playing():
			$Step.play()
	else:
		$Step.stop()
				
	if not is_on_floor():
		in_air = true
	else:
		if in_air:
			in_air = false
			if not swimming and not ball:
				$Land.play()
	
	if $Sprite.animation == "smol_fall":
		return
	
	if transition:
		$Sprite.stop()
		$Step.stop()
		return
	$Sprite.play()
	
	if warp:
		$Sprite.play("warp")
		$Sprite.set_flip_h(false)
		$Sprite.rotation_degrees = new_velocity.angle()/PI*180
		return
	else:
		$Sprite.rotation_degrees = 0
	if not dialouge:
		if Input.is_action_pressed("ui_right"):
			$Sprite.set_flip_h(false)
		elif Input.is_action_pressed("ui_left"):
			$Sprite.set_flip_h(true)
		
	
	if ($Sprite.animation == "to_boi" or $Sprite.animation == "to_ball" or
		$Sprite.animation == "smol_to_boi" or $Sprite.animation == "smol_to_ball" or
		$Sprite.animation == "revive"):
		return
	
	if ball:
		$Sprite.play("ball")
	elif swimming:
		if velocity.y > 0:
			$Sprite.play("down")
		else:
			$Sprite.play("swimming")
	elif is_on_floor():
		if velocity.x == 0:
			if smol:
				$Sprite.play("smol_idle")
			else:
				$Sprite.play("idle")
		else:
			if smol:
				$Sprite.play("smol_running")
			else:
				$Sprite.play("running")
	else:
		if velocity.y < 0:
			if smol:
				$Sprite.play("smol_up")
			else:
				$Sprite.play("up")
		else:
			if smol:
				$Sprite.play("smol_down")
			else:
				$Sprite.play("down")

func _on_Sprite_animation_finished():
	if $Sprite.animation == "to_boi":
		$Sprite.play("idle")
		_animation_and_sound()
	elif $Sprite.animation == "to_ball":
		$Sprite.play("ball")
	elif $Sprite.animation == "smol_to_boi":
		$Sprite.play("smol_idle")
		_animation_and_sound()
	elif $Sprite.animation == "smol_to_ball":
		$Sprite.play("ball")
	elif $Sprite.animation == "revive":
		$Sprite.play("idle")

func _update_box():
	if ball:
		$HitBox.shape.points = ball_rect
	else:
		$HitBox.shape.points = player_rect

func _die():#die
	var node = death_animation.instance()
	node.offset.x = position.x
	node.offset.y = position.y
	get_tree().get_root().add_child(node)
	
	for n in get_tree().get_nodes_in_group("Resettable"):
		n._reset()
	position = spawns_manager.currentSpawn._SpawnCoordinates()
	velocity = Vector2(0, 0)
	jump_extend_window = 0
	ball = false
	burb = false
	warp = false
	$Tween.remove_all()
	dead = false
	_update_box()
	
	if malo_active:
		malo._die()
	_restart_action_queue()
	
	$Sprite.play("revive")
	$Death.play()

func _restart_action_queue():#restarts action queue
	action_queue._clear()
	time_passed = 0

func _push(vector):
	velocity += vector
	if vector.y < 0:
		on_floor_window = 0
		jump_extend_window = 0

func _warp(tar, new_vel):
	$Tween.interpolate_property(self, "position", position, tar, 
		(position - tar).length()/700, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	warp = true
	new_velocity = new_vel

func _y_amplify():
	if velocity.y > 0:
		y_amp = true
	else:
		velocity.y = -sqrt(2*velocity.y*velocity.y)

func _x_amplify():
	if velocity.x > 0:
		velocity.x = MAX_SPEED.x
	else:
		velocity.x = -MAX_SPEED.x
	velocity.y = JUMP_Y

func _launch():
	velocity.y = -900
	on_floor_window = 0
	jump_extend_window = 0
	if Input.is_action_just_pressed("ui_right"):
		velocity.x = MAX_RUN_SPEED
	elif Input.is_action_just_pressed("ui_left"):
		velocity.x = -MAX_RUN_SPEED
	
func _shoot(start):
	position = start
	$Tween.remove_all()
	$Timer.stop()
	$Timer.set_wait_time(0.25)
	$Timer.start()
	shoot = true
	jump_extend_window = 0
	
func _teleport(vector):
	ball = false
	position = vector

func _start_dialouge():
	dialouge = true
	#time_passed = 0

func _end_dialouge():
	go_to = false
	dialouge = false
	#if malo_active:
	#	_restart_action_queue()
	#	malo._reset(position)

func _go_to(x):
	$Step.stop()
	go_to = true
	target = x;

func _start_cutscene():
	$Step.stop()
	set_physics_process(false)

func _end_cutscene():
	$Tween.remove_all()
	go_to = false
	dialouge = false
	set_physics_process(true)

func _play_animation(string):
	$Sprite.play(string)

func _flip_animation(boolean):
	$Sprite.set_flip_h(boolean)

func _make_small():
	smol = true

func _activate_malo():
	malo_active = true
	_restart_action_queue()
	malo.visible = true

func _save(mode):
	if mode == Save.SAVE_AND_QUIT:
		Save.dict["player_x"] = position.x
		Save.dict["player_y"] = position.y
		Save.dict["shard_count"] = shards
		Save.dict["malo_active"] = malo_active
		Save.dict["smol"] = smol

func _center() -> Vector2:
	if ball:
		return position + Vector2(16, 18)
	else:
		return position + Vector2(16, 26)

func _get_camera() -> Node:
	return $Camera

func _on_Timer_timeout():
	var end = Vector2(0,0)
	var new_vel = Vector2(0,0)
	if(Input.is_action_pressed("ui_right")):
		end = position + Vector2(320, 0)
		new_vel = Vector2(1200,0)
	elif(Input.is_action_pressed("ui_left")):
		end = position + Vector2(-320, 0)
		new_vel = Vector2(-1200,0)
	elif(Input.is_action_pressed("ui_up")):
		end = position + Vector2(0, -320)
		new_vel = Vector2(0,-1200)
	elif(Input.is_action_pressed("ui_down")):
		end = position + Vector2(0, 320)
		new_vel = Vector2(0,1200)
	else:
		if $Sprite.is_flipped_h():
			end = position + Vector2(-320, 0)
			new_vel = Vector2(-1200,0)
		else:
			end = position + Vector2(320, 0)
			new_vel = Vector2(1200,0)
	$Tween.interpolate_property(self, "position", position, end, 
		(position - end).length()/1200, Tween.TRANS_LINEAR, Tween.EASE_OUT_IN)
	$Tween.start()
	new_velocity = new_vel
