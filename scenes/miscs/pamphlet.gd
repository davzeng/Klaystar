extends AnimatedSprite
#dialouge info
export var file_location :String
export var code :int
#dict
var dialouge_box :PackedScene = preload("res://scenes/cutscene/dialouge_box.tscn")
var file :File = File.new()
var dict: Dictionary
#name(for save)
export var phamphlet_number:int
var collected:bool
#node
var player :Node
var dialouge_layer :Node

func _ready():
	file.open(file_location, File.READ)#sets dict and nodes
	dict = parse_json(file.get_as_text())
	file.close()
	player = get_tree().current_scene._get_player()
	dialouge_layer = get_tree().current_scene._get_dialouge_layer()
	#checks to see if it's collected
	if Save.dict["pamphlets"].has(str(get_tree().current_scene.chp_number) + str(phamphlet_number)):
		collected = Save.dict["pamphlets"][str(get_tree().current_scene.chp_number) + str(phamphlet_number)]
	player = get_tree().current_scene._get_player()
	play("collected")

func _process(_delta):
	if collected:#stop code
		return
	else:
		play("idle")
		if $Area.overlaps_body(player):#collects and plays dialouge
			collected = true
			Save.pamphlets[str(get_tree().current_scene.chp_number) + str(phamphlet_number)] = true#change save
			Save.pamphlet_count += 1
			play("collect")
			
			var d :Node = self.dialouge_box.instance()
			d.init(dict[String(code)], self)
			self.dialouge_layer.add_child(d)

func _end():#dummy funciton for dialouge
	return

func _on_Pamphlet_animation_finished():#switches anim
	if animation == "collect":
		play("collected")
