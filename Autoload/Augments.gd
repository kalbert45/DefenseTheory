extends Node

# need to pick 3 available. availability depends on level and on state of other
# augments.
# function for creating pool
# function for picking 3 augments
# augment implementation handled locally

func _ready():
	randomize()

enum AUGMENTS {COMPACT, EXTEND, FORTIFY, GROW_CD_REDUC, ROTATE_CD_REDUC, EXPLOSION,
	PENTAGRAM, GROWTH_PATTERN, SHIELD, GARBAGE_COLLECTION, WIN}

var augment_resources = {
	AUGMENTS.COMPACT : preload("res://Assets/Resources/Augments/compact.tres"),
	AUGMENTS.EXTEND : preload("res://Assets/Resources/Augments/extend.tres"),
	AUGMENTS.FORTIFY : preload("res://Assets/Resources/Augments/fortify.tres"),
	AUGMENTS.GROW_CD_REDUC : preload("res://Assets/Resources/Augments/grow_cd_reduc.tres"),
	AUGMENTS.ROTATE_CD_REDUC : preload("res://Assets/Resources/Augments/rotate_cd_reduc.tres"),
	AUGMENTS.EXPLOSION : preload("res://Assets/Resources/Augments/explosion.tres"),
	AUGMENTS.PENTAGRAM : preload("res://Assets/Resources/Augments/pentagram.tres"),
	AUGMENTS.GROWTH_PATTERN : preload("res://Assets/Resources/Augments/grow_pattern.tres"),
	AUGMENTS.SHIELD : preload("res://Assets/Resources/Augments/shield.tres"),
	AUGMENTS.GARBAGE_COLLECTION : preload("res://Assets/Resources/Augments/garbage_collection.tres"),
	AUGMENTS.WIN : preload("res://Assets/Resources/Augments/win.tres")
}

func make_pool():
	var pool = []
	for augment in augment_resources.keys():
		if augment == AUGMENTS.WIN:
			continue
		var resource = augment_resources[augment]
		if resource.count == resource.limit:
			continue
		pool.append(augment)
	return pool

func pick_three():
	var pool = make_pool()
	pool.shuffle()
	return pool.slice(0, 3)

func pick_augment(augment):
	var resource = augment_resources[augment]
	resource.count += 1
