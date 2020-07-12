extends GameObject

# Game object that changes frame based on direction.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var animation = get_node("AnimatedSprite")
	
	if direction_x == -1 and direction_y == 0:
		animation.frame = 3
	if direction_x == 1 and direction_y == 0:
		animation.frame = 2
	if direction_x == 0 and direction_y == -1:
		animation.frame = 1
	if direction_x == 0 and direction_y == 1:
		animation.frame = 0
		
	# Diagonal directions.
	if animation.frames.size() > 4:
		if direction_x == -1 and direction_y == -1:
			animation.frame = 6
		if direction_x == 1 and direction_y == -1:
			animation.frame = 7
		if direction_x == -1 and direction_y == 1:
			animation.frame = 5
		if direction_x == 1 and direction_y == 1:
			animation.frame = 4
