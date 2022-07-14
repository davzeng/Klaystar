extends AnimatedSprite

const UP: int = 0
const DOWN: int = 1
const RIGHT: int = 2
const LEFT: int = 3

const SLOW: int = 0
const MEDIUM: int = 1
const FAST: int = 2
export var delay: float
export var mode: int
export var speed: int
var player :Node
var bound_manager :Node
#var beating: bool

func _ready():#pause node and sets player
	player = get_tree().current_scene._get_player()
	bound_manager = get_tree().current_scene._get_bounds_manager()
	if delay == 0:
		if speed == SLOW:
			play("slow")
		if speed == MEDIUM:
			play("medium")
		if speed == FAST:
			play("fast")
	else:
		$Timer.start(delay)

func _on_Heart_animation_finished():
	if bound_manager.activeBound.overlaps_area($Area):
		if mode == UP:
			if(player.velocity.y >= 0):
				player._push(Vector2(0, -550))
			else:
				player._push(Vector2(0, -400))
		if mode == DOWN:
			player._push(Vector2(0, 500))
		if mode == RIGHT:
			player._push(Vector2(550, 0))
		if mode == LEFT:
			player._push(Vector2(-550, 0))


func _reset():#sets position and state
	set_frame(0)
	stop()
	if delay == 0:
		if speed == SLOW:
			play("slow")
		if speed == MEDIUM:
			play("medium")
		if speed == FAST:
			play("fast")
	else:
		$Timer.start(delay)

func _on_Timer_timeout():
	if speed == SLOW:
		play("slow")
	if speed == MEDIUM:
		play("medium")
	if speed == FAST:
		play("fast")
