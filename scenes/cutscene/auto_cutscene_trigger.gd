extends Area2D

export var animation: String#anim to play

var player :Node#nodes
var animation_player :Node

var triggered:bool = false
var playing:bool = false

func _ready():
	player = get_tree().current_scene._get_player()
	animation_player = get_tree().current_scene._get_animation_player()
	
	if Save.dict.has("cutscenes"):#checks to see if scene has already been triggered
		if Save.dict["cutscenes"].has(name):
			triggered = Save.dict["cutscenes"][name]

func _physics_process(_delta):
	if overlaps_body(player):
		if not triggered and not playing and player.is_physics_processing():# and animation_player.current_animation == "":#triggers anim
			animation_player.play(animation)
			playing = true

func _trigger():
	triggered = true

func _save(mode):#saves info on trigger
	if mode == Save.SAVE_AND_QUIT:
		if not Save.dict.has("cutscenes"):
			Save.dict["cutscenes"] = {}
		Save.dict["cutscenes"][name] = triggered
