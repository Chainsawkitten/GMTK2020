extends Node

# Everything needed to know about a level.
class LevelDescription:
	# The name of the level, has to be exact to the scene name.
	var name : String
	
	# Whether the level has been beaten.
	var beaten : bool = false
	
	# The level's child levels.
	var children = []
	
	# The level's parent level.
	var parent = null

# The level currently being played.
var current_level : LevelDescription

# The top level.
var top_level : LevelDescription

# The number of total beaten levels.
var total_beaten : int = 0

func _init():
	top_level = create_overworld_levels()
	current_level = top_level.children[0]

# Create all the levels in the overworld.
func create_overworld_levels():
	var overworld = LevelDescription.new()
	overworld.name = "overworld"
	
	create_leaf_level(overworld, "test_level")
	
	return overworld

# Create a leaf-node level.
func create_leaf_level(var parent : LevelDescription, var name : String):
	var level = LevelDescription.new()
	level.name = name
	level.parent = parent
	
	parent.children.push_back(level)

# Select a level to play.
func select(var level_index : int):
	if level_index < current_level.children.size():
		play_level(current_level.children[level_index])

# Win the current level.
func win():
	# Mark the level as beaten.
	if !current_level.beaten:
		current_level.beaten = true
		total_beaten += 1
	
	# TODO Handle beating the top level.
	if current_level.parent == null:
		return
	
	return_to_parent()

# Return to the parent level.
func return_to_parent():
	if current_level.parent != null:
		play_level(current_level.parent)

# Play a level.
func play_level(var level : LevelDescription):
	# Clear current level.
	get_node("/Level").queue_free()
	
	current_level = level
	
	# TODO Load level.
	