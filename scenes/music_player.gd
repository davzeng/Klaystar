extends AudioStreamPlayer


var path: String = "res://assets/audio/tracks/"
var current_track: String
var tracks: Dictionary
var next_track:String = ""
var sav:bool = false

func _ready():
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with(".") and not file.ends_with("import"):
			tracks[file] = load(path + file)

			
func _load(_songs):#takes in an array of strings
	pass
	
func _play(song, saved):
	if playing:
		if next_track == song:
			return
		if song == "":
			stop()
			return
		next_track = song
		sav = saved
		$Tween.interpolate_property(self, "volume_db", volume_db, -80, 
			1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.start()
	else:
		set_stream(tracks[song])
		if saved == true:
			current_track = song
		play()

func _stop():
	stop()

func _save(mode):#
	if mode == Save.SAVE_AND_QUIT:
		Save.dict["track"] = current_track
		pass
		
func _lower():
	$Tween.interpolate_property(self, "volume_db", volume_db, -10, 
		1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	next_track = ""
	$Tween.start()

func _raise():
	$Tween.interpolate_property(self, "volume_db", volume_db, 0, 
		1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	next_track = ""
	$Tween.start()

func _on_Tween_tween_completed(object, key):
	if next_track != "":
		set_stream(tracks[next_track])
		if sav == true:
			current_track = next_track
		play()
		set_volume_db(0)
		next_track = ""
