extends GameObject
class_name Text

# text_type : TextType
export var text_type: int = 0

# Whether the text is a button.
func is_button():
	match text_type:
		Global.TextType.BUTTON_UP:
			return true
		Global.TextType.BUTTON_LEFT:
			return true
		Global.TextType.BUTTON_RIGHT:
			return true
		Global.TextType.BUTTON_DOWN:
			return true
		Global.TextType.BUTTON_A:
			return true
		Global.TextType.BUTTON_B:
			return true
		Global.TextType.BUTTON_X:
			return true
		Global.TextType.BUTTON_Y:
			return true
	
	return false

func is_action():
	return !is_button() and text_type != Global.TextType.IS
