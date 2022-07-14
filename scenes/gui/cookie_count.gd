extends Control

var count:int = 0

func _ready():#################to be changed to pamphlet
	#sets pos
	rect_position.y = -200
	#sets text
	if Save.dict.has("cookie_count"):
		count = Save.dict["cookie_count"]
	else:
		count = 0
	$VBox/Text.text = String(count)

func _add():#adds pamphlets
	count += 1
	#anim
	$VBox/Text.text = String(count)
	$Tween.interpolate_property(self, "rect_position", Vector2(0,-200), Vector2(0,0), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()

func _on_Tween_tween_completed(object, key):
	if rect_position.y == 0:#starts retract timer if the node is revealed
		$Timer.start()


func _on_Timer_timeout():
	$Timer.stop()#retracts
	$Tween.interpolate_property(self, "rect_position",Vector2(0,0), Vector2(0,-200), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()

#saves pamphlets
func _save(mode):
	Save.dict["cookie_count"] = count
