extends Node2D


var arr:Array = []

func _ready():#gets save
	if Save.dict.has("layout"):
		arr = Save.dict["layout"]
	else:
		arr.resize(get_child_count())
		for i in range(arr.size()):
			arr[i] = false
		arr[0] = true
	_update_groups()

func _shift(var array):#changes groups
	arr = array
	_update_groups()

func _update_groups():#updates all groups
	for i in range(arr.size()):
		get_child(i)._update_group(arr[i])

func _save(mode):#saves
	if mode == Save.SAVE_AND_QUIT:
		Save.dict["layout"] = arr
