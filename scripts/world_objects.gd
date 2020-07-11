extends Node

# Handle all interactible objects in the world.

# Update all objects in the world.
func update_world_objects():
	# Note: Order is important.
	for cat in GlobalGridMap.get_objects_by_type(Global.GameObjectType.CAT):
		update_cat(cat)

# Update the cat.
func update_cat(var cat : GameObject):
	# Check if the player is in the same position.
	for object in GlobalGridMap.get_objects(cat.grid_x, cat.grid_y):
		if object.game_object_type == Global.GameObjectType.PLAYER:
			LevelHandler.win()
			return
