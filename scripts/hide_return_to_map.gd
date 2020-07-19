extends Polygon2D

# Hide's the RETURN TO MAP text if returning to map is not allowed.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	visible = !LevelHandler.parent_is_reached()
