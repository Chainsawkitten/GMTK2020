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

# The current turn. Only used to animate stuff.
var turn  = 0

# How long to wait between inputs.
const time_to_wait_for_input = 0.27

# How long we've waited.
var wait_for_input = time_to_wait_for_input

# Whether the game is paused for whatever reason.
var paused : bool = false

var menu : Node2D = null

# Called when the node enters the scene tree for the first time.
func _ready():
	call_deferred("reread_button_actions")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	wait_for_input += delta
	
	# Check if player has performed (exactly one!) input.
	var input : int = get_player_input()
	
	# If any input was performed, 
	if input != Press.NONE:
		wait_for_input = 0.0
		
		if input == Press.MENU:
			if menu == null:
				menu = get_node("/root/Game/PauseMenu")
			if menu != null:
				# check that the game is not paused for some other reason
				# such as the win screen
				if not (paused && not menu.visible):
					if LevelHandler.current_level.name != "credits":
						menu.visible = not paused
						set_pause(not paused)
		else:
			if !paused:
				# Not in the menu, normal gameplay.
				if input == Press.UNDO:
					if GlobalGridMap.undo():
						reread_button_actions()
					else:
						pass # TODO undo returns false when cannot undo more
				elif input == Press.REDO:
					if GlobalGridMap.redo():
						reread_button_actions()
					else:
						pass # TODO redo returns false when cannot redo more
				else:
					# Perform a turn.
					if perform_normal_input(input):
						turn += 1
						WorldObjects.update_world_objects()
						reread_button_actions()
						GlobalGridMap.save_state()
			else:
				# In the menu.
				if input == Press.BUTTON_Y:
					GlobalGridMap.reset_action()
					menu.visible = false
					set_pause(false)
				elif input == Press.BUTTON_X and LevelHandler.parent_is_reached():
					LevelHandler.return_to_parent()
					menu.visible = false
					set_pause(false)


# Get player input.
func get_player_input() -> int:
	if (Input.is_action_just_pressed("button_start")):
		return Press.MENU
	
	if (Input.is_action_just_pressed("button_undo") or (Input.is_action_pressed("button_undo") and wait_for_input > time_to_wait_for_input)):
		return Press.UNDO
		
	if (Input.is_action_just_pressed("button_redo") or (Input.is_action_pressed("button_redo") and wait_for_input > time_to_wait_for_input)):
		return Press.REDO
	
	var any_pressed : bool = false
	var input : int = Press.NONE
	var mappings = [ "", "",
					 "button_up", "button_left", "button_right","button_down",
					 "button_a", "button_b", "button_x", "button_y"]
	
	for i in range(Press.BUTTON_UP, Press.UNDO):
		if (Input.is_action_just_pressed(mappings[i]) or (Input.is_action_pressed(mappings[i]) and wait_for_input > time_to_wait_for_input)):
			input = i
			if (!any_pressed):
				any_pressed = true
			else:
				return Press.NONE
	
	return input

# Perform normal game input.
func perform_normal_input(var input : int) -> bool:
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
	
	return ButtonActions.press_button(button)

# Reread all button actions based on text in the world.
func reread_button_actions():
	ButtonActions.clear_actions()
	
	# Loop through all is text and get actions.
	var is_texts = GlobalGridMap.get_text_by_type(Global.TextType.IS)
	
	for i in is_texts:
		read_text(i, 0, 1)
		read_text(i, 1, 0)

# Read a text in a given direction.
func read_text(var is_text, var x : int, var y : int):
	var buttons = []
	var actions = []
	var not_actions = []
	
	# Get the is' position.
	var is_x : int = is_text.grid_x
	var is_y : int = is_text.grid_y
	
	# Get whether there's a not.
	var there_is_not : bool = false
	var two_before_x : int = is_x - 2 * x
	var two_before_y : int = is_y - 2 * y
	var objects = GlobalGridMap.get_objects(two_before_x, two_before_y)
	for o in objects:
		if o is Text and o.text_type == Global.TextType.NOT:
			there_is_not = true
	
	# Get buttons before the is.
	var before_x : int = is_x - x
	var before_y : int = is_y - y
	objects = GlobalGridMap.get_objects(before_x, before_y)
	for o in objects:
		if o is Text:
			if o.is_button():
				if there_is_not:
					for button in range(ButtonActions.Button.SIZE):
						if button != ButtonActions.text_type_to_button(o.text_type):
							buttons.push_back(button)
				else:
					buttons.push_back(ButtonActions.text_type_to_button(o.text_type))
	
	# Get actions after the is.
	var after_x : int = is_x + x
	var after_y : int = is_y + y
	objects = GlobalGridMap.get_objects(after_x, after_y)
	for o in objects:
		if o is Text:
			if o.is_action():
				actions.push_back(ButtonActions.text_type_to_action(o.text_type))
			elif o.text_type == Global.TextType.NOT:
				# Get actions after not.
				var after_not_x : int = after_x + x
				var after_not_y : int = after_y + y
				var not_objects = GlobalGridMap.get_objects(after_not_x, after_not_y)
				for no in not_objects:
					if no is Text and no.is_action():
						not_actions.push_back(ButtonActions.text_type_to_action((no.text_type)))
	
	# Map buttons to actions.
	for b in buttons:
		for a in actions:
			ButtonActions.add_action(b, a)
		
		for na in not_actions:
			ButtonActions.add_not_action(b, na)

# Set whether the game is paused.
func set_pause(var pause : bool):
	paused = pause
	
	reread_button_actions()
