extends Node2D

const BLOCK_SIZE = 16
const CENTER = Vector2.ZERO
var grid_size = Vector2(11,11)
var separation = 5 # in pixels, between blocks
var cell_size = 16
var _grid : Grid
#---------------------------------------------
var grid_to_block = {}

func _ready():
	SignalBus.grow.connect(grow)
	_grid = Grid.new(grid_size, Vector2(21,21))

func turn_clockwise():
	pass
	
func turn_counterclockwise():
	pass
	
func grow(grid_p):
	var positions = [grid_p]
	for dir in Constants.DIRECTIONS:
		positions.append(grid_p + dir)
		
	
