extends PathFollow2D

const SPEED = 40
const CURVE_CONST = 70
var color = Color('ffb3cb')
var exp = 2

func _ready():
	pass
	
# returns Path2D. attempt a semicircle path
func create_path(start_p, end_p):
	var path = Path2D.new()
	path.curve = Curve2D.new()
	path.curve.add_point(start_p)
	
	# point 2 should create a diagonal path. add 2 half vectors
	var v = (end_p - start_p) / 2
	var v_orth = v.orthogonal()
	if randi_range(0, 1) == 1:
		v_orth *= -1
	var v_in = -v.normalized() * CURVE_CONST
	var v_out = -v_in
	path.curve.add_point(start_p + v + v_orth, v_in, v_out)
	path.curve.add_point(end_p)
	
	return path

func _process(delta):
	progress += SPEED * delta
