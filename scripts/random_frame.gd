extends GameObject

# Game object that selects a random frame at the beginning.


# Called when the node enters the scene tree for the first time.
func _ready():
	var anim = get_node("AnimatedSprite")
	
	anim.frame = randi() % anim.frames.get_frame_count("default")
