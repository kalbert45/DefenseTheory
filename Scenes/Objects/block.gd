extends Node2D

var grid_p : Vector2
var breaking = false
var spawning = false
var fortify_count = 0

var _tween

@onready var anim_player = $AnimationPlayer

func _ready():
	pass

# called externally
func grow():
	var fortify_limit = Augments.augment_resources[Augments.AUGMENTS.FORTIFY].count
	if fortify_count >= fortify_limit:
		return
		
	# add fortify count, also change how it looks
	fortify_count += 1
	match fortify_count:
		1:
			$Layer2/AnimationPlayer.play("spawn")
		2:
			$Layer3/AnimationPlayer.play("spawn")
		3:
			$Sprite2D.texture = Constants.BLOCK_V2_TEX
		4:
			$Layer2.texture = Constants.BLOCK_LAYER2_V2_TEX
		5:
			$Layer3.texture = Constants.BLOCK_LAYER3_V2_TEX

# updates fortify visuals
func break_fortify():
	match fortify_count:
		0:
			$Layer2/AnimationPlayer.play_backwards("spawn")
		1:
			$Layer3/AnimationPlayer.play_backwards("spawn")
		2:
			$Sprite2D.texture = Constants.BLOCK_TEX
		3:
			$Layer2.texture = Constants.BLOCK_LAYER2_TEX
		4:
			$Layer3.texture = Constants.BLOCK_LAYER3_TEX

# used for compaction. use position
func tween_to(pos):
	_tween = get_tree().create_tween()
	_tween.tween_property(self, 'position', pos, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

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
	if fortify_count <= 0:
		SignalBus.emit_signal('break_enemy', area.get_parent())
		SignalBus.emit_signal('break_block', grid_p)
	else:
		SignalBus.emit_signal('break_enemy', area.get_parent())
		fortify_count -= 1
		break_fortify()
