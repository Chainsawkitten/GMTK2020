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
