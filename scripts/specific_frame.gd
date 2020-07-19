extends GameObject

# Game object that selects a specific frame to display.

export var frame : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	var anim = get_node("AnimatedSprite")
	
	anim.frame = frame
