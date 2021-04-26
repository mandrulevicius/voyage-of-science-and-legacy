extends Node

# would like to explore better options for a command handler, but will have to settle for hardcoded for now

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func process_input(text):
	if text == '':
		get_parent().receive_command('continue', 'Interpreter')
		return
	get_parent().receive_message('unknown command - ' + text, 'Interpreter')
