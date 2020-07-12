extends AnimatedSprite

# Set frame based on whether keyboard or gamepad was last used.

# Called when the node enters the scene tree for the first time.
func _process(_delta):
	if Global.last_was_gamepad:
		frame = 1
	else:
		frame = 0
