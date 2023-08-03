extends AudioStreamPlayer

var random = false
var range = Vector2(0.8, 1.2)

# Called when the node enters the scene tree for the first time.
func _ready():
	if random:
		pitch_scale = randf_range(range.x, range.y)
		
	play()


func _on_finished():
	queue_free()
