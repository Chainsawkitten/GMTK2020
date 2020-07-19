extends Node

# The types of game objects there are.
enum GameObjectType {
	TEXT,
	WALL,
	PLAYER,
	CAT,
	LEVEL_SELECT,
	CONVEYOR,
	DOOR,
	CROCODILE,
	LAVA,
	TRAP,
	DECORATION
}

# The types of text there are.
enum TextType {
	BUTTON_UP,
	BUTTON_LEFT,
	BUTTON_RIGHT,
	BUTTON_DOWN,
	BUTTON_A,
	BUTTON_B,
	BUTTON_X,
	BUTTON_Y,
	IS,
	DIE,
	MOVE_UP,
	MOVE_LEFT,
	MOVE_RIGHT,
	MOVE_DOWN,
	SELECT,
	NOT,
	OPEN,
	SWAP,
	SMASH,
	TURN,
	MENU,
	PARTY
}

const cell_size : int = 32

var last_was_gamepad = false

func _input(event):
	if event is InputEventKey:
		last_was_gamepad = false
	
	if event is InputEventJoypadButton:
		last_was_gamepad = true
