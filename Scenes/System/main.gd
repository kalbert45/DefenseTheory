extends Node2D

signal done_turning

const DEFAULT_ENEMY_SCENE = preload("res://Scenes/Objects/enemy.tscn")
const QUICK_ENEMY_SCENE = preload('res://Scenes/Objects/enemy_quick.tscn')

const BLOCK_SCENE = preload("res://Scenes/Objects/block.tscn")
const PARTICLE_SCENE = preload("res://Scenes/Objects/break_particles.tscn")
const ENEMY_PARTICLE_SCENE = preload("res://Scenes/Objects/enemy_break_particles.tscn")
const LIFE_PARTICLE_SCENE = preload("res://Scenes/Objects/life_break_particles.tscn")
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
var lives = 5
var level = 1
var _tween
#------------------------------------------------
# flood fill
var _flood_array = []
var _flood_queue = []

func _ready():
	done_turning.connect(set_turning)
	SignalBus.lose_life.connect(_on_lose_life)
	SignalBus.grow.connect(grow)
	SignalBus.break_block.connect(break_block)
	SignalBus.break_enemy.connect(break_enemy)
	_grid = Grid.new(grid_size, Vector2(21,21))
	grid_to_block[Vector2.ZERO] = $Grid/main_block
	
func augment_selected():
	level += 1
	$UI/Level.text = 'LVL ' + str(level)

func set_turning():
	turning = false

func turn_clockwise():
	if turning:
		return
	Global.play_sfx('snap.wav', -2, true)
	turning = true
	_tween = get_tree().create_tween()
	_tween.tween_property($Grid, 'rotation_degrees', $Grid.rotation_degrees + 90, 0.6).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	_tween.tween_callback(emit_signal.bind('done_turning'))
	
func turn_counterclockwise():
	if turning:
		return
	Global.play_sfx('snap.wav', -2, true)
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
			
	Global.play_sfx('grow.wav', 1.0, true)
	grid_to_block[grid_p].anim_player.play_backwards('click')
	grow_cd = true
	$UI/TextureProgressBar/AnimationPlayer.play("stretch")
	$Timers/GrowCDTimer.start()
			
func _on_lose_life():
	lives -= 1
	var life = $UI/Lives.get_child(lives)
	life.visible = false
	var particles = LIFE_PARTICLE_SCENE.instantiate()
	particles.global_position = life.global_position + Vector2(12,12)
	$UI.add_child(particles)
	
	if lives == 0:
		lose_game()
			
func lose_game():
	#Global.play_sfx('kick.wav', 1.0, true)
	$Timers/SpawnTimer.stop()
	
	for block in $Grid.get_children():
		if block.grid_p != Vector2.ZERO:
			clear_block(block)
			
	for enemy in get_tree().get_nodes_in_group('enemies'):
		break_enemy(enemy)
			
func break_enemy(enemy):
	Global.play_sfx('rim2.wav', 4, true)
	var particles = ENEMY_PARTICLE_SCENE.instantiate()
	particles.global_position = enemy.global_position
	particles.color = enemy.color
	$Particles.add_child(particles)
	$UI/ExpBar.gain_exp(enemy.exp)
	enemy.get_parent().queue_free()
			
# remove block. add effect.
func break_block(grid_p):
	#Global.play_sfx('ting.wav', 0.4, true)
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
				
	var blocks_cleared = 0
	for block in $Grid.get_children():
		if !_flood_array.has(block.grid_p):
			blocks_cleared += 1
			clear_block(block)

# for now, spawn at random point, random enemy
func spawn_enemy():
	var rand = randi_range(0, 1)
	var enemy
	match rand:
		0:
			enemy= DEFAULT_ENEMY_SCENE.instantiate()
		1:
			enemy= QUICK_ENEMY_SCENE.instantiate()
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
