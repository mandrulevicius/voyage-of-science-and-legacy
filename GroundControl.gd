extends Node

func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func send_message(text):
	get_parent().receive_message(text, 'Ground Control')


func receive_message(text):
	if text == 'ready':
		send_message('Initiating countdown...')
		yield(get_tree().create_timer(1.5), "timeout")
		send_message('Launch in 3...')
		yield(get_tree().create_timer(1.5), "timeout")
		send_message('2...')
		yield(get_tree().create_timer(1.5), "timeout")
		send_message('1...')
		yield(get_tree().create_timer(1.5), "timeout")
		send_message('Engines on...')
		yield(get_tree().create_timer(1.5), "timeout")
		send_message('Liftoff!')
		get_parent().receive_command('launch')
