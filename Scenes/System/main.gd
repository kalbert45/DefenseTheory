extends Node2D

signal done_turning

const DEFAULT_ENEMY_SCENE = preload("res://Scenes/Objects/enemy.tscn")

const BLOCK_SCENE = preload("res://Scenes/Objects/block.tscn")
const PARTICLE_SCENE = preload("res://Scenes/Objects/break_particles.tscn")
const ENEMY_PARTICLE_SCENE = preload("res://Scenes/Objects/enemy_break_particles.tscn")
const BLOCK_SIZE = 16
const CENTER = Vector2.ZERO
var game_started = false
var grid_size = Vector2(11,11)
var separation = 5 # in pixels, between blocks
var cell_size = 16
var _grid : Grid
#---------------------------------------------
# active variables
var grid_to_block = {}
var turning = false # used to handle turning
var grow_cd = false # used for grow cd
var _tween
#------------------------------------------------
# flood fill
var _flood_array = []
var _flood_queue = []

func _ready():
	done_turning.connect(set_turning)
	SignalBus.grow.connect(grow)
	SignalBus.break_block.connect(break_block)
	SignalBus.break_enemy.connect(break_enemy)
	_grid = Grid.new(grid_size, Vector2(21,21))
	grid_to_block[Vector2.ZERO] = $Grid/main_block

# temp
func _unhandled_input(event):
	if turning:
		return
#	if event.is_action_pressed('turn_clockwise'):
#		turn_clockwise()
#	elif event.is_action_pressed('turn_counterclockwise'):
#		turn_counterclockwise()

func set_turning():
	turning = false

func turn_clockwise():
	if turning:
		return
	turning = true
	_tween = get_tree().create_tween()
	_tween.tween_property($Grid, 'rotation_degrees', $Grid.rotation_degrees + 90, 0.6).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	_tween.tween_callback(emit_signal.bind('done_turning'))
	
func turn_counterclockwise():
	if turning:
		return
	turning = true
	_tween = get_tree().create_tween()
	_tween.tween_property($Grid, 'rotation_degrees', $Grid.rotation_degrees - 90, 0.6).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	_tween.tween_callback(emit_signal.bind('done_turning'))
	
# if position is open, create a new block. else, call grow on the block.
func grow(grid_p):
	if grow_cd:
		return
	if grid_p == Vector2.ZERO and !game_started:
		$Timers/SpawnTimer.start()
		game_started = true
		
	var positions = [grid_p]
	for dir in Constants.DIRECTIONS.values():
		positions.append(grid_p + dir)
	for p in positions:
		if !_grid.is_within_bounds(p):
			continue
		
		if grid_to_block.has(p):
			if grid_to_block[p].has_method('grow'):
				grid_to_block[p].grow()
		else:
			var new_block = BLOCK_SCENE.instantiate()
			new_block.grid_p = p
			new_block.position = _grid.calculate_map_position(p)
			grid_to_block[p] = new_block
			$Grid.add_child(new_block)
			
	Global.play_sfx('basic_boop.wav', 0.8, true)
	grid_to_block[grid_p].anim_player.play_backwards('click')
	grow_cd = true
	$UI/TextureProgressBar/AnimationPlayer.play("stretch")
	$Timers/GrowCDTimer.start()
			
func break_enemy(enemy):
	var particles = ENEMY_PARTICLE_SCENE.instantiate()
	particles.global_position = enemy.global_position
	$Particles.add_child(particles)
	enemy.queue_free()
			
# remove block. add effect.
func break_block(grid_p):
	Global.play_sfx('blip.wav', 0.6, true)
	grid_to_block.erase(grid_p)
	break_stray_blocks()
	
# version that ignores stray blocks
func clear_block(block):
	if grid_to_block.has(block.grid_p):
		grid_to_block.erase(block.grid_p)
	var particles = PARTICLE_SCENE.instantiate()
	particles.global_position = block.global_position
	$Particles.add_child(particles)
	block.queue_free()
	
# from main block, flood fill. remove any blocks that arent in the flood fill.
func break_stray_blocks():
	# fill flood array
	_flood_array.clear()
	_flood_queue.clear()
	_flood_fill(Vector2.ZERO)
			
# fills flood array
func _flood_fill(node):
	_flood_queue.push_back(node)
	
	while !_flood_queue.is_empty():
		var n = _flood_queue.pop_front()
	
		if _grid.is_within_bounds(n) and grid_to_block.has(n):
			if !(n in _flood_array):
				_flood_array.append(n)
				_flood_queue.push_back(n + Constants.DIRECTIONS.UP)
				_flood_queue.push_back(n + Constants.DIRECTIONS.DOWN)
				_flood_queue.push_back(n + Constants.DIRECTIONS.LEFT)
				_flood_queue.push_back(n + Constants.DIRECTIONS.RIGHT)
				
	for block in $Grid.get_children():
		if !_flood_array.has(block.grid_p):
			clear_block(block)

# for now, spawn at random point
func spawn_enemy():
	var enemy = DEFAULT_ENEMY_SCENE.instantiate()
	
	$SpawnPoints/PathFollow2D.progress_ratio = randf_range(0.0, 1.0)
	var start_p = $SpawnPoints/PathFollow2D.global_position
	var end_p = $Grid/main_block.global_position
	
	var path = enemy.create_path(start_p, end_p)
	$Enemies.add_child(path)
	path.add_child(enemy)
	
func _on_spawn_timer_timeout():
	spawn_enemy()

func _on_grow_cd_timer_timeout():
	grow_cd = false

func _on_turn_cd_timer_timeout():
	$UI/LeftButton.disabled = false
	$UI/RightButton.disabled = false


func _on_left_button_pressed():
	turn_counterclockwise()
	$UI/LeftButton/TextureProgressBar/AnimationPlayer.play("stretch")
	$UI/LeftButton.disabled = true
	$UI/RightButton.disabled = true
	$Timers/TurnCDTimer.start()
	


func _on_right_button_pressed():
	turn_clockwise()
	$UI/RightButton/TextureProgressBar/AnimationPlayer.play("stretch")
	$UI/LeftButton.disabled = true
	$UI/RightButton.disabled = true
	$Timers/TurnCDTimer.start()
