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
	top_level = LevelDescription.new()
	top_level.name = "over_overworld"
	
	create_overworld_levels(top_level)
	create_test_levels(top_level)
	
	current_level = top_level.children[0].children[0]

# Create all the levels in the overworld.
func create_overworld_levels(var parent : LevelDescription):
	var overworld = LevelDescription.new()
	overworld.name = "overworld"
	overworld.parent = parent
	
	create_leaf_level(overworld, "level0")
	create_leaf_level(overworld, "level1")
	create_leaf_level(overworld, "level_die")
	create_leaf_level(overworld, "level_not_die")
	
	parent.children.push_back(overworld)

# Create the levels meant for testing things.
func create_test_levels(var parent : LevelDescription):
	var test_levels = LevelDescription.new()
	test_levels.name = "test_levels"
	test_levels.parent = parent
	
	create_leaf_level(test_levels, "test_direction_level")
	create_leaf_level(test_levels, "test_not_level")
	create_leaf_level(test_levels, "test_conveyor")
	create_leaf_level(test_levels, "test_door_level")
	
	parent.children.push_back(test_levels)

# Create a leaf-node level.
func create_leaf_level(var parent : LevelDescription, var name : String):
	var level = LevelDescription.new()
	level.name = parent.name + "/" + name
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
	var game_node = get_node("/root/Game/Level")
	game_node.get_child(0).queue_free()
	ButtonActions.clear_actions()
	GlobalGridMap.clear_grid()
	
	current_level = level
	
	# Load new level.
	var new_level = load("scenes/levels/" + level.name + ".tscn").instance()
	game_node.add_child(new_level)
