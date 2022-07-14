extends CanvasLayer
#box
var dialouge_box :PackedScene = preload("res://scenes/cutscene/dialouge_box.tscn")
#info
var file :File = File.new()
var dict: Dictionary

func _load(string, integer, next):#loads box for anim
	#gets dict
	file.open(string, File.READ)
	dict = parse_json(file.get_as_text())
	file.close()
	#creates anim
	var d :Node = dialouge_box.instance()
	d.init(dict[String(integer)], null, next)
	add_child(d)

func _clear():#called at end of anim
	for n in get_children():
		remove_child(n)
		n.queue_free()
