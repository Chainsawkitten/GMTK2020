extends Node2D
class_name GameObject

# Global.GameObjectType
export var game_object_type : int = 0

export var is_pushable: bool = true
export var is_barrier: bool = true

export var direction_x : int = 0
export var direction_y : int = 1

export var swappable : bool = true

var grid_x : int
var grid_y : int

var target_position : Vector2
const move_time : float = 0.1

func _ready():
	grid_x = int(global_position.x) / 32
	grid_y = int(global_position.y) / 32
	
	GlobalGridMap.add(self, grid_x, grid_y)
	
	target_position = position

#func _ready():
#	pass

# Called every frame.
func _process(delta):
	var diff = target_position - position
	var max_move_speed = float(Global.cell_size) / move_time * delta
	diff.x = clamp(diff.x, -max_move_speed, max_move_speed)
	diff.y = clamp(diff.y, -max_move_speed, max_move_speed)
	position += diff

# Move linarly to a given position (visual respresentation only).
func move_linear(var target : Vector2):
	target_position = target

# Set grid position, when moved, pushed, or either undo or redo of the same
func move(var x:int, var y:int):
	grid_x = x
	grid_y = y
	move_linear(Vector2(grid_x * Global.cell_size, grid_y * Global.cell_size))

# When the object is created or undo destruction
func appear():
	# TODO Inverse poof?
	visible = true

# When the object is destroyed or undo creation
func disappear():
	# Play poof.
	var poof = load("scenes/effects/poof.tscn").instance()
	poof.position = target_position + Vector2(Global.cell_size / 2, Global.cell_size / 2)
	get_parent().call_deferred("add_child", poof)
	visible = false

# Destroy the object.
func kill():
	GlobalGridMap.remove(self)
	disappear()

