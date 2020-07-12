extends Node

# This class handles associating buttons with actions.
# Actions can be added to a button and a button can be queried for all
# associated actions.

# The different buttons that can be bound to actions.
enum Button {
	UP,
	LEFT,
	RIGHT,
	DOWN,
	A,
	B,
	X,
	Y,
	SIZE
}

# Actions that can be performed by pressing a button.
enum Action {
	DIE,
	MOVE_UP,
	MOVE_LEFT,
	MOVE_RIGHT,
	MOVE_DOWN,
	WIN, # First non-special order action.
	TURN,
	SELECT,
	OPEN,
	SMASH,
	SWAP,
	SIZE
}

# Actions associated with a button.
var actions = []

# Not actions prevent a button from doing an action.
var not_actions = []

# Called when the node enters the scene tree for the first time.
func _ready():
	clear_actions()

# Clear all actions associated with buttons.
func clear_actions():
	actions.clear()
	not_actions.clear()
	for _i in range(Button.SIZE):
		actions.push_back(Array())
		not_actions.push_back(Array())

# Add an action to a button.
func add_action(var button : int, var action : int):
	# Don't add the action if it already exists.
	for a in actions[button]:
		if a == action:
			return
	
	actions[button].push_back(action)

# Add an override, making a button never do a certain action.
func add_not_action(var button : int, var not_action : int):
	not_actions[button].push_back(not_action)

# Get all actions associated with a button.
func get_actions(var button : int):
	var values = []
	
	# Exclude not:ed actions.
	for action in actions[button]:
		if !not_actions[button].has(action):
			values.push_back(action)
	
	return values

# Get button from text type.
func text_type_to_button(var text_type : int) -> int:
	match text_type:
		Global.TextType.BUTTON_UP:
			return Button.UP
		Global.TextType.BUTTON_LEFT:
			return Button.LEFT
		Global.TextType.BUTTON_RIGHT:
			return Button.RIGHT
		Global.TextType.BUTTON_DOWN:
			return Button.DOWN
		Global.TextType.BUTTON_A:
			return Button.A
		Global.TextType.BUTTON_B:
			return Button.B
		Global.TextType.BUTTON_X:
			return Button.X
		Global.TextType.BUTTON_Y:
			return Button.Y
	
	return Button.SIZE

# Get action from text type.
func text_type_to_action(var text_type : int) -> int:
	match text_type:
		Global.TextType.DIE:
			return Action.DIE
		Global.TextType.MOVE_UP:
			return Action.MOVE_UP
		Global.TextType.MOVE_LEFT:
			return Action.MOVE_LEFT
		Global.TextType.MOVE_RIGHT:
			return Action.MOVE_RIGHT
		Global.TextType.MOVE_DOWN:
			return Action.MOVE_DOWN
		Global.TextType.TURN:
			return Action.TURN
		Global.TextType.SELECT:
			return Action.SELECT
		Global.TextType.OPEN:
			return Action.OPEN
		Global.TextType.SWAP:
			return Action.SWAP
		Global.TextType.SMASH:
			return Action.SMASH
	
	return Action.SIZE

# Press a button and see what happens.
func press_button(var button : int):
	# Always check die first.
	for action in get_actions(button):
		if action == Action.DIE:
			die()
	
	# Then move.
	var direction_x = 0
	var direction_y = 0
	for action in get_actions(button):
		match action:
			Action.MOVE_UP:
				direction_y -= 1
			Action.MOVE_LEFT:
				direction_x -= 1
			Action.MOVE_RIGHT:
				direction_x += 1
			Action.MOVE_DOWN:
				direction_y += 1
	
	if direction_x != 0 or direction_y != 0:
		move(direction_x, direction_y)
	
	# Then other actions, in order of the enum.
	for i in range(Action.WIN, Action.SIZE):
		var found = false
		for action in get_actions(button):
			if i == action:
				found = true
		
		if found:
			match i:
				Action.WIN:
					win()
				Action.TURN:
					turn()
				Action.SELECT:
					select()
				Action.OPEN:
					open()
				Action.SWAP:
					swap()
				Action.SMASH:
					smash()
	

# Move
func move(var x : int, var y : int):
	for player in GlobalGridMap.get_objects_by_type(Global.GameObjectType.PLAYER):
		player.direction_x = x
		player.direction_y = y
		
		if GlobalGridMap.can_move_into(player.grid_x + x, player.grid_y + y, x, y):
			GlobalGridMap.push(player.grid_x + x, player.grid_y + y, x, y)
			GlobalGridMap.move_object(player.grid_x, player.grid_y, player.grid_x + x, player.grid_y + y, player)

# Die
func die():
	for player in GlobalGridMap.get_objects_by_type(Global.GameObjectType.PLAYER):
		player.kill()

# Win
func win():
	get_node("/root/Game/Win").win(0)

# Select
func select():
	for player in GlobalGridMap.get_objects_by_type(Global.GameObjectType.PLAYER):
		for object in GlobalGridMap.get_objects(player.grid_x, player.grid_y):
			if object.game_object_type == Global.GameObjectType.LEVEL_SELECT:
				LevelHandler.select(object.level)
				return

# Turn
func turn():
	for player in GlobalGridMap.get_objects_by_type(Global.GameObjectType.PLAYER):
		if player.direction_x == -1 and player.direction_y == 0:
			player.direction_x = 0
			player.direction_y = -1
		elif player.direction_x == 1 and player.direction_y == 0:
			player.direction_x = 0
			player.direction_y = 1
		elif player.direction_x == 0 and player.direction_y == -1:
			player.direction_x = 1
			player.direction_y = 0
		elif player.direction_x == 0 and player.direction_y == 1:
			player.direction_x = -1
			player.direction_y = 0
		elif player.direction_x == -1 and player.direction_y == -1:
			player.direction_x = 1
			player.direction_y = -1
		elif player.direction_x == 1 and player.direction_y == -1:
			player.direction_x = 1
			player.direction_y = 1
		elif player.direction_x == -1 and player.direction_y == 1:
			player.direction_x = -1
			player.direction_y = -1
		elif player.direction_x == 1 and player.direction_y == 1:
			player.direction_x = -1
			player.direction_y = 1

# Open
func open():
	for player in GlobalGridMap.get_objects_by_type(Global.GameObjectType.PLAYER):
		var pos_x = player.grid_x + player.direction_x
		var pos_y = player.grid_y + player.direction_y
		for object in GlobalGridMap.get_objects(pos_x, pos_y):
			if object.game_object_type == Global.GameObjectType.DOOR:
				object.kill()

# Swap
func swap():
	for player in GlobalGridMap.get_objects_by_type(Global.GameObjectType.PLAYER):
		var pos_x = player.grid_x + player.direction_x
		var pos_y = player.grid_y + player.direction_y
		
		var any_object : bool = false
		for object in GlobalGridMap.get_objects(pos_x, pos_y):
			if object.swappable:
				any_object = true
				GlobalGridMap.move_object(pos_x, pos_y, player.grid_x, player.grid_y, object)
		
		if any_object:
			GlobalGridMap.move_object(player.grid_x, player.grid_y, pos_x, pos_y, player)

# Smash
func smash():
	for player in GlobalGridMap.get_objects_by_type(Global.GameObjectType.PLAYER):
		var pos_x = player.grid_x + player.direction_x
		var pos_y = player.grid_y + player.direction_y
		for object in GlobalGridMap.get_objects(pos_x, pos_y):
			if object.smashable:
				object.kill()
