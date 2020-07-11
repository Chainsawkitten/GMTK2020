extends AnimatedSprite

# Set frame based on whether keyboard or gamepad was last used.

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Handle input.
func _input(event):
	print("event")
	
	if event is InputEventKey:
		frame = 0
	
	if event is InputEventJoypadButton:
		frame = 1
