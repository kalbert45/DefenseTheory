extends Node

const DIRECTIONS = {LEFT = Vector2(-1,0), RIGHT = Vector2(1,0), UP = Vector2(0,-1), DOWN = Vector2(0,1)}
enum ENEMY_TYPES {DEFAULT, QUICK, VQUICK, SLOW, VSLOW}
enum ANGLES {C, CC, HALF}

const BLOCK_TEX = preload("res://Assets/Sprites/block.png")
const BLOCK_LAYER2_TEX = preload("res://Assets/Sprites/block_layer2.png")
const BLOCK_LAYER3_TEX = preload("res://Assets/Sprites/block_layer3.png")
const BLOCK_V2_TEX = preload("res://Assets/Sprites/block_v2.png")
const BLOCK_LAYER2_V2_TEX = preload("res://Assets/Sprites/block_layer2_v2.png")
const BLOCK_LAYER3_V2_TEX = preload("res://Assets/Sprites/block_layer3_v2.png")
