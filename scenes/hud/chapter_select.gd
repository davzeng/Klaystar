extends Container
#indexes
var index :int = 0
var max_index :int
#progress
var progress:int = 0

func _ready():
	MusicPlayer._stop()
	#checks if the game is in chapter
	if Save.dict.has("chapter") and not Save.dict["chapter"] == "" and not Save.dict["chapter"] == null:
		get_tree().change_scene(Save.dict["chapter"])
	#gets progress
	if Save.dict.has("chapters_complete"):
		progress = Save.dict["chapters_complete"]
		if progress == 0 and not Save.debug:#just started
			get_tree().change_scene("res://scenes/chapters/chapter_one.tscn")

func _process(_delta):
	#right and left key
	if Input.is_action_just_pressed("ui_right"):
		if index < progress or Save.debug:
			index += 1
	if Input.is_action_just_pressed("ui_left"):
		if index > 0 or Save.debug:
			index -= 1
		
	#select
	if Input.is_action_just_released("ui_select"):
		get_child(index)._selected()
	#return to save select
	if Input.is_action_just_released("ui_back"):
		get_tree().change_scene("res://scenes/hud/save_select.tscn")
	_update_boxes()
	
	
func _update_boxes():
	var i = 0;#updates every button
	for node in get_children():
		if node is Button:
			if node.number > progress+1 and !Save.debug:
				node.visible = false
			elif index-i == 1:#left
				node.visible = true
				fit_child_in_rect(node, Rect2(rect_size.x/9, rect_size.y/3, rect_size.x/9, rect_size.y/3))
			elif index-i == 0:#mid
				node.visible = true
				fit_child_in_rect(node, Rect2(rect_size.x/3, 0, rect_size.x/3, rect_size.y))
			elif index-i == -1:#right
				node.visible = true
				fit_child_in_rect(node, Rect2(7*rect_size.x/9, rect_size.y/3, rect_size.x/9, rect_size.y/3))
			else:
				node.visible = false
			i += 1
