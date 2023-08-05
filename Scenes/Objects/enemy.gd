extends PathFollow2D

const SPEED = 25
var color = Color('ffb3cb')
var exp = 1

func _ready():
	pass
	
# returns Path2D
func create_path(start_p, end_p):
	var path = Path2D.new()
	path.curve = Curve2D.new()
	path.curve.add_point(start_p)
	path.curve.add_point(end_p)
	
	return path

func _process(delta):
	progress += SPEED * delta
