extends GameObject

# A barrier in the overworld that goes away after beating a certain number
# of levels.

# How many levels need to be beaten before the barrier goes away.
export var levels_to_beat : int = 0

var killed : bool = false

# Called when the node enters the scene tree for the first time.
func _process(_delta):
	if killed:
		GlobalGridMap.remove(self)
		visible = false
	elif !TurnHandler.paused:
		if LevelHandler.get_beaten_levels() == levels_to_beat:
			# Create a poof!
			var poof = load("scenes/effects/poof.tscn").instance()
			poof.position = position + Vector2(Global.cell_size / 2, Global.cell_size / 2)
			get_parent().call_deferred("add_child", poof)
			
			kill()
		elif LevelHandler.get_beaten_levels() > levels_to_beat:
			kill()

# Kill the barrier.
func kill():
	GlobalGridMap.remove(self)
	visible = false
	killed = true
