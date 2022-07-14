extends Button

export var scene:String
export var number:int
var file: File
var dict: Dictionary

func _on_Button_pressed():#might be removed
	get_tree().change_scene(scene)

func _selected():
	get_tree().change_scene(scene)
