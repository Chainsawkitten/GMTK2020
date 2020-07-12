extends Node

# The types of game objects there are.
enum GameObjectType {
	TEXT,
	WALL,
	PLAYER,
	CAT,
	LEVEL_SELECT,
	CONVEYOR,
	DOOR
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
	TURN
}

const cell_size : int = 32
