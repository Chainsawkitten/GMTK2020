extends GameObject

# Which level to load
export var level : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	if LevelHandler.current_level.children.size() > level:
		if LevelHandler.current_level.children[level].beaten:
			get_node("AnimatedSprite").frame = 1
