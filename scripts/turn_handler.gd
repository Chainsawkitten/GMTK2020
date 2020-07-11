extends Node

# Handles taking turns. Each turn has three phases:
# 1. Wait for player input.
# 2. Perform actions based on player input.
# 3. Re-read button texts.

enum Press {
	NONE,
	MENU,
	BUTTON_UP,
	BUTTON_LEFT,
	BUTTON_RIGHT,
	BUTTON_DOWN,
	BUTTON_A,
	BUTTON_B,
	BUTTON_X,
	BUTTON_Y,
	UNDO,
	REDO
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# Check if player has performed (exactly one!) input.
	var input : int = get_player_input()
	
	# If any input was performed, 
	if (input != Press.NONE):
		if (input == Press.MENU):
			# TODO
			pass
		elif (input == Press.UNDO):
			# TODO
			pass
		elif (input == Press.REDO):
			# TODO
			pass
		else:
			# Perform a turn.
			perform_normal_input(input)
			execute_world_objects()
			reread_button_actions()

# Get player input.
func get_player_input() -> int:
	if (Input.is_action_just_pressed("button_start")):
		return Press.MENU
	
	if (Input.is_action_just_pressed("button_undo")):
		return Press.UNDO
		
	if (Input.is_action_just_pressed("button_redo")):
		return Press.REDO
	
	var any_pressed : bool = false
	var input : int = Press.NONE
	var mappings = [ "", "",
					 "button_up", "button_left", "button_right","button_down",
					 "button_a", "button_b", "button_x", "button_y"]
	
	for i in range(Press.BUTTON_UP, Press.UNDO):
		if (Input.is_action_just_pressed(mappings[i])):
			input = i
			if (!any_pressed):
				any_pressed = true
			else:
				return Press.NONE
	
	return input

# Open the menu.
func open_menu():
	# TODO
	pass

# Undo the last action.
func undo():
	# TODO
	pass

# Undo the last undid action...
func redo():
	# TODO
	pass

# Perform normal game input.
func perform_normal_input(var input : int):
	var button : int = 0
	
	match input:
		Press.BUTTON_UP:
			button = ButtonActions.Button.UP
		Press.BUTTON_LEFT:
			button = ButtonActions.Button.LEFT
		Press.BUTTON_RIGHT:
			button = ButtonActions.Button.RIGHT
		Press.BUTTON_DOWN:
			button = ButtonActions.Button.DOWN
		Press.BUTTON_A:
			button = ButtonActions.Button.A
		Press.BUTTON_B:
			button = ButtonActions.Button.B
		Press.BUTTON_X:
			button = ButtonActions.Button.X
		Press.BUTTON_Y:
			button = ButtonActions.Button.Y
	
	# TODO Actually perform the actions associated with that button.

# Execute world elements that do something every turn.
func execute_world_objects():
	# TODO
	pass

# Reread all button actions based on text in the world.
func reread_button_actions():
	ButtonActions.clear_actions()
	
	# TODO Loop through all text and get actions.
