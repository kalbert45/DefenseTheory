extends Node2D

var grid_p : Vector2
var breaking = false
var spawning = false

@onready var anim_player = $AnimationPlayer

func _ready():
	pass

# called externally
func grow():
	pass


func _on_area_2d_input_event(viewport, event, shape_idx):
	if event.is_action_pressed('left_click'):
		SignalBus.emit_signal('grow', grid_p)
		#$AnimationPlayer.play_backwards("click")
		
	# temp
	elif event.is_action_pressed('right_click'):
		SignalBus.emit_signal('break_block', grid_p)


# animation
func _on_area_2d_mouse_entered():
	$Sprite2D.material.set_shader_parameter('width', 1)
	$AnimationPlayer.play("hover")


# animation
func _on_area_2d_mouse_exited():
	$Sprite2D.material.set_shader_parameter('width', 0)
	$AnimationPlayer.play("default")


func _on_animation_player_animation_finished(anim_name):
	pass


func _on_hurtbox_body_entered(body):
	pass


func _on_hurtbox_area_entered(area):
	SignalBus.emit_signal('break_enemy', area.get_parent())
	SignalBus.emit_signal('break_block', grid_p)
