extends Node2D

var grid_p = Vector2.ZERO

@onready var anim_player = $AnimationPlayer

# move shadow
#func turn(angle, _time):
#	$Sprite2D/shadow.transform = $Sprite2D/shadow.transform.rotated(-angle)

func _on_area_2d_mouse_entered():
	$Sprite2D.material.set_shader_parameter('width', 1)
	$AnimationPlayer.play("hover")


func _on_area_2d_input_event(viewport, event, shape_idx):
	if event.is_action_pressed('left_click'):
		SignalBus.emit_signal('grow', Vector2.ZERO)
		#$AnimationPlayer.play_backwards("click")


func _on_area_2d_mouse_exited():
	$Sprite2D.material.set_shader_parameter('width', 0)
	$AnimationPlayer.play("default")


func _on_hurtbox_area_entered(area):
	Global.play_sfx('hurt.wav', null, true)
	SignalBus.emit_signal('break_enemy', area.get_parent())
	SignalBus.emit_signal('lose_life')
