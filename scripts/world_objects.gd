extends Node

# Handle all interactible objects in the world.

# Update all objects in the world.
func update_world_objects():
	# Note: Order is important.
	for crocodile in GlobalGridMap.get_objects_by_type(Global.GameObjectType.CROCODILE):
		update_crocodile(crocodile)
	
	for lava in GlobalGridMap.get_objects_by_type(Global.GameObjectType.LAVA):
		update_lava(lava)
	
	for trap in GlobalGridMap.get_objects_by_type(Global.GameObjectType.TRAP):
		update_trap(trap)
	
	for cat in GlobalGridMap.get_objects_by_type(Global.GameObjectType.CAT):
		update_cat(cat)

# Update the cat.
func update_cat(var cat : GameObject):
	# Check if the player is in the same position.
	for object in GlobalGridMap.get_objects(cat.grid_x, cat.grid_y):
		if object.game_object_type == Global.GameObjectType.PLAYER:
			get_node("/root/Game/Win").win(cat.get_node("AnimatedSprite").frame)
			return

# Update the crocodile.
func update_crocodile(var crocodile : GameObject):
	# Move.
	if GlobalGridMap.can_move_into(crocodile.grid_x + crocodile.direction_x, crocodile.grid_y + crocodile.direction_y, crocodile.direction_x, crocodile.direction_y):
		GlobalGridMap.push(crocodile.grid_x + crocodile.direction_x, crocodile.grid_y + crocodile.direction_y, crocodile.direction_x, crocodile.direction_y)
		GlobalGridMap.move_object(crocodile.grid_x, crocodile.grid_y, crocodile.grid_x + crocodile.direction_x, crocodile.grid_y + crocodile.direction_y, crocodile)
	else:
		crocodile.direction_x = -crocodile.direction_x
		crocodile.direction_y = -crocodile.direction_y
		
		if GlobalGridMap.can_move_into(crocodile.grid_x + crocodile.direction_x, crocodile.grid_y + crocodile.direction_y, crocodile.direction_x, crocodile.direction_y):
			GlobalGridMap.push(crocodile.grid_x + crocodile.direction_x, crocodile.grid_y + crocodile.direction_y, crocodile.direction_x, crocodile.direction_y)
			GlobalGridMap.move_object(crocodile.grid_x, crocodile.grid_y, crocodile.grid_x + crocodile.direction_x, crocodile.grid_y + crocodile.direction_y, crocodile)
	
	# Munch.
	for object in GlobalGridMap.get_objects(crocodile.grid_x, crocodile.grid_y):
		if object.game_object_type == Global.GameObjectType.PLAYER or object.game_object_type == Global.GameObjectType.CAT:
			object.kill()

# Update the lava.
func update_lava(var lava : GameObject):
	for object in GlobalGridMap.get_objects(lava.grid_x, lava.grid_y):
		if object.game_object_type != Global.GameObjectType.LAVA:
			object.kill()

# Update the trap.
func update_trap(var trap : GameObject):
	var caught_something = false
	for object in GlobalGridMap.get_objects(trap.grid_x, trap.grid_y):
		if object.game_object_type == Global.GameObjectType.PLAYER or object.game_object_type == Global.GameObjectType.CAT or object.game_object_type == Global.GameObjectType.CROCODILE:
			object.kill()
			caught_something = true
	
	if caught_something:
		trap.kill()
