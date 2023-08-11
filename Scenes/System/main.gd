extends Node2D

signal done_turning

const DEFAULT_ENEMY_SCENE = preload("res://Scenes/Objects/enemy.tscn")
const QUICK_ENEMY_SCENE = preload('res://Scenes/Objects/enemy_quick.tscn')

const BLOCK_SCENE = preload("res://Scenes/Objects/block.tscn")
const ORB_SCENE = preload("res://Scenes/Objects/orb.tscn")
const EXPLOSION_SCENE = preload("res://Scenes/Objects/explosion.tscn")
const PARTICLE_SCENE = preload("res://Scenes/Objects/break_particles.tscn")
const ENEMY_PARTICLE_SCENE = preload("res://Scenes/Objects/enemy_break_particles.tscn")
const LIFE_PARTICLE_SCENE = preload("res://Scenes/Objects/life_break_particles.tscn")
const BLOCK_SIZE = 16
const CENTER = Vector2.ZERO
#------------------------------------------------
var testing = true # for testing
var game_started = false
var grid_size = Vector2(11,11)
var separation = 5 # in pixels, between blocks
var cell_size = 16
var _grid : Grid
#---------------------------------------------
# active variables
var use_explosion = false
var explosion_radius = 32
var grid_to_block = {}
var turning = false # used to handle turning
var grow_cd = false # used for grow cd
var lives = 5
var level = 1
var _tween
#----------------------------------------------
# augment variables
var deep_clean_count = 0
#------------------------------------------------
# flood fill
var _flood_array = []
var _flood_queue = []

func _ready():
	done_turning.connect(set_turning)
	SignalBus.lose_life.connect(_on_lose_life)
	SignalBus.gain_life.connect(_on_gain_life)
	SignalBus.grow.connect(grow)
	SignalBus.break_block.connect(break_block)
	SignalBus.break_enemy.connect(break_enemy)
	_grid = Grid.new(grid_size, Vector2(21,21))
	grid_to_block[Vector2.ZERO] = $Grid/main_block
	

# some augment functionalities
func augment_selected(augment):
	level += 1
	$UI/Level.text = 'LVL ' + str(level)
	$UI/ExpBar.set_max_exp(level)
	
	match augment:
		Augments.AUGMENTS.GROW_CD_REDUC:
			$Timers/GrowCDTimer.wait_time *= 0.8
		Augments.AUGMENTS.ROTATE_CD_REDUC:
			$Timers/TurnCDTimer.wait_time *= 0.75
		Augments.AUGMENTS.COMPACT:
			_grid = Grid.new(grid_size, Vector2(17,17))
			for v in grid_to_block.keys():
				if v == Vector2.ZERO:
					continue
				grid_to_block[v].tween_to(_grid.calculate_map_position(v))
		Augments.AUGMENTS.EXTEND:
			Global.play_sfx('grow.wav', 1.0, true)
			var extension = Augments.augment_resources[augment].count
			grid_size = Vector2(grid_size.x + 2*extension, grid_size.y + 2*extension)
			_grid = Grid.new(grid_size, _grid.cell_size)
			
			# create max layer
			var max_layer = 1
			for block in $Grid.get_children():
				max_layer = max(max_layer, abs(block.grid_p.x))
				max_layer = max(max_layer, abs(block.grid_p.y))
			# spawn blocks in max layer
			var positions = []
			for i in range(-max_layer, max_layer+1):
				positions.append(Vector2(i, max_layer))
				positions.append(Vector2(i, -max_layer))
				positions.append(Vector2(max_layer, i))
				positions.append(Vector2(-max_layer, i))
			for p in positions:
				if grid_to_block.has(p):
					grid_to_block[p].grow()
					continue
				var new_block = BLOCK_SCENE.instantiate()
				new_block.grid_p = p
				new_block.position = _grid.calculate_map_position(p)
				grid_to_block[p] = new_block
				$Grid.add_child(new_block)
		Augments.AUGMENTS.EXPLOSION:
			use_explosion = true
			explosion_radius = 16 * (Augments.augment_resources[augment].count + 1)

func set_turning():
	turning = false

func turn_clockwise():
	if turning:
		return
	var shield_count = Augments.augment_resources[Augments.AUGMENTS.SHIELD].count
	if shield_count > 0:
		for block in $Grid.get_children():
			block.shield_timer.wait_time = 0.5 * shield_count
			block.shield_active = true
	check_deep_clean()
	Global.play_sfx('snap.wav', -2, true)
	turning = true
	_tween = get_tree().create_tween()
	_tween.tween_property($Grid, 'rotation_degrees', $Grid.rotation_degrees + 90, 0.6).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	_tween.tween_callback(emit_signal.bind('done_turning'))
	
func turn_counterclockwise():
	if turning:
		return
	var shield_count = Augments.augment_resources[Augments.AUGMENTS.SHIELD].count
	if shield_count > 0:
		for block in $Grid.get_children():
			block.shield_timer.wait_time = 0.5 * shield_count
			block.shield_active = true
	check_deep_clean()
	Global.play_sfx('snap.wav', -2, true)
	turning = true
	_tween = get_tree().create_tween()
	_tween.tween_property($Grid, 'rotation_degrees', $Grid.rotation_degrees - 90, 0.6).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	_tween.tween_callback(emit_signal.bind('done_turning'))
	
func check_deep_clean():
	var resource = Augments.augment_resources[Augments.AUGMENTS.PENTAGRAM]
	if resource.count == 0:
		return
	deep_clean_count += 1
	var quota = 11 - resource.count
	if deep_clean_count >= quota:
		deep_clean_count = 0
		clear_enemies()
	
# if position is open, create a new block. else, call grow on the block.
func grow(grid_p, from_orb = false):
	if grow_cd and !from_orb:
		return
	if grid_p == Vector2.ZERO and !game_started:
		$Timers/SpawnTimer.start()
		game_started = true
	
	var pattern = Augments.augment_resources[Augments.AUGMENTS.GROWTH_PATTERN].count
	var positions = [grid_p]
	for dir in Constants.DIRECTIONS.values():
		positions.append(grid_p + dir)
	if pattern >= 1:
		for dir in Constants.DIRECTIONS_V2.values():
			positions.append(grid_p + dir)
	if pattern >= 2:
		for dir in Constants.DIRECTIONS_V3.values():
			positions.append(grid_p + dir)
	if pattern >= 3:
		for dir in Constants.DIRECTIONS_V4.values():
			positions.append(grid_p + dir)
	if pattern >= 4:
		for dir in Constants.DIRECTIONS_V5.values():
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
			$Grid.call_deferred('add_child', new_block)
			
	Global.play_sfx('grow.wav', 1.0, true)
	grid_to_block[grid_p].anim_player.play_backwards('click')
	grow_cd = true
	$UI/TextureProgressBar/AnimationPlayer.play("stretch")
	$Timers/GrowCDTimer.start()
			
func _on_gain_life():
	lives += 1
	lives = clampi(lives, 0, 5)
	var life = $UI/Lives.get_child(lives - 1)
	life.visible = true
			
func _on_lose_life():
	if testing:
		return
	
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
	
func clear_enemies():
	Global.play_sfx('kick2.wav', 4, true)
	for enemy in get_tree().get_nodes_in_group('enemies'):
		var particles = ENEMY_PARTICLE_SCENE.instantiate()
		particles.global_position = enemy.global_position
		particles.color = enemy.color
		$Particles.add_child(particles)
		enemy.get_parent().queue_free()
			
# remove block. add effect.
func break_block(grid_p):
	#Global.play_sfx('ting.wav', 0.4, true)
	grid_to_block.erase(grid_p)
	break_stray_blocks()
	
# version that ignores stray blocks
func clear_block(block):
	var garbage_count = Augments.augment_resources[Augments.AUGMENTS.GARBAGE_COLLECTION].count
	if garbage_count > 0:
		var chance = 0.03 + (0.03 * garbage_count)
		if randf() < chance:
			var orb = ORB_SCENE.instantiate()
			orb.set_deferred('global_position', block.global_position)
			$Effects.call_deferred('add_child', orb)
	
	if grid_to_block.has(block.grid_p):
		grid_to_block.erase(block.grid_p)
		
	if use_explosion:
		var explosion = EXPLOSION_SCENE.instantiate()
		explosion.set_deferred('global_position', block.global_position)
		$Effects.call_deferred('add_child', explosion)
	else:
		var particles = PARTICLE_SCENE.instantiate()
		particles.global_position = block.global_position
		$Particles.add_child(particles)
	
	block.call_deferred('queue_free')
	
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
	
# for testing
func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		spawn_enemy()
	
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
