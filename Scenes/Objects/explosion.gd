extends Node2D

@onready var particles = $CPUParticles

func _ready():
	var count = Augments.augment_resources[Augments.AUGMENTS.EXPLOSION].count
	
	$Area2D/CollisionShape2D.shape.set_deferred("radius", 16 * (count + 1))
	$Area2D/CollisionShape2D.set_deferred("disabled", false)
	
	match count:
		1:
			particles.lifetime = 0.3
			particles.emission_sphere_radius = 5
			particles.initial_velocity_min = 110
			particles.initial_velocity_max = 160
			particles.amount = 16
			particles.scale_amount_min = 0.5
			particles.scale_amount_max = 2
		2:
			particles.lifetime = 0.5
			particles.emission_sphere_radius = 10
			particles.initial_velocity_min = 130
			particles.initial_velocity_max = 180
			particles.amount = 16
			particles.scale_amount_min = 0.5
			particles.scale_amount_max = 2
		3:
			particles.lifetime = 0.7
			particles.emission_sphere_radius = 15
			particles.initial_velocity_min = 150
			particles.initial_velocity_max = 200
			particles.amount = 16
			particles.scale_amount_min = 0.5
			particles.scale_amount_max = 2
		4:
			particles.lifetime = 0.8
			particles.emission_sphere_radius = 20
			particles.initial_velocity_min = 160
			particles.initial_velocity_max = 210
			particles.amount = 24
			particles.scale_amount_min = 1
			particles.scale_amount_max = 2.5

func explode():
	Global.play_sfx('pop.wav', 0, true)
	var enemies = $Area2D.get_overlapping_areas()
	for area in enemies:
		SignalBus.emit_signal('break_enemy', area.get_parent())

func _on_timer_timeout():
	queue_free()

func _on_animation_player_animation_finished(anim_name):
	match anim_name:
		'spawn':
			particles.emitting = true
			explode()
