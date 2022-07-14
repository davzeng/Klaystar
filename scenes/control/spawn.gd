extends Area2D

var player :Node

func _ready():
	if Save.dict.has("spawn"):
		if Save.dict["spawn"] == name:#checks save
			get_node("..").currentSpawn = self
	player = get_tree().current_scene._get_player()

func _physics_process(_delta):
	if overlaps_area(player.get_node("BoundDetect")):#detects player entering
		get_node("..").currentSpawn = self

#getters
func _SpawnCoordinates() -> Vector2:
	return Vector2(position.x+16, 64 * scale.y + position.y-60)
