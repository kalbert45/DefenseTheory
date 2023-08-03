# Represents a grid. Includes helper functions for navigating the grid
# point (0,0) is the center of the grid. always odd number grid size
class_name Grid
extends Resource


# grid's size
@export var size = Vector2(7,7)
# size of a cell in pixels
@export var cell_size = Vector2(40,40)

# half of cell size
# used to calculate center of cell
var _half_cell_size = cell_size / 2

func _init(grid_size, _cell_size = Vector2(40,40)):
	size = grid_size
	cell_size = _cell_size

# Returns the position of a cell's center in pixels.
# We'll place units and have them move through cells using this function.
func calculate_map_position(grid_position: Vector2) -> Vector2:
	return grid_position * cell_size #+ _half_cell_size


# Returns the coordinates of the cell on the grid given a position on the map.
# This is the complementary of `calculate_map_position()` above.
# When designing a level, you'll place units visually in the editor. We'll use this function to find
# the grid coordinates they're placed on, and call `calculate_map_position()` to snap them to the
# cell's center.
func calculate_grid_coordinates(map_position: Vector2) -> Vector2:
	return (map_position / cell_size).floor()


# Returns true if the `cell_coordinates` are within the grid.
# This method and the following one allow us to ensure the cursor or units can never go past the
# map's limit.
func is_within_bounds(cell_coordinates: Vector2) -> bool:
	var half_size = (size.x - 1)/2
	var out = cell_coordinates.x >= -half_size and cell_coordinates.x <= half_size
	return out and cell_coordinates.y >= -half_size and cell_coordinates.y <= half_size


# Makes the `grid_position` fit within the grid's bounds.
# This is a clamp function designed specifically for our grid coordinates.
# The Vector2 class comes with its `Vector2.clamp()` method, but it doesn't work the same way: it
# limits the vector's length instead of clamping each of the vector's components individually.
# That's why we need to code a new method.
func clamp(grid_position: Vector2) -> Vector2:
	var out := grid_position
	out.x = clamp(out.x, -((size.x-1)/2), ((size.x-1)/2))
	out.y = clamp(out.y, -((size.y-1)/2), ((size.y-1)/2))
	return out


# Given Vector2 coordinates, calculates and returns the corresponding integer index. You can use
# this function to convert 2D coordinates to a 1D array's indices.
#
# There are two cases where you need to convert coordinates like so:
# 1. We'll need it for the AStar algorithm, which requires a unique index for each point on the
# graph it uses to find a path.
# 2. You can use it for performance. More on that below.
#func as_index(cell: Vector2) -> int:
#	return int(cell.x + size.x * cell.y)
	
# Return random point on grid. Used for various generation algorithms
#func random_point() -> Vector2:
#	return Vector2(randi_range(0, size.x-1), randi_range(0, size.y-1))
