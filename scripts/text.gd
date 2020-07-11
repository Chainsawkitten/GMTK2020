extends GameObject
class_name Text

# text_type : TextType
export var text_type: int = 0

# Whether the text is a button.
func is_button():
	return ButtonActions.text_type_to_button(text_type) != ButtonActions.Button.SIZE

# Whether the text is an action.
func is_action():
	return ButtonActions.text_type_to_action(text_type) != ButtonActions.Action.SIZE
