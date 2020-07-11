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

func get_objects(var x:int, var y:int):
	return grid[grid_width*y+x]


func move_object(var from_x:int, var from_y:int, var to_x:int, var to_y:int, var object):
	pass

func can_move_into(var to_x:int, var to_y:int):
	return false;

func can_push(var from_x:int, var from_y:int, var direction:int):
	return false;

func push(var from_x:int, var from_y:int, var direction:int):
	pass

