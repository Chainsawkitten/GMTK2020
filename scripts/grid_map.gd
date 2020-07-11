extends Node


var grid_height = 16
var grid_width = 30

var grid: Array

var grid_undo_frames: Array
var undo_frame_index: int = -1

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

func _ready():
	call_deferred("save_state")

func outside_grid(var x:int, var y:int):
	return x < 0 || x >= grid_width || y < 0 || y >= grid_height

func add(object, var x:int, var y:int):
	grid[grid_width * y + x].push_back(object)

func get_objects(var x:int, var y:int):
	if outside_grid(x, y):
		return []
	
	return grid[grid_width * y + x]

# type: GameObjectType
func get_objects_by_type(type: int):
	var objects = []
	for cell in grid:
		for object in cell:
			if type == object.game_object_type:
				objects.push_back(object)
	return objects

# text_type: TextType
func get_text_by_type(text_type: int):
	var objects = []
	for cell in grid:
		for object in cell:
			if object is Text && object.text_type == text_type:
				objects.push_back(object)
	return objects

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
	# TODO
	pass


func save_state():
	# var undo_frame = Array()
	# undo_frame.resize(grid.size())
	# for k in range(grid.size())
	# 	undo_frame[k] = grid[k].duplicate()
	var undo_frame = grid.duplicate(true)

	# remove all undo frames after the current
	while undo_frame_index + 1 < grid_undo_frames.size():
		grid_undo_frames.pop_back()
	# append new unto frame
	grid_undo_frames.push_back(undo_frame)
	# update undo frame index
	undo_frame_index = grid_undo_frames.size() - 1;


func undo():
	if undo_frame_index <= 0:
		# At oldest state, cannot undo more
		return false
	# Go back to previous state and restore
	undo_frame_index = undo_frame_index - 1
	restore_state()
	return true

func redo():
	var last_frame_index = grid_undo_frames.size() - 1
	if undo_frame_index >= last_frame_index:
		# At newest state, cannot redo more
		return false
	# Go to next frame and restore
	undo_frame_index = undo_frame_index + 1
	restore_state()
	return true

func restore_state():
	# TODO restore state
	# TODO diff grid against current undo frame
	# Find what objects are moved, added, and removed
	# grid = grid_undo_frames[undo_frame_index].duplicate(true)
	# notify all moved, added, and removed objects about their new status
	pass

