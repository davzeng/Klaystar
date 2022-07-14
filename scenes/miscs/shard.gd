extends AnimatedSprite
#state
var collected:bool = false
var player :Node

func _ready():
	#read save
	if Save.dict.has(get_tree().current_scene.name + name):
		collected = Save.dict[get_tree().current_scene.name + name]
	player = get_tree().current_scene._get_player()

func _physics_process(delta):
	#collect shard
	if !collected:
		if $Area.overlaps_body(player):
			collected = true
			player.shards += 1#implement GUI
			print(player.shards)


func _save(mode):
	#saves
	if mode == Save.SAVE_AND_QUIT:
		Save.dict[get_tree().current_scene.name + name] = collected
