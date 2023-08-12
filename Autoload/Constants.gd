extends Node

# other versions used for growth patterns
const DIRECTIONS = {LEFT = Vector2(-1,0), RIGHT = Vector2(1,0), UP = Vector2(0,-1), DOWN = Vector2(0,1)}
const DIRECTIONS_V2 = {LEFT = Vector2(-1,1), RIGHT = Vector2(1,1), UP = Vector2(-1,-1), DOWN = Vector2(1,-1)}
const DIRECTIONS_V3 = {LEFT = Vector2(-2,0), RIGHT = Vector2(2,0), UP = Vector2(0,-2), DOWN = Vector2(0,2)}
const DIRECTIONS_V5 = {LEFT = Vector2(-2,2), RIGHT = Vector2(2,2), UP = Vector2(-2,-2), DOWN = Vector2(2,-2)}
const DIRECTIONS_V4 = {LEFT = Vector2(-2,1), RIGHT = Vector2(-2,-1), UP = Vector2(2,-1), DOWN = Vector2(2,1),
					A = Vector2(1, 2), B = Vector2(-1, 2), C = Vector2(1, -2), D = Vector2(-1, -2)}

enum ENEMY_TYPES {DEFAULT, QUICK, QUICKER}
enum ANGLES {C, CC, HALF}

const BLOCK_TEX = preload("res://Assets/Sprites/block.png")
const BLOCK_LAYER2_TEX = preload("res://Assets/Sprites/block_layer2.png")
const BLOCK_LAYER3_TEX = preload("res://Assets/Sprites/block_layer3.png")
const BLOCK_V2_TEX = preload("res://Assets/Sprites/block_v2.png")
const BLOCK_LAYER2_V2_TEX = preload("res://Assets/Sprites/block_layer2_v2.png")
const BLOCK_LAYER3_V2_TEX = preload("res://Assets/Sprites/block_layer3_v2.png")
