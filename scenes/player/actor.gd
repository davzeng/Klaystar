extends KinematicBody2D
class_name Actor

const UP:Vector2 = Vector2(0, -1)

const MAX_SPEED:Vector2 = Vector2(1200, 1500)#max caps
const MAX_WATER_SPEED:Vector2 = Vector2(600,300)
const MAX_ROUGH_WALL_SPEED:int = 300
const MAX_RUN_SPEED:int = 400
const MAX_SWIM_SPEED:int = 300
const MAX_GLIDE_SPEED:int = 300

const GRAVITY:int = 1500#forces
const WATER_GRAVITY:int = 1500
const RUN_ACCEL:int = 2500
const SWIM_ACCEL:int = 1250
const WATER_BALL_ACCEL:int = -2000
const DECEL:int = 1500
const SWIM_DECEL:int = 2000

const JUMP_Y:int = -600#jump
const WALL_JUMP:Vector2 = Vector2(400, -600)
const WALL_JUMP_STUN_TIME:float = 0.25
var wall_jump_stun_window:float = 0
var stun_right:bool = false
#const JUMP_Y:int = -1200
const JUMP_EXTEND_TIME:float = 0.20
var jump_extend_window:float

const BUSH_BOUNCE = 0.8
const WINDOW:float = 0.1#window

var velocity:Vector2 = Vector2(0, 0)
var on_floor_window:float = 0
var jump_pressed_window:float = 0
