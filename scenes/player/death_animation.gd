extends AnimatedSprite



func _ready():
	play("death")
#delete
func _on_DeathAnimation_animation_finished():
	visible = false
	queue_free()
