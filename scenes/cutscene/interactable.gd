extends AnimatedSprite
class_name Interactable
#controls hit box
export var turning :bool
export var file_location :String
export var prompt_position :Vector2
export var area_position :Vector2
export var area_scale :Vector2
#info on dialouge
var dialouge_box :PackedScene = preload("res://scenes/cutscene/dialouge_box.tscn")
var file :File = File.new()
var dict: Dictionary
#nodes
var player :Node
var animation_player :Node
var dialouge_layer :Node
#info on node
var times_interacted: int = 0
var active :bool = false
var over:bool = false

func _ready():#sets nodes
	#sets dict
	file.open(file_location, File.READ)
	dict = parse_json(file.get_as_text())
	file.close()
	#sets nodes
	player = get_tree().current_scene._get_player()
	animation_player = get_tree().current_scene._get_animation_player()
	dialouge_layer = get_tree().current_scene._get_dialouge_layer()
	#sets hitbox
	$Prompt.position = prompt_position
	$Area.position = area_position
	$Area.scale = area_scale
	
	play("idle")

func _process(_delta):#controls animation/activation
	if turning:#turns sprite
		set_flip_h(player.position.x < position.x)
	if active or over:#over or activated
		$Prompt.visible = false
	elif $Area.overlaps_body(player):#player overlaping
		$Prompt.visible = true
		
		if not player.ball:#stops player from being ball
			player.in_cs = true
		if Input.is_action_just_pressed("ui_select") and player.is_physics_processing():#activates
			_start()
	else:#idle
		$Prompt.visible = false
	
func _start():#activates
	if dict.has(String(times_interacted)):#plays nums
		var d :Node = self.dialouge_box.instance()
		d.init(dict[String(times_interacted)], self)
		self.dialouge_layer.add_child(d)
		active = true
	elif dict.has("loop"):#plays loop
		var d :Node = self.dialouge_box.instance()
		d.init(dict[String("loop")], self)
		self.dialouge_layer.add_child(d)
		active = true
	
func _end():#called by dialouge box
	active = false
	times_interacted += 1
	if not dict.has(String(times_interacted)) and not dict.has("loop"):
		over = true
