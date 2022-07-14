extends AnimatedSprite
export var vis:bool = false

func _ready():
	play("idle")
	if Save.dict.has(get_name()):
		visible = Save.dict[get_name()]
	else:
		visible = vis
	if not visible:
		$FrostBlock.set_collision_layer_bit(1, false)
	else:
		$FrostBlock.set_collision_layer_bit(1, true)
	
func _save(mode):
	if mode == Save.SAVE_AND_QUIT:
		Save.dict[get_name()] = visible

func _dehit():
	$FrostBlock.set_collision_layer_bit(1, false)

func _disappear():
	visible = false
