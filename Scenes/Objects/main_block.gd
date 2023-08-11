extends Node2D

var grid_p = Vector2.ZERO
var shield_active = false : set = _set_shield_active

@onready var anim_player = $AnimationPlayer
@onready var shield_timer = $Sprite2D/shield/Timer


func _set_shield_active(value):
	shield_active = value
	if shield_active:
		$Sprite2D/shield.visible = true
		$Sprite2D/shield/Timer.start()
	else:
		$Sprite2D/shield.visible = false
		$Sprite2D/shield/Timer.stop()
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

func emit_grow():
	SignalBus.emit_signal('grow', grid_p, true)
	
func emit_gain():
	SignalBus.emit_signal('gain_life')

func _on_area_2d_mouse_exited():
	$Sprite2D.material.set_shader_parameter('width', 0)
	$AnimationPlayer.play("default")


func _on_hurtbox_area_entered(area):
	if shield_active:
		SignalBus.emit_signal('break_enemy', area.get_parent())
		self.shield_active = false
		return
	
	Global.play_sfx('hurt.wav', null, true)
	SignalBus.emit_signal('break_enemy', area.get_parent())
	SignalBus.emit_signal('lose_life')



func _on_timer_timeout():
	#$Sprite2D/shield/AnimationPlayer.play("activate")
	self.shield_active = false
