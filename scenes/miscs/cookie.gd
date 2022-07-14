extends AnimatedSprite

var collected:bool

var player :Node
var cookie_count:Node

func _ready():
	if Save.dict.has(get_tree().current_scene.name + name):
		collected = Save.dict[get_tree().current_scene.name + name]
	#collected = false
	#if collected:
	#	print("w")
	player = get_tree().current_scene._get_player()
	cookie_count = get_tree().current_scene._get_cookie_count()

func _process(delta):
	if collected:
		if animation != "collect":
			play("collected")
	else:
		play("idle")

func _save(mode):
	Save.dict[get_tree().current_scene.name + name] = collected

func _on_HitBox_body_entered(body):
	if collected:
		return
	if body == player:
		play("collect")
		collected = true
		cookie_count._add()


func _on_Cookie_animation_finished():
	if animation == "collect":
		play("collected")
