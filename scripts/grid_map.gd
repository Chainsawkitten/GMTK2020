extends Node


var grid_height = 16
var grid_width = 30

# An object in the grid. Contains the object's state.
class CellObject:
	var object : GameObject
	var direction_x : int
	var direction_y : int

var grid: Array

# Undo / redo functionality.
var grid_undo_frames: Array
var undo_frame_index: int = -1

# Called when the node is created
func _init():
	grid.resize(grid_height * grid_width)
	clear_grid()

func _ready():
	call_deferred("save_state")

# Get whether the given position is outside the grid.
func outside_grid(var x:int, var y:int):
	return x < 0 || x >= grid_width || y < 0 || y >= grid_height

# Add an object to the grid.
func add(object, var x:int, var y:int):
	var cell = CellObject.new()
	cell.object = object
	cell.direction_x = object.direction_x
	cell.direction_y = object.direction_y
	grid[grid_width * y + x].push_back(cell)

# Remove an object from the grid.
func remove(object):
	var cell_objects = grid[grid_width * object.grid_y + object.grid_x]
	var index = -1
	for i in range(cell_objects.size()):
		if cell_objects[i].object == object:
			index = i
	
	if index != -1:
		cell_objects[index] = cell_objects[cell_objects.size() - 1]
		cell_objects.resize(cell_objects.size() - 1)

# Clear the grid.
func clear_grid():
	for k in range(grid.size()):
		grid[k] = Array()
	grid_undo_frames.clear()
	undo_frame_index = -1
	call_deferred("save_state")

# Get all objects at a given position.
func get_objects(var x:int, var y:int):
	if outside_grid(x, y):
		return []
	
	var objects = []
	
	for cell_object in grid[grid_width * y + x]:
		objects.push_back(cell_object.object)
	
	return objects

# Get all objects of a certain type.
# type: GameObjectType
func get_objects_by_type(type: int):
	var objects = []
	for cell in grid:
		for cell_object in cell:
			if type == cell_object.object.game_object_type:
				objects.push_back(cell_object.object)
	return objects

# Get all text objects of a certain type.
# text_type: TextType
func get_text_by_type(text_type: int):
	var objects = []
	for cell in grid:
		for cell_object in cell:
			if cell_object.object is Text && cell_object.object.text_type == text_type:
				objects.push_back(cell_object.object)
	return objects

# Move an object in the grid.
func move_object(var from_x:int, var from_y:int, var to_x:int, var to_y:int, var object):
	remove(object)
	add(object, to_x, to_y)
	object.move(to_x, to_y)

# Get whether a position can be moved into.
func can_move_into(var to_x:int, var to_y:int, var direction_x:int, var direction_y:int):
	if outside_grid(to_x, to_y):
		return false
	var cell = grid[grid_width * to_y + to_x]
	if cell.empty():
		return true
	var must_push = false
	for cell_object in cell:
		if cell_object.object.is_barrier:
			if cell_object.object.is_pushable:
				must_push = true
			else:
				return false
	if must_push:
		return can_push(to_x, to_y, direction_x, direction_y)
	return true

# Get whether a position can be pushed from a given direction.
func can_push(var from_x:int, var from_y:int, var direction_x:int, var direction_y:int):
	if outside_grid(from_x, from_y):
		return false
	var cell = grid[grid_width * from_y + from_x]
	if cell.empty():
		return true
	var must_push = false
	for cell_object in cell:
		if cell_object.object.is_barrier:
			if cell_object.object.is_pushable:
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
	var cell = grid[grid_width * from_y + from_x]
	if cell.empty():
		return

	var any_pushable = false
	for cell_object in cell:
		# Implicit from precondition can_push
		assert(not cell_object.object.is_barrier || cell_object.object.is_pushable)
		# Assumption
		assert(!(not cell_object.object.is_barrier && cell_object.object.is_pushable))
		if cell_object.object.is_pushable:
			any_pushable = true
			break

	if any_pushable:
		var to_x = from_x + direction_x
		var to_y = from_y + direction_y
		push(to_x, to_y, direction_x, direction_y)
		for cell_object in cell:
			if cell_object.object.is_pushable:
				move_object(from_x, from_y, to_x, to_y, cell_object.object)




# Save the current state of the grid.
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

func reset_action():
	if undo_frame_index <= 0:
		# At oldest state, cannot undo more
		return false
	# Go back to previous state and restore
	undo_frame_index = 0
	restore_state()
	return true

# Undo the last turn.
func undo():
	if undo_frame_index <= 0:
		# At oldest state, cannot undo more
		return false
	# Go back to previous state and restore
	undo_frame_index = undo_frame_index - 1
	restore_state()
	return true

# Redo an undid turn.
func redo():
	var last_frame_index = grid_undo_frames.size() - 1
	if undo_frame_index >= last_frame_index:
		# At newest state, cannot redo more
		return false
	# Go to next frame and restore
	undo_frame_index = undo_frame_index + 1
	restore_state()
	return true

# Restore the state.
func restore_state():
	# TODO Fix this
	# Get undo frame to restore
	var undo_frame = grid_undo_frames[undo_frame_index]
	
	# Set (non-position) state of all objects. eg. direction
	for k in range(undo_frame.size()):
		for cell_object in undo_frame[k]:
			cell_object.object.direction_x = cell_object.direction_x
			cell_object.object.direction_y = cell_object.direction_y
	
	# diff undo frame against grid
	var diff_add = []
	var diff_remove = []
	for k in range(grid.size()):
		for cell_object in grid[k]:
			# Check if undo frame has the object in the same position.
			var found : bool = false
			for undo_object in undo_frame[k]:
				if undo_object.object == cell_object.object:
					found = true
			if !found:
				diff_remove.push_back(cell_object.object)
		for cell_object in undo_frame[k]:
			# Check if the grid has the object in the same position.
			var found : bool = false
			for grid_object in grid[k]:
				if grid_object.object == cell_object.object:
					found = true
			if !found:
				diff_add.push_back(cell_object.object)

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
	grid =  undo_frame.duplicate(true)

	# notify all moved, added, and removed objects about their new status
	for object in added:
		object.appear()
	
	for object in removed:
		object.disappear()
	
	for k in range(grid.size()):
		# k = grid_width * y + x
		var x = k % grid_width
		var y = k / grid_width

		for cell_object in grid[k]:
			cell_object.object.move(x, y)
