extends Node2D

const AUGMENT_SCREEN_SCENE = preload("res://Scenes/System/augment_screen.tscn")

func _ready():
	SignalBus.level_up.connect(_on_level_up)
	
func _on_level_up(level):
	get_tree().paused = true
	var screen = AUGMENT_SCREEN_SCENE.instantiate()
	add_child(screen)
	
