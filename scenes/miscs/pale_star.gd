extends Node2D

var player :Node
var used:bool = false

func _ready():#pause node and sets player
	player = get_tree().current_scene._get_player()
	$Sprite.play("idle")


func _physics_process(_delta):#detects player
	if $Area.overlaps_body(player) && !used:
		if player.burb:
			var start = _center()-(player._center() - player.position)
			player._shoot(start)
			used = true
			$Sprite.visible = false
			$Timer.set_wait_time(3)
			$Timer.start()
		elif player.ball:
			var speed = player.velocity.length()
			if speed < 500:
				speed = 500
			var new_vel = (player._center() - _center()).normalized()*speed
			player.velocity = new_vel
			used = true
			$Sprite.visible = false
			$Timer.set_wait_time(0.1)
			$Timer.start()
		else:
			player._launch()
			used = true
			$Sprite.visible = false
			$Timer.set_wait_time(3)
			$Timer.start()

func _center() -> Vector2:#returns center coordinates
	return position + $Center.position

func _reset():#sets position and state
	$Timer.stop()
	used = false
	$Sprite.visible = true

func _on_Timer_timeout():
	used = false
	$Sprite.visible = true
