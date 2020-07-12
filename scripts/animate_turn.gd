extends AnimatedSprite

# Add to an AnimatedSprite to animate it one step every turn.

var last_turn = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if last_turn != TurnHandler.turn:
		last_turn = TurnHandler.turn
		
		frame = (frame + 1) % frames.get_frame_count("default")
