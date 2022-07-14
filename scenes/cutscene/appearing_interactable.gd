extends Interactable

export var dependent_save: String

func _ready():
	visible = false
	set_process(false)
	if Save.dict.has("cutscenes"):#checks to see if scene has already been triggered
		if Save.dict["cutscenes"].has(dependent_save):
			visible = Save.dict["cutscenes"][dependent_save]
			set_process(Save.dict["cutscenes"][dependent_save])

func _appear():
	visible = true
	set_process(true)
