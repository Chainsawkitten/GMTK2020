extends Node2D
class_name GameObject

# Global.GameObjectType
export var game_object_type : int = 0

export var is_pushable: bool = true
export var is_barrier: bool = true

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
