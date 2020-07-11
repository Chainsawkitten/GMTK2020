extends Node2D
class_name GameObject

# Global.GameObjectType
export var game_object_type : int = 0

export var is_pushable: bool = true
export var is_barrier: bool = true

var grid_x : int
var grid_y : int

func _ready():
	grid_x = int(global_position.x) / 32
	grid_y = int(global_position.y) / 32
	
	GlobalGridMap.add(self, grid_x, grid_y)

#func _ready():
#	pass

#func _process(delta):
#	pass
