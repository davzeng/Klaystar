extends AnimatedSprite

#dir and dict
export var file_dir :String
var dict:Dictionary

func _ready():
	#prints save and sets dict
	dict = Save._load(file_dir)
	print(dict)
	if name == "SaveButton1":
		_selected()

func _selected():#anims selected
	$Tween.stop_all()
	$Tween.interpolate_property($ResetSlide, "position", $ResetSlide.position, Vector2(596, 0), 0.5
		,Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.start()

func _unselected():#anims unselected
	$Tween.stop_all()
	$Tween.interpolate_property($ResetSlide, "position", $ResetSlide.position, Vector2(392, 0), 0.5
		,Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.start()
	
func _triggered():#opens save
	Save._open(file_dir, dict)
	get_tree().change_scene("res://scenes/hud/chapter_select.tscn")

func _reset():
	dict = Save._reset(file_dir)
