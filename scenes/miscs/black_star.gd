extends Node2D

var player :Node

func _ready():#pause node and sets player
	player = get_tree().current_scene._get_player()
	$Sprite.play("idle")

func _physics_process(_delta):#detects player
	if $Area.overlaps_body(player):
		if $Sprite.animation == "idle":
			$Sprite.play("explode")

func _center() -> Vector2:#returns center coordinates
	return position + $Center.position


func _on_Sprite_animation_finished():
	if $Sprite.animation == "explode":
		$Sprite.play("regen")
	elif $Sprite.animation == "regen":
		$Sprite.play("idle")
	


func _on_Sprite_frame_changed():
	if $Sprite.animation == "explode" and $Sprite.frame == 6:
		if $Area.overlaps_body(player):
			player.dead = true
