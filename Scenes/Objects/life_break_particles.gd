extends Node2D

var color : Color

func _ready():
	if color:
		$CPUParticles2D.color = color
	$CPUParticles2D.emitting = true

func _on_timer_timeout():
	queue_free()
