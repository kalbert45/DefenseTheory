extends Node2D

signal spawn_enemy(enemy, life, progress_pos, rand)

var stage = 0

# takes care of enemy staging. depends on time passed.

func _on_spawn_timer_timeout():
	match stage:
		0:
			emit_signal("spawn_enemy", Constants.ENEMY_TYPES.DEFAULT, 1, null, null)
		1:
			match randi_range(0, 1):
				0:
					emit_signal("spawn_enemy", Constants.ENEMY_TYPES.QUICK, 1, null, null)
				1:
					emit_signal("spawn_enemy", Constants.ENEMY_TYPES.DEFAULT, 1, null, null)
		2:
			match randi_range(0, 2):
				0:
					emit_signal("spawn_enemy", Constants.ENEMY_TYPES.QUICK, randi_range(1, 2), null, null)
				1:
					emit_signal("spawn_enemy", Constants.ENEMY_TYPES.DEFAULT, randi_range(1, 2), null, null)
		3:
			match randi_range(0, 2):
				0:
					emit_signal("spawn_enemy", Constants.ENEMY_TYPES.QUICK, randi_range(1, 2), null, null)
				1:
					emit_signal("spawn_enemy", Constants.ENEMY_TYPES.DEFAULT, randi_range(1, 2), null, null)
				2:
					emit_signal("spawn_enemy", Constants.ENEMY_TYPES.QUICKER, randi_range(1, 2), null, null)
		4:
			match randi_range(0, 2):
				0:
					emit_signal("spawn_enemy", Constants.ENEMY_TYPES.QUICK, randi_range(2, 3), null, null)
					emit_signal("spawn_enemy", Constants.ENEMY_TYPES.QUICK, randi_range(2, 3), null, null)
				1:
					emit_signal("spawn_enemy", Constants.ENEMY_TYPES.DEFAULT, randi_range(2, 3), null, null)
					emit_signal("spawn_enemy", Constants.ENEMY_TYPES.DEFAULT, randi_range(2, 3), null, null)
				2:
					emit_signal("spawn_enemy", Constants.ENEMY_TYPES.QUICKER, randi_range(2, 3), null, null)
					emit_signal("spawn_enemy", Constants.ENEMY_TYPES.QUICKER, randi_range(2, 3), null, null)
		5:
			match randi_range(0, 2):
				0:
					emit_signal("spawn_enemy", Constants.ENEMY_TYPES.QUICK, 3, null, null)
					emit_signal("spawn_enemy", Constants.ENEMY_TYPES.QUICK, 3, null, null)
				1:
					emit_signal("spawn_enemy", Constants.ENEMY_TYPES.DEFAULT, 3, null, null)
					emit_signal("spawn_enemy", Constants.ENEMY_TYPES.DEFAULT, 3, null, null)
				2:
					emit_signal("spawn_enemy", Constants.ENEMY_TYPES.QUICKER, 3, null, null)
					emit_signal("spawn_enemy", Constants.ENEMY_TYPES.QUICKER, 3, null, null)
		6:
			match randi_range(0, 2):
				0:
					emit_signal("spawn_enemy", Constants.ENEMY_TYPES.QUICK, 3, null, null)
					emit_signal("spawn_enemy", Constants.ENEMY_TYPES.QUICK, 3, null, null)
				1:
					emit_signal("spawn_enemy", Constants.ENEMY_TYPES.DEFAULT, 3, null, null)
					emit_signal("spawn_enemy", Constants.ENEMY_TYPES.DEFAULT, 3, null, null)
				2:
					emit_signal("spawn_enemy", Constants.ENEMY_TYPES.QUICKER, 3, null, null)
					emit_signal("spawn_enemy", Constants.ENEMY_TYPES.QUICKER, 3, null, null)


func _on_stage_timer_timeout():
	match stage:
		0:
			stage += 1
			$StageTimer.start()
			$SpawnTimer.wait_time = 1.5
		1:
			stage += 1
			$StageTimer.start()
			$SpawnTimer.wait_time = 1.0
			
			for i in range(10):
				emit_signal("spawn_enemy", Constants.ENEMY_TYPES.QUICK, 2, i * (1.0 / 10.0), true)
		2:
			stage += 1
			$StageTimer.wait_time = 120
			$StageTimer.start()
			$SpawnTimer.wait_time = 0.5
		3:
			stage += 1
			$StageTimer.wait_time = 120
			$StageTimer.start()
			$SpawnTimer.wait_time = 0.5
			
			for i in range(15):
				emit_signal("spawn_enemy", Constants.ENEMY_TYPES.QUICKER, 3, i * (1.0 / 15.0), true)
		4:
			stage += 1
			$StageTimer.wait_time = 120
			$StageTimer.start()
			$SpawnTimer.wait_time = 0.25
		5:
			stage += 1
			$StageTimer.stop()
			#$StageTimer.wait_time = 120
			#$StageTimer.start()
			$SpawnTimer.wait_time = 0.15
			for i in range(50):
				emit_signal("spawn_enemy", Constants.ENEMY_TYPES.DEFAULT, 3, i * (1.0 / 50.0), true)
				
	print(stage)
