extends TextureProgressBar

var level = 1

func _ready():
	set_max_exp(1)

func gain_exp(exp):
	value += exp
	if value == max_value:
		level += 1
		SignalBus.emit_signal('level_up', level)
	
func set_max_exp(level):
	value = 0
	match level:
		1:
			max_value = 10
		2:
			max_value = 20
		3:
			max_value = 40
