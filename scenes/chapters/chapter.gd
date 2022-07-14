extends Node

export var tracks:Array#tracks that will be loaded
export var chp_number:int

func _ready():
	if Save.dict.has("track"):
		MusicPlayer._play(Save.dict["track"], true)
	#MusicPlayer._load(tracks)#the loads the tracks

func _save(mode):#saves which chp the game is on or current chp
	if mode == Save.SAVE_AND_QUIT:#saves current chp
		Save.dict["chapter"] = get_tree().current_scene.filename
		if $SpawnsManager.currentSpawn:
			Save.dict["spawn"] = $SpawnsManager.currentSpawn.name
	elif mode == Save.RETURN_TO_SELECT:#does nothing
		return
	elif mode == Save.COMPLETE:#updates which chp the game is on
		if chp_number > Save.dict["chapters_complete"]:
			Save.dict["chapters_complete"] = chp_number

func _chapter_complete():#called if the chp is complete
	Save._save(Save.COMPLETE)
	HomeState.mode = 2
	get_tree().change_scene("res://scenes/hud/home.tscn")

func _play_track(song, saved):
	MusicPlayer._play(song, saved)

func _lower_audio():
	MusicPlayer._lower()

func _raise_audio():
	MusicPlayer._raise()
#getters
func _get_player() -> Node:
	return $Player/Klay

func _get_malo() -> Node:
	return $Player/Malo

func _get_player_camera() -> Node:
	return $Player/Camera

func _get_bounds_manager() -> Node:
	return $BoundsManager
	
func _get_spawns_manager() -> Node:
	return $SpawnsManager

func _get_cookies() -> Node:
	return $Miscs/Cookies

func _get_dialouge_layer() -> Node:
	return $DialougeLayer

func _get_animation_player() -> Node:
	return $AnimationPlayer

func _get_cookie_count() -> Node:
	return $GUILayer/CookieCount
