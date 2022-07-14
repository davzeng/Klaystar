extends Sprite
export var vis:bool = false

func _ready():
	if Save.dict.has(get_name()):
		visible = Save.dict[get_name()]
	else:
		visible = vis

func _save(mode):
	if mode == Save.SAVE_AND_QUIT:
		Save.dict[get_name()] = visible
