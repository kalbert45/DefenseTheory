extends Control

var selected_augment
var pool = []

func _ready():
	Global.play_sfx('ting.wav', 0, false)
	pool = Augments.pick_three()
	# update descriptions and pics based on pool
	var resource1 = Augments.augment_resources[pool[0]]
	var resource2 = Augments.augment_resources[pool[1]]
	var resource3 = Augments.augment_resources[pool[2]]
	
	$Window/VBoxContainer/Button1/Title.text = resource1.name
	if resource1.count == 0:
		$Window/VBoxContainer/Button1/Description.text = resource1.description
	else:
		$Window/VBoxContainer/Button1/Description.text = resource1.secondary_d
	$Window/VBoxContainer/Button1/Pic.texture = resource1.pic
	
	$Window/VBoxContainer/Button2/Title.text = resource2.name
	if resource2.count == 0:
		$Window/VBoxContainer/Button2/Description.text = resource2.description
	else:
		$Window/VBoxContainer/Button2/Description.text = resource2.secondary_d
	$Window/VBoxContainer/Button2/Pic.texture = resource2.pic
	
	$Window/VBoxContainer/Button3/Title.text = resource3.name
	if resource3.count == 0:
		$Window/VBoxContainer/Button3/Description.text = resource3.description
	else:
		$Window/VBoxContainer/Button3/Description.text = resource3.secondary_d
	$Window/VBoxContainer/Button3/Pic.texture = resource3.pic


func _on_button_1_pressed():
	selected_augment = pool[0]
	Global.play_sfx('ting_higher.wav', 0, false)
	$AnimationPlayer.play("despawn2")
	$Window/VBoxContainer/Button1.disabled = true
	$Window/VBoxContainer/Button2.disabled = true
	$Window/VBoxContainer/Button3.disabled = true


func _on_button_2_pressed():
	selected_augment = pool[1]
	Global.play_sfx('ting_higher.wav', 0, false)
	$AnimationPlayer.play("despawn2")
	$Window/VBoxContainer/Button1.disabled = true
	$Window/VBoxContainer/Button2.disabled = true
	$Window/VBoxContainer/Button3.disabled = true

func _on_button_3_pressed():
	selected_augment = pool[2]
	Global.play_sfx('ting_higher.wav', 0, false)
	$AnimationPlayer.play("despawn2")
	$Window/VBoxContainer/Button1.disabled = true
	$Window/VBoxContainer/Button2.disabled = true
	$Window/VBoxContainer/Button3.disabled = true


func _on_animation_player_animation_finished(anim_name):
	match anim_name:
		'spawn2':
			$Window/VBoxContainer/Button1.disabled = false
			$Window/VBoxContainer/Button2.disabled = false
			$Window/VBoxContainer/Button3.disabled = false
		'despawn2':
			SignalBus.emit_signal('augment_selected', selected_augment)
			queue_free()
