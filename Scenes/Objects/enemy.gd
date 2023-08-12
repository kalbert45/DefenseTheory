extends PathFollow2D

const SPEED = 25
var speed = SPEED
var color = Color('ffb3cb')
var exp = 1
var life = 2 : set = _set_life
var rand = true # doesnt do anything

func _ready():
	$Sprite2D.frame = life - 1
	
func _set_life(value):
	life = value
	if life > 0:
		$Sprite2D.frame = life - 1
	
# returns Path2D
func create_path(start_p, end_p):
	var path = Path2D.new()
	path.curve = Curve2D.new()
	path.curve.add_point(start_p)
	path.curve.add_point(end_p)
	
	return path
	
func push_back():
	speed = - 4 * SPEED

func _process(delta):
	$Sprite2D.rotation_degrees += 120 * delta
	progress += speed * delta
	speed = lerpf(speed, SPEED, 0.01)
