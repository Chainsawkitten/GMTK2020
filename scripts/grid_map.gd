extends Node


var grid_height = 16
var grid_width = 30

var grid: Array

var grid_undo_frames: Array
var undo_frame_index: int = -1

# Called when the node is created
func _init():
	grid.resize(grid_height * grid_width)
	clear_grid()

func _ready():
	call_deferred("save_state")

func outside_grid(var x:int, var y:int):
	return x < 0 || x >= grid_width || y < 0 || y >= grid_height

func add(object, var x:int, var y:int):
	grid[grid_width * y + x].push_back(object)

func clear_grid():
	for k in range(grid.size()):
		grid[k] = Array()
	grid_undo_frames.clear()
	undo_frame_index = -1

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
	object.move(to_x, to_y)

func can_move_into(var to_x:int, var to_y:int, var direction_x:int, var direction_y:int):
	if outside_grid(to_x, to_y):
		return false
	var cell = get_objects(to_x, to_y)
	if cell.empty():
		return true
	var must_push = false
	for object in cell:
		if object.is_barrier:
			if object.is_pushable:
				must_push = true
			else:
				return false
	if must_push:
		return can_push(to_x, to_y, direction_x, direction_y)
	return true

func can_push(var from_x:int, var from_y:int, var direction_x:int, var direction_y:int):
	if outside_grid(from_x, from_y):
		return false
	var cell = get_objects(from_x, from_y)
	if cell.empty():
		return true
	var must_push = false
	for object in cell:
		if object.is_barrier:
			if object.is_pushable:
				must_push = true
			else:
				return false
	if must_push:
		# check that the objects can move to the next cell in direction 
		var to_x = from_x + direction_x
		var to_y = from_y + direction_y
		# Mutual recursion!! =D
		return can_move_into(to_x, to_y, direction_x, direction_y)
	return true

# Precondition: can_push(from_x, from_y, direction_x, direction_y)
# Assumtion: there are no objects that are not is_barrier but are is_pushable
func push(var from_x:int, var from_y:int, var direction_x:int, var direction_y:int):
	assert(can_push(from_x, from_y, direction_x, direction_y))
	if outside_grid(from_x, from_y):
		return
	var cell = get_objects(from_x, from_y)
	if cell.empty():
		return

	var any_pushable = false
	for object in cell:
		# Implicit from precondition can_push
		assert(not object.is_barrier || object.is_pushable)
		# Assumtion
		assert(!(not object.is_barrier && object.is_pushable))
		if object.is_pushable:
			any_pushable = true
			break

	if any_pushable:
		var to_x = from_x + direction_x
		var to_y = from_y + direction_y
		push(to_x, to_y, direction_x, direction_y)
		for object in cell:
			if object.is_pushable:
				move_object(from_x, from_y, to_x, to_y, object)
				





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
	# Get undo frame to restore
	var undo_frame = grid_undo_frames[undo_frame_index]
	# diff undo frame against grid
	var diff_add = []
	var diff_remove = []
	for k in range(grid.size()):
		for object in grid[k]:
			if not undo_frame[k].has(object):
				diff_remove.push_back(object);
		for object in undo_frame[k]:
			if not grid[k].has(object):
				diff_add.push_back(object);

	# Find what objects are moved, added, and removed
	var moved = []
	var added = []
	for object in diff_add:
		if diff_remove.has(object):
			moved.push_back(object)
		else:
			added.push_back(object)

	var removed = []
	for object in diff_remove:
		if not diff_add.has(object):
			removed.push_back(object)

	# restore grid to old state
	grid = undo_frame.duplicate(true)

	# notify all moved, added, and removed objects about their new status
	for k in range(grid.size()):
		# k = grid_width * y + x
		var x = k % grid_width
		var y = k / grid_width

		for object in grid[k]:
			if moved.has(object):
				object.move(x, y)
			elif added.has(object):
				object.move(x, y)
				object.appear()
			elif removed.has(object):
				object.move(x, y)
				object.disappear()

