extends Node


var grid_height = 16;
var grid_width = 30;

var grid: Array

enum Direction {
	UP, LEFT, DOWN, RIGHT
}


# Called when the node enters the scene tree for the first time.
func _ready():
	grid.resize(grid_height*grid_width)
	for k in range(grid.size()):
		grid[k] = Array()


# When can we detect objects and add them to the grid?

func outside_grid(var x:int, var y:int):
	return x < 0 || x > grid_width || y < 0 || y > grid_height

func get_objects(var x:int, var y:int):
	return grid[grid_width*y+x]


func move_object(var from_x:int, var from_y:int, var to_x:int, var to_y:int, var object):
	grid[grid_width*from_y+from_x].erase(object)
	grid[grid_width*to_y+to_x].push_back(object)

func can_move_into(var to_x:int, var to_y:int, var direction:int):
	if outside_grid(to_x, to_y):
		return false
	if get_objects(to_x, to_y).empty():
		return true
	if can_push(to_x, to_y, direction):
		return true
	return true

func can_push(var from_x:int, var from_y:int, var direction:int):
	if outside_grid(from_x, from_y):
		return false
	var cell = get_objects(from_x, from_y);
	if cell.empty():
		return true
	for object in cell:
		pass # FIXME Check that each object is pushable
	# FIXME check that the objects can move to the next cell in direction 
	# to_x = from_x apply direction
	# to_y = from_y apply direction
	# Mutual recursion!! =D
	# can_move_into(to_x, to_y, direction)

	return true

func push(var from_x:int, var from_y:int, var direction:int):
	pass

