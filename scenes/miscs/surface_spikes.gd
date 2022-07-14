extends Node2D

#exports
export var spike_length:int
export var image_dir:String
#imager
var image:Image
var image_texture:ImageTexture

func _ready():
	#sets area
	$Sprite.offset = Vector2(32*spike_length, 10)
	$Area.position = Vector2(32*spike_length, 10)
	
	#rotation
	if int(round(rotation_degrees)) == 90 or int(round(rotation_degrees)) == 270:
		$Area/CollisionShape2D.shape.extents.x = 32*spike_length-4
		$Area/CollisionShape2D.shape.extents.y = 6
	else:
		$Area/CollisionShape2D.shape.extents.x = 32*spike_length
		$Area/CollisionShape2D.shape.extents.y = 6
	
	#creates img
	var temp_image:Image# = Image.new()
	temp_image = load(image_dir)
	
	image = Image.new()
	image.create(64*spike_length, 20, false, Image.FORMAT_RGBA8)
	
	image.lock()
	temp_image.lock()
	for i in image.get_width():
		for j in image.get_height():
			image.set_pixel(i, j, temp_image.get_pixel(i%temp_image.get_width(),j))
	image.unlock()
	temp_image.unlock()
	
	image_texture = ImageTexture.new()
	image_texture.create_from_image(image)
	$Sprite.texture = image_texture

func _on_Area_body_entered(body):
	if visible:#checks activity
		if body.name == "Klay":
			body.dead = true
