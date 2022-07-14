extends ParallaxLayer


export var speed:int

# Called when the node enters the scene tree for the first time.
func _ready():
	return
	#if $AnimatedSprite:
	#	$AnimatedSprite.playing = true

func _process(delta):
	self.motion_offset.x -= speed*delta
