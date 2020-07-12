extends Node2D

# Displays win animation.

var wait : float = 0.0
const duration : float = 3.0

var win_stage : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	wait += delta
	
	if win_stage == 1 and wait > duration * 0.2:
		visible = true
		win_stage = 2
	
	if win_stage == 2 and wait > duration * 0.5:
		LevelHandler.win()
		win_stage = 3
	
	if win_stage == 3 and wait > duration:
		TurnHandler.set_pause(false)
		visible = false
		win_stage = 0

# Win the level.
func win(var cat_version : int):
	if win_stage == 0:
		TurnHandler.set_pause(true)
		get_node("Cat").frame = cat_version
		win_stage = 1
		wait = 0.0
