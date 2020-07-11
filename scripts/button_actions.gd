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
	MOVE_UP,
	MOVE_LEFT,
	MOVE_RIGHT,
	MOVE_DOWN,
	DIE,
	WIN,
	SIZE
}

# Actions associated with a button.
var actions = []

# Called when the node enters the scene tree for the first time.
func _ready():
	clear_actions()

# Clear all actions associated with buttons.
func clear_actions():
	actions.clear()
	for _i in range(Button.SIZE):
		actions.push_back(Array())

# Add an action to a button.
func add_action(var button : int, var action : int):
	# Don't add the action if it already exists.
	for a in actions[button]:
		if a == action:
			return
	
	actions[button].push_back(action)

# Get all actions associated with a button.
func get_actions(var button : int):
	return actions[button]

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
	
	return Action.SIZE

# Press a button and see what happens.
func press_button(var button : int):
	# Perform actions in the order of the enum.
	for i in range(Action.SIZE):
		var found = false
		for action in get_actions(button):
			if i == action:
				found = true
		
		if found:
			match i:
				Action.MOVE_UP:
					move(0, -1)
				Action.MOVE_LEFT:
					move(-1, 0)
				Action.MOVE_RIGHT:
					move(1, 0)
				Action.MOVE_DOWN:
					move(0, 1)
				Action.DIE:
					die()
				Action.WIN:
					win()

# Move
func move(var x : int, var y : int):
	for player in GlobalGridMap.get_objects_by_type(Global.GameObjectType.PLAYER):
		# TODO Change directions (player sprite).
		
		if GlobalGridMap.can_move_into(player.grid_x + x, player.grid_y + y, x, y):
			GlobalGridMap.move_object(player.grid_x, player.grid_y, player.grid_x + x, player.grid_y + y, player)

# Die
func die():
	# TODO
	print("die")

# Win
func win():
	LevelHandler.win()
