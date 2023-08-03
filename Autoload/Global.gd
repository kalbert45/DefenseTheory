extends Node

const SFX_SCENE = preload('res://Scenes/System/sfx.tscn')

# General sfx player
func play_sfx(path, _db = null, _random=null, _range=null):
	var s = load('res://Assets/Sounds/SFX/' + path)
	var sfx = SFX_SCENE.instantiate()
	if _db:
		sfx.volume_db = _db
	if _random:
		sfx.random = _random
	if _range:
		sfx.range = _range
	sfx.stream = s
	add_child(sfx)
