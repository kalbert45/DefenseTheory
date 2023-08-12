extends PathFollow2D

const SPEED = 70
const CURVE_CONST = 70
var speed = SPEED
var color = Color('ffb3cb')
var exp = 3
var life = 2 : set = _set_life
var rand = true

func _ready():
	$Sprite2D.frame = life - 1

func _set_life(value):
	life = value
	if life > 0:
		$Sprite2D.frame = life - 1

# returns Path2D. attempt a spiral path
func create_path(start_p, end_p):
	
	
	var dist = start_p.distance_to(end_p)
	var path = Path2D.new()
	path.curve = Curve2D.new()
	path.curve.add_point(start_p)
	
	# point 2 should create a diagonal path. add 2 half vectors
	var v_orth1 = ((end_p - start_p) / 2).orthogonal()
	#var v_orth2 = -(v_orth1 / 2).orthogonal()
	#var v_orth3 = -(v_orth2 / 2).orthogonal()
	if rand:
		if randi_range(0, 1) == 1:
			v_orth1 *= -1
	#	v_orth3 *= -1
	path.curve.add_point(end_p + v_orth1)
	#path.curve.add_point(end_p + v_orth2)
	#path.curve.add_point(end_p + v_orth3)
	path.curve.add_point(end_p)
	
	return path

func push_back():
	speed = - 4 * SPEED

func _process(delta):
	$Sprite2D.rotation_degrees += 240 * delta
	progress += speed * delta
	speed = lerpf(speed, SPEED, 0.01)
