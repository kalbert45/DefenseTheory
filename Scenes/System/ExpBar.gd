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
			max_value = 15
		3:
			max_value = 20
		4:
			max_value = 40
		5:
			max_value = 60
		6:
			max_value = 80
		7:
			max_value = 110
		8:
			max_value = 140
		9:
			max_value = 180
		10:
			max_value = 250
		11:
			max_value = 300
		12:
			max_value = 350
		13:
			max_value = 400
		14:
			max_value = 500
		_:
			max_value = (level * 50) - 200
