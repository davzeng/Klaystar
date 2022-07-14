extends AnimationPlayer

export var StartingAnimation: String
export var ContinuingAnimation: String
var first_animation_ended:bool = false
var next_animation
var next_waiting:bool = false

var skip_animation
var skip_waiting:bool = false

func _ready():
	if Save.dict.has("first_animation_ended"):
		first_animation_ended = Save.dict["first_animation_ended"]
	
	#decides which anim to play #first_animation_ended
	if StartingAnimation and (not first_animation_ended):
		play(StartingAnimation)
	elif ContinuingAnimation:
		play(ContinuingAnimation)

func _process(_delta):#looks for input
	if next_waiting and Input.is_action_just_pressed("ui_select"):#next anim(might be removed)
		play(next_animation)
		next_waiting = false

func _activate_next(string):#looks for next(might be removed)
	next_animation = string
	next_waiting = true

func _activate_skip(string):#looks for skip
	skip_animation = string
	skip_waiting = true

func _skip():#might be removed
	play(skip_animation)
	skip_waiting = false

func _end_scene():#ends animation
	next_waiting = false
	skip_waiting = false

func _set_first_animation_ended(ended):
	first_animation_ended = ended

func _save(mode):#saves which chp the game is on or current chp
	if mode == Save.SAVE_AND_QUIT:#saves current chp
		Save.dict["first_animation_ended"] = first_animation_ended
