extends Container

#modes info
var mode :int
var icon :String
const LEFT :int = 0
const RIGHT :int = 1
const QUICKIE :int = 2
const NARRATION :int = 3
const FLIP_NPC :int = 4
const FLIP_KLAY :int = 5
#availible icons
var icons :Dictionary = {}
#nodes
var interactable :Node
var player :Node
var animationPlayer :Node
#next anim
var next:String
#info about lines
var lines:Dictionary
var line:String
var length:int
var stops:Array = []
var index:int = -1
var stop_index:int = 0
#info for tween
var target:float = 0
var stopped:bool = false
var talking:bool = false

var pitch:int

func init(dict, node, string = ""):#manually called when created
	var dir = Directory.new()#sets directiry
	dir.open("res://assets/imgs/dialouge/icons")
	dir.list_dir_begin()
	#gets call icons(might move to seperate obj)
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with(".") and not "import" in file:
			icons[file] = load("res://assets/imgs/dialouge/icons/" + file)
	#sets dict, interactable, and next anim
	lines = dict
	interactable = node
	next = string
	
func _ready():
	player = get_tree().current_scene._get_player()
	animationPlayer = get_tree().current_scene._get_animation_player()
	#calls player function if it is created from interactable
	if interactable:#starts dialouge
		player._start_dialouge()
		_load_dialouge(interactable.is_flipped_h())
	else:
		_load_dialouge()
	
func _process(_delta):
	if Input.is_action_just_pressed("ui_select"):
		if stopped:#continues dialouge
			if interactable:#starts dialouge
				_load_dialouge(interactable.is_flipped_h())
			else:
				_load_dialouge()
		else:#speeds up dialouge
			$Tween.stop_all()
			$DialougeText.percent_visible = target
			stopped = true
			talking = false
	
func _load_dialouge(flipped = false):
	#checks if it has reached end of line
	if stop_index >= stops.size():
		$High1.stop()
		$High2.stop()
		$High3.stop()
		$Mid1.stop()
		$Mid2.stop()
		$Mid3.stop()
		$Low1.stop()
		$Low2.stop()
		$Low3.stop()
		#moves to next line
		index += 1
		#checks to see if all lines have been read
		if index >= lines.size():
			if interactable:#from interactable
				player._end_dialouge()
				interactable._end()
				queue_free()
			else:#from anim
				if next != "":
					animationPlayer.play(next)
				queue_free()
			return
		#moves to next line
		stop_index = 0
		stops.clear()
		var pos:int = 0
		
		#finds new stops
		line = lines[String(index)]["dialouge"]#set vars
		while line.find("~", pos) != -1:
			pos = line.find("~", pos)
			
			var temp:String = line
			temp.erase(pos, 1)
			line = temp
			
			stops.append(_length_to(pos))
		#adds end stop
		length = _length_to(line.length())
		stops.append(length)
		#resets text
		$DialougeText.bbcode_text = line#
		$DialougeText.percent_visible = 0
		
		pitch = lines[String(index)]["voice"]
		#sets new mode and icon
		mode = lines[String(index)]["mode"]
		if mode != NARRATION and mode != QUICKIE:
			$NameText.bbcode_text = lines[String(index)]["speaker"]
			$NameText.percent_visible = 1
		_mode(flipped)
		
		if mode != QUICKIE and mode != NARRATION:
			icon =  lines[String(index)]["icon"]
			$Icon.texture = icons[icon]
	
	#interpolate tween
	var start:float = $DialougeText.percent_visible
	var end:float = (float(stops[stop_index])*2+1)/float(length)/2
	target = end
	stopped = false
	
	$Tween.interpolate_property(
		$DialougeText, "percent_visible", start, end, (end-start)*length/60.0, 
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	talking = true
	var r:float = randf()
	if (not $High1.is_playing() and not $High2.is_playing() and not $High3.is_playing() and
		not $Mid1.is_playing() and not $Mid2.is_playing() and not $Mid3.is_playing() and
		not $Low1.is_playing() and not $Low2.is_playing() and not $Low3.is_playing()):
		match pitch:
			0:
				if r < 0.33:
					$High1.play()
				elif r < 0.66:
					$High2.play()
				else:
					$High3.play()
			1:
				if r < 0.33:
					$Mid1.play()
				elif r < 0.66:
					$Mid2.play()
				else:
					$Mid3.play()
			2:
				if r < 0.33:
					$Low1.play()
				elif r < 0.66:
					$Low2.play()
				else:
					$Low3.play()
	stop_index += 1

func _mode(flipped):
	#sets icon and box positions based on mode
	match mode:
		LEFT: #or klay(flip) or npc(no flip)
			_left()
		RIGHT: #or klay(no flip) or npc(flip)
			_right()
		QUICKIE:
			$Icon.visible = false
			$Dialouge.flip_h = false
			fit_child_in_rect($Dialouge, Rect2(rect_size.y, 2*rect_size.y/3, rect_size.x-2*rect_size.y, rect_size.y/3))
			fit_child_in_rect($DialougeText, Rect2(rect_size.y+16, 2*rect_size.y/3+16, rect_size.x-2*rect_size.y-32, rect_size.y/3-32))
			$Name.visible = false
		NARRATION:
			$Icon.visible = false
			$Dialouge.flip_h = false
			fit_child_in_rect($Dialouge, Rect2(rect_size.y/2, rect_size.y/3, rect_size.x-rect_size.y, 2*rect_size.y/3))
			fit_child_in_rect($DialougeText, Rect2(rect_size.y/2+16, rect_size.y/3+16, rect_size.x-rect_size.y-32, 2*rect_size.y/3-32))
			$Name.visible = false
			$NameText.visible = false
		FLIP_NPC:
			if not flipped:
				_left()
			else:
				_right()
		FLIP_KLAY:
			if flipped:
				_left()
			else:
				_right()
#calculates length to each character
func _length_to(g) -> int:
	var l = 0;
	for i in range(0,g):
		if line.substr(i, 1) != "\n":
			l += 1
	return l

func _left():
	$Icon.visible = true
	$Icon.flip_h = false
	fit_child_in_rect($Icon, Rect2(0, 0, rect_size.y, rect_size.y))
	$Dialouge.flip_h = false
	fit_child_in_rect($Dialouge, Rect2(rect_size.y, rect_size.y/3, rect_size.x-rect_size.y, 2*rect_size.y/3))
	fit_child_in_rect($DialougeText, Rect2(rect_size.y+16, rect_size.y/3+16, rect_size.x-rect_size.y-32, 2*rect_size.y/3-32))
	$Name.visible = true
	fit_child_in_rect($Name, Rect2(rect_size.y, rect_size.y/3-$Name.rect_size.y, $Name.rect_size.x, $Name.rect_size.y))
	$NameText.visible = true
	fit_child_in_rect($NameText, Rect2(rect_size.y+12, rect_size.y/3-$Name.rect_size.y+12, $Name.rect_size.x-24, $Name.rect_size.y))

func _right():
	$Icon.visible = true
	$Icon.flip_h = true
	fit_child_in_rect($Icon, Rect2(rect_size.x-rect_size.y, 0, rect_size.y, rect_size.y))
	$Dialouge.flip_h = true
	fit_child_in_rect($Dialouge, Rect2(0, rect_size.y/3, rect_size.x-rect_size.y, 2*rect_size.y/3))
	fit_child_in_rect($DialougeText, Rect2(16, rect_size.y/3+16, rect_size.x-rect_size.y-32, 2*rect_size.y/3-32))
	$Name.visible = true
	fit_child_in_rect($Name, Rect2(rect_size.x-rect_size.y-$Name.rect_size.x, rect_size.y/3-$Name.rect_size.y, $Name.rect_size.x, $Name.rect_size.y))
	$NameText.visible = true
	fit_child_in_rect($NameText, Rect2(rect_size.x-rect_size.y-$Name.rect_size.x+12, rect_size.y/3-$Name.rect_size.y+12, $Name.rect_size.x-24, $Name.rect_size.y))

#called when the tween is done
func _on_Tween_tween_completed(_object, _key):
	stopped = true
	talking = false

func _on_High1_finished():
	if not talking:
		return
	var r:float = randf()
	if r < 0.33:
		$High1.play()
	elif r < 0.66:
		$High2.play()
	else:
		$High3.play()


func _on_High2_finished():
	if not talking:
		return
	var r:float = randf()
	if r < 0.33:
		$High1.play()
	elif r < 0.66:
		$High2.play()
	else:
		$High3.play()


func _on_High3_finished():
	if not talking:
		return
	var r:float = randf()
	if r < 0.33:
		$High1.play()
	elif r < 0.66:
		$High2.play()
	else:
		$High3.play()


func _on_Mid1_finished():
	if not talking:
		return
	var r:float = randf()
	if r < 0.33:
		$Mid1.play()
	elif r < 0.66:
		$Mid2.play()
	else:
		$Mid3.play()


func _on_Mid2_finished():
	if not talking:
		return
	var r:float = randf()
	if r < 0.33:
		$Mid1.play()
	elif r < 0.66:
		$Mid2.play()
	else:
		$Mid3.play()


func _on_Mid3_finished():
	if not talking:
		return
	var r:float = randf()
	if r < 0.33:
		$Mid1.play()
	elif r < 0.66:
		$Mid2.play()
	else:
		$Mid3.play()


func _on_Low1_finished():
	if not talking:
		return
	var r:float = randf()
	if r < 0.33:
		$Low1.play()
	elif r < 0.66:
		$Low2.play()
	else:
		$Low3.play()


func _on_Low2_finished():
	if not talking:
		return
	var r:float = randf()
	if r < 0.33:
		$Low1.play()
	elif r < 0.66:
		$Low2.play()
	else:
		$Low3.play()


func _on_Low3_finished():
	if not talking:
		return
	var r:float = randf()
	if r < 0.33:
		$Low1.play()
	elif r < 0.66:
		$Low2.play()
	else:
		$Low3.play()
