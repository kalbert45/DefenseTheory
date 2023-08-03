extends TextureProgressBar

@export var timer : Timer
@onready var anim_player = $AnimationPlayer

func _ready():
	pass


func _process(delta):
	value = ((timer.wait_time - timer.time_left)/timer.wait_time) * max_value
	if value == max_value:
		tint_over.a = 1
	else:
		tint_over.a = 0
