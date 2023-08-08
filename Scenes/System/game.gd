extends Node2D

const AUGMENT_SCREEN_SCENE = preload("res://Scenes/System/augment_screen.tscn")
var augment_screen = false

func _ready():
	SignalBus.level_up.connect(_on_level_up)
	SignalBus.augment_selected.connect(_on_augment_selected)
	
func _on_level_up(level):
	if augment_screen:
		return
	augment_screen = true
	get_tree().paused = true
	var screen = AUGMENT_SCREEN_SCENE.instantiate()
	add_child(screen)
	
func _on_augment_selected(augment):
	augment_screen = false
	Augments.pick_augment(augment)
	get_tree().paused = false
	$main.augment_selected(augment)
