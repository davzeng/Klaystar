extends Node2D

#exports
export var length:int
#image
var image:Image
var image_texture:ImageTexture

var player :Node

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().current_scene._get_player()
	
	$Sprite.offset = Vector2(2, 8*length)
	$Area.position = Vector2(4, 8*length)
	$Area/CollisionShape2D.shape.extents.x = 4
	$Area/CollisionShape2D.shape.extents.y = 8*length;
	
	var temp_image:Image# = Image.new()
	temp_image = load("res://assets/imgs/miscs/rough_wall.png")
	
	image = Image.new()
	image.create(12, 16*length, false, Image.FORMAT_RGBA8)
	
	image.lock()
	temp_image.lock()
	for i in image.get_width():
		for j in image.get_height():
			image.set_pixel(i, j, temp_image.get_pixel(i,j%temp_image.get_height()))
	image.unlock()
	temp_image.unlock()
	
	image_texture = ImageTexture.new()
	image_texture.create_from_image(image)
	$Sprite.texture = image_texture

func _physics_process(delta):
	if $Area.overlaps_body(player):
		if rotation_degrees == 0:
			player.on_rough_wall_l = true
		else:
			player.on_rough_wall_r = true


func _on_Area_body_exited(body):
	if body == player:
		if rotation_degrees == 0:
			player.on_rough_wall_l = false
		else:
			player.on_rough_wall_r = false
