extends Node2D

var type = 0

func _ready():
	if randf() < 0.5:
		type = 1
		$Sprite2D.texture = load("res://Assets/Sprites/heart_orb-sheet.png")
	
	$AnimationPlayer.play("spawn")

func _on_timer_timeout():
	$AnimationPlayer.play("despawn")


func _on_animation_player_animation_finished(anim_name):
	match anim_name:
		'despawn':
			call_deferred('queue_free')


func _on_area_2d_area_entered(area):
	match type:
		0:
			area.get_parent().emit_grow()
			$Area2D/CollisionShape2D.set_deferred('disabled', true)
			call_deferred('queue_free')
		1:
			Global.play_sfx('life_up.wav')
			area.get_parent().emit_gain()
			$Area2D/CollisionShape2D.set_deferred('disabled', true)
			call_deferred('queue_free')
	
