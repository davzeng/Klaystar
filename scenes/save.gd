extends Node

const debug = true
const reset = false

const SAVE_AND_QUIT:int = 0
const RETURN_TO_SELECT:int = 1
const COMPLETE:int = 2

var file_path :String
var file :File = File.new()
var dict :Dictionary

var chapters_complete :int
var pamphlet_count :int
var pamphlets :Dictionary

#always there
	#chapters complete:int
	#pamphlet_count: int
	#pamphlets: Dictionary
#Save and Quit
	#chapter: path
	#first_animation_ended
	#layout: Array
	#Player State
		#position: int
		#malo_active: bool
		#shard_count :int
	#cutscenes :Dictionary 
	#shards :Dictionary -only chp4 ***************
	#spawn
	#track
	#smol
	#backgrounds

# order - {chapter, chapters_complete, cutscenes, layout, 
	#malo_active, pamplet_count, pamphlets, player_x, player_y, shard_count, shards, spawn}

func _ready():
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	pass

func _load(path):#returns a dict for this path
	var temp:Dictionary
	#file_path = path
	file.open(path, File.READ)#filepath
	if parse_json(file.get_as_text()):
		temp = parse_json(file.get_as_text())
	else:
		temp = {}
	if not temp.has("chapters_complete"):
		temp["chapters_complete"] = 0
	if not temp.has("pamphlet_count"):
		temp["pamphlet_count"] = 0
	if not temp.has("pamphlets"):
		temp["pamphlets"] = {}
	file.close()
	return temp

func _open(p, d):#opens a save
	file_path = p
	dict = d
	chapters_complete = dict["chapters_complete"]
	pamphlet_count = dict["pamphlet_count"]
	pamphlets = dict["pamphlets"]

func _save(mode):#only called from pause screen or chapter end
	file.open(file_path, File.WRITE)
	
	dict = {}
	dict["chapters_complete"] = chapters_complete
	dict["pamphlet_count"] = pamphlet_count
	dict["pamphlets"] = pamphlets
	var save_nodes = get_tree().get_nodes_in_group("Savable")
	for node in save_nodes:
		node._save(mode)
	print("__________________")
	print("saved")
	print(dict)
	print("__________________")
	file.store_line(to_json(dict))
	file.close()
	chapters_complete = dict["chapters_complete"]
	pamphlet_count = dict["pamphlet_count"]
	pamphlets = dict["pamphlets"]
	
func _reset(var path):#saves empty save for this path
	file.open(path, File.WRITE)
	var temp = {}
	temp["chapters_complete"] = 0
	temp["pamphlet_count"] = 0
	temp["pamphlets"] = {}
	print("reset :" + path)
	print(temp)
	file.store_line(to_json(temp))
	file.close()
	return temp
