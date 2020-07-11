extends GameObject

# A barrier in the overworld that goes away after beating a certain number
# of levels.

# How many levels need to be beaten before the barrier goes away.
export var levels_to_beat : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	if LevelHandler.total_beaten == levels_to_beat:
		# Create a poof!
		var poof = load("scenes/effects/poof.tscn").instance()
		poof.position = position + Vector2(Global.cell_size / 2, Global.cell_size / 2)
		get_parent().call_deferred("add_child", poof)
		
		kill()
	elif LevelHandler.total_beaten > levels_to_beat:
		kill()

# Kill the barrier.
func kill():
	GlobalGridMap.remove(self)
	queue_free()
