extends Node

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
	for i in range(Button.LENGTH):
		actions[i] = []

# Add an action to a button.
func add_action(var button : int, var action : int):
	actions[button].push_back(action)

# Get all actions associated with a button.
func get_actions(var button : int):
	return actions[button]
