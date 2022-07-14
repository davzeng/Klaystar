extends Node
class_name Link

#var action:String#position, anim and time only
var position:Vector2
var flip:bool
var anim:String
var on_floor:bool
#var velocity:Vector2
#var animation:String
var time:float
var next:Link

func _Link(double, vector_pos, boolean_one, string, link, boolean_two):
	#action = string
	time = double
	position = vector_pos
	flip = boolean_one
	anim = string
	#velocity = vector_vel
	next = link
	on_floor = boolean_two
