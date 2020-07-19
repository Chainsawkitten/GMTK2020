extends Node

# Everything needed to know about a level.
class LevelDescription:
	# The name of the level, has to be exact to the scene name.
	var name : String
	
	# Whether the level has been beaten.
	var beaten : bool = false
	
	# Whether the level has been reached (attempted).
	var reached : bool = false
	
	# The level's child levels.
	var children = []
	
	# The level's parent level.
	var parent = null

# The level currently being played.
var current_level : LevelDescription

# The top level.
var top_level : LevelDescription

# Save file version number. Increasing this will make previous save files
# incompatible.
const save_file_version : int = 1

# Path to the save file.
const save_file_path : String = "user://save"

func _init():
	top_level = LevelDescription.new()
	top_level.name = "over_overworld"
	
	create_overworld_levels(top_level)
	create_test_levels(top_level)
	create_world2_levels(top_level)
	
	current_level = top_level.children[0].children[0]
	
	call_deferred("load")

# Create all the levels in the overworld.
func create_overworld_levels(var parent : LevelDescription):
	var overworld = LevelDescription.new()
	overworld.name = "overworld"
	overworld.parent = parent
	
	create_leaf_level(overworld, "level0")
	create_leaf_level(overworld, "level1")
	create_leaf_level(overworld, "level_die")
	create_leaf_level(overworld, "croco_dash")
	create_leaf_level(overworld, "directional_movement")
	create_leaf_level(overworld, "lava_level")
	create_leaf_level(overworld, "level_not_die")
	create_leaf_level(overworld, "save_the_cat")
	
	parent.children.push_back(overworld)

func create_world2_levels(var parent : LevelDescription):
	var world2 = LevelDescription.new()
	world2.name = "world2"
	world2.parent = parent
	
	create_leaf_level(world2, "swap_rocks")
	create_leaf_level(world2, "door_swap")
	
	parent.children.push_back(world2)

# Create the levels meant for testing things.
func create_test_levels(var parent : LevelDescription):
	var test_levels = LevelDescription.new()
	test_levels.name = "test_levels"
	test_levels.parent = parent
	
	create_leaf_level(test_levels, "test_direction_level")
	create_leaf_level(test_levels, "test_not_level")
	create_leaf_level(test_levels, "test_conveyor")
	create_leaf_level(test_levels, "test_door_level")
	create_leaf_level(test_levels, "test_swap_level")
	create_leaf_level(test_levels, "test_smash_level")
	
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
		call_deferred("play_level", current_level.children[level_index])

# Win the current level.
func win():
	# Mark the level as beaten.
	if !current_level.beaten:
		current_level.beaten = true
	
	# Beating the top level.
	if current_level.parent == null:
		var credits = LevelDescription.new()
		credits.name = "credits"
		
		play_level(credits)
		return
	
	return_to_parent()

# Check whether the player can return to the parent through the menu.
func parent_is_reached():
	return current_level.parent != null and current_level.parent.reached

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
	level.reached = true
	
	save()
	
	# Load new level.
	var new_level = load("scenes/levels/" + level.name + ".tscn").instance()
	game_node.add_child(new_level)
	
	TurnHandler.reread_button_actions()

# Get beaten levels in the current world.
func get_beaten_levels() -> int:
	var beaten = 0
	for child in current_level.children:
		if child.beaten:
			beaten += 1
	return beaten

# Save the game.
func save():
	var file : File = File.new()
	file.open(save_file_path, File.WRITE)
	
	# Version number.
	file.store_8(save_file_version)
	
	# Level information.
	save_level(file, top_level)
	
	file.close()

# Load saved game.
func load():
	var file : File = File.new()
	if !file.file_exists(save_file_path):
		return
	
	file.open(save_file_path, File.READ)
	
	# Version number check.
	var version_number = file.get_8()
	if version_number != save_file_version:
		return
	
	# Level information.
	load_level(file, top_level)
	
	# Start from the overworld.
	return_to_parent()
	
	file.close()

# Save the state of a level to file.
func save_level(var file : File, var level : LevelDescription):
	# Save level.
	file.store_8(level.beaten)
	file.store_8(level.reached)
	
	# Save children.
	for child in level.children:
		save_level(file, child)

# Load the state of a level from file.
func load_level(var file : File, var level : LevelDescription):
	# Load level.
	level.beaten = file.get_8()
	level.reached = file.get_8()
	
	# Load children.
	for child in level.children:
		load_level(file, child)
