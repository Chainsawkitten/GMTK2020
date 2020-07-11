extends Node


var grid_height = 16
var grid_width = 30

var grid: Array

enum Direction {
	UP, LEFT, DOWN, RIGHT
	UP_LEFT, DOWN_LEFT, DOWN_RIGHT, UP_RIGHT
}

const dir_offsets = [
	[0, -1], [-1, 0], [0, 1], [1, 0], 
	[-1, -1], [-1, 1], [1, 1], [1, -1], 
]


# Called when the node is created
func _init():
	grid.resize(grid_height * grid_width)
	for k in range(grid.size()):
		grid[k] = Array()


func outside_grid(var x:int, var y:int):
	return x < 0 || x > grid_width || y < 0 || y > grid_height

func add(object, var x:int, var y:int):
	grid[grid_width * y + x].push_back(object)

func get_objects(var x:int, var y:int):
	return grid[grid_width * y + x]

func move_object(var from_x:int, var from_y:int, var to_x:int, var to_y:int, var object):
	grid[grid_width * from_y + from_x].erase(object)
	grid[grid_width * to_y + to_x].push_back(object)

func can_move_into(var to_x:int, var to_y:int, var direction:int):
	if outside_grid(to_x, to_y):
		return false
	var cell = get_objects(to_x, to_y)
	if cell.empty():
		return true
	var must_push = false
	for object in cell:
		if object is GameObject:
			if object.is_barrier:
				if object.is_pushable:
					must_push = true
				else:
					return false
	if must_push:
		return can_push(to_x, to_y, direction)
	return true

func can_push(var from_x:int, var from_y:int, var direction:int):
	if outside_grid(from_x, from_y):
		return false
	var cell = get_objects(from_x, from_y)
	if cell.empty():
		return true
	var must_push = false
	for object in cell:
		if object is GameObject:
			if object.is_barrier:
				if object.is_pushable:
					must_push = true
				else:
					return false
	if must_push:
		# check that the objects can move to the next cell in direction 
		var to_x = from_x + dir_offsets[direction][0]
		var to_y = from_y + dir_offsets[direction][1]
		# Mutual recursion!! =D
		return can_move_into(to_x, to_y, direction)
	return true

func push(var _from_x:int, var _from_y:int, var _direction:int):
	pass

