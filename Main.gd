extends Node

enum { INIT, READY, LAUNCH, EMERGENCY, DRIFT, FLIGHT, HIBERNATION, PHOTOGRAPHY, SAIL }

var state = INIT

var output_box
var command_line

var fuel = 10
var speed = 30.138
var distance = 0
var nominal = false
var taking_photo = false
var x = 0
var y = 0
var start_x = 960 - 500
var start_y = 540 - 500

var time = 0

var speed_display
var distance_display
var fuel_display

func _ready():
	output_box = $HUD/ConsoleContainer/VBoxContainer/Output
	command_line = $HUD/ConsoleContainer/VBoxContainer/HBoxContainer/CommandLine
	speed_display = $HUD/StatsContainer/VBoxContainer/SpeedDisplay
	distance_display = $HUD/StatsContainer/VBoxContainer/DistanceDisplay
	fuel_display = $HUD/StatsContainer/VBoxContainer/FuelDisplay
	output_box.text = ''
	yield(get_tree().create_timer(0.5), "timeout")
	update_output('Initializing systems...')
	yield(get_tree().create_timer(1.5), "timeout")
	update_output('Subsystems initialized. Ready to proceed.')
	yield(get_tree().create_timer(1.5), "timeout")
	update_output('<press enter to continue>')
	command_line.grab_focus()
	command_line.editable = true


func _process(delta):
	time += delta
	if time > 1 and state > LAUNCH:
		time = 0
		distance += speed
	if state == FLIGHT:
		fuel_display.text = str(stepify(fuel, 0.001)) + ' seconds of thrust remaining'
		speed_display.text = str(stepify(speed, 0.001)) + ' km/s'
		distance_display.text = str(stepify(distance, 0.001)) + ' km'
		if Input.is_key_pressed(KEY_SPACE) and fuel > 0 and not nominal:
			fuel -= delta
			speed += delta
			if fuel < 3.6:
				nominal = true
				update_output('Required speed reached. Trajectory nominal')
				yield(get_tree().create_timer(3), "timeout")
				update_output('Exiting active flight mode')
				yield(get_tree().create_timer(3), "timeout")
				update_output('Rerunning analysis...')
				yield(get_tree().create_timer(3), "timeout")
				update_output('All systems working as expected. Trajectory nominal')
				yield(get_tree().create_timer(3), "timeout")
				update_output('Entering hibernation until Jupiter flyby...')
				yield(get_tree().create_timer(3), "timeout")
				state += 1
				$SkyChangeAnimation.play("LightSpaceToDeeper")
				$HUD/StatsContainer.visible = false
				yield(get_tree().create_timer(3), "timeout")
				update_output('/* Few years later... */')
				yield(get_tree().create_timer(3), "timeout")
				update_output('Exiting hibernation, Jupiter flyby eminent')
				yield(get_tree().create_timer(3), "timeout")
				update_output('<run "photo" command to start photography mode>')
				command_line.editable = true
	if state == PHOTOGRAPHY:
		if Input.is_action_just_released("ui_accept"):
			take_photo()
	if taking_photo and time > 0.02:
		time = 0
		if x - start_x > 1000:
			x = start_x
			y += 100
		else:
			x += 100
		$PhotoFrame.position = Vector2(x, y)
		if y - start_y > 1000:
			taking_photo = false
			$PhotoFrame.visible = false
			state += 1
			yield(get_tree().create_timer(3), "timeout")
			update_output('Sending data to Ground Control...')
			yield(get_tree().create_timer(3), "timeout")
			update_output('Ground Control: Data received')
			yield(get_tree().create_timer(3), "timeout")
			update_output('Continuing mission...')
			$SkyChangeAnimation.play("DeeperSpaceToDeepest")
			yield(get_tree().create_timer(3), "timeout")
			update_output('/* The diligent spacecraft continued on to flyby and photograph other celestials - planets Saturn, Uranus and Neptune, and even their moons. */')
			yield(get_tree().create_timer(8), "timeout")
			update_output('/* But there is one more mission before sailing off beyond the solar system... */')
			yield(get_tree().create_timer(6), "timeout")
			update_output('/* To turn around and take photos of various planets, including Earth. */ \n')
			yield(get_tree().create_timer(5), "timeout")
			$EarthPhotoAnimation.play("TurnAround")
			yield(get_tree().create_timer(6), "timeout")
			$EarthPhotoAnimation.play("Zoom")
			yield(get_tree().create_timer(6), "timeout")
			update_output('/* At such distance, Earth is just a pale blue dot, a speck of dust suspended in a sunbeam... */')
			yield(get_tree().create_timer(8), "timeout")
			update_output('/* And yet it is home to many - including those who made this mission possible more than 20 years ago. */')
			yield(get_tree().create_timer(8), "timeout")
			update_output('/* While some of them are still alive, the spacecraft is destined to outlive the Earth itself - a few billion years later it might be the only evidence that the Earth has ever existed... */')
			yield(get_tree().create_timer(10), "timeout")
			update_output('/* And so the voyage continues, deeper and deeper into interstellar space... */')
			yield(get_tree().create_timer(6), "timeout")
			update_output('<press enter to end the game>')
			command_line.editable = true


func take_photo():
	x = start_x
	y = start_y
	$PhotoFrame.position = Vector2(x, y)
	$PhotoFrame.visible = true
	taking_photo = true


func _on_CommandLine_text_entered(new_text):
	command_line.text = ''
	update_output(
		$HUD/ConsoleContainer/VBoxContainer/HBoxContainer/PathLabel.text +
		new_text)
	receive_command(new_text)


func update_output(text):
	output_box.text += text + '\n'
	output_box.visible_characters = output_box.text.length()
		#$HUD/ConsoleContainer/VBoxContainer/Output.visible_characters += 1
		#print($HUD/ConsoleContainer/VBoxContainer/Output.visible_characters)


func update_output_slow(text):
	output_box.text += text + '\n'
	play_typing(2)

func play_typing(duration):
	# not implemented
	var typing = $Tween
	print(typing.is_active())
	if typing.is_active():
		typing.stop(output_box)
	typing.interpolate_property(output_box, 'visible_characters',
		output_box.visible_characters, output_box.text.length(),
		duration)
	typing.start()


func receive_message(text, sender):
	update_output(sender + ': ' + text)


func receive_command(text):
	match text:
		'':
			if state == INIT:
				state += 1
				command_line.editable = false
				yield(get_tree().create_timer(1), "timeout")
				$GroundControl.receive_message('ready')
			elif state == EMERGENCY:
				command_line.editable = false
				yield(get_tree().create_timer(0.5), "timeout")
				update_output('Ground Control sending a status request')
				yield(get_tree().create_timer(3), "timeout")
				update_output('Status request rejected due to emergency mode')
				yield(get_tree().create_timer(3), "timeout")
				update_output('Ground Control sending a request to end emergency mode')
				yield(get_tree().create_timer(3), "timeout")
				update_output('Request rejected due to emergency mode')
				yield(get_tree().create_timer(4), "timeout")
				update_output('Ground Control sending a request for manual override')
				yield(get_tree().create_timer(3), "timeout")
				update_output('Request rejected due to emergency mode')
				yield(get_tree().create_timer(4), "timeout")
				update_output('Ground Control sending a reboot request')
				yield(get_tree().create_timer(3), "timeout")
				update_output('<please run the "reboot" command>')
				command_line.editable = true
			elif state == SAIL:
				$EndAnimation.play("End")
				yield(get_tree().create_timer(6), "timeout")
				get_tree().quit()
			else:
				yield(get_tree().create_timer(0.5), "timeout")
				update_output('Wrong command - ' + text)
		'launch':
			if state == READY:
				state += 1
				play_launch_sequence()
		'reboot':
			if state == EMERGENCY:
				command_line.editable = false
				yield(get_tree().create_timer(0.5), "timeout")
				update_output('Rebooting system...')
				yield(get_tree().create_timer(3), "timeout")
				update_output('Reboot successful')
				yield(get_tree().create_timer(2), "timeout")
				state += 1
				update_output('Running periodic system analysis...')
				yield(get_tree().create_timer(3), "timeout")
				update_output('Analysis complete. Found one critical issue')
				yield(get_tree().create_timer(3), "timeout")
				update_output('Current speed below minimum required for nominal trajectory')
				yield(get_tree().create_timer(3), "timeout")
				update_output('Reason - second propellant tank missing fuel, leak detected')
				yield(get_tree().create_timer(3), "timeout")
				update_output('<run "flight" command to enter active flight mode>')
				command_line.editable = true
			else:
				yield(get_tree().create_timer(0.5), "timeout")
				update_output('Wrong command - ' + text)
		'flight':
			if state == DRIFT:
				command_line.editable = false
				yield(get_tree().create_timer(0.5), "timeout")
				$HUD/StatsContainer.visible = true
				update_output('<hold space to accelerate>')
				state += 1
			else:
				yield(get_tree().create_timer(0.5), "timeout")
				update_output('Wrong command - ' + text)
		'photo':
			if state == HIBERNATION:
				command_line.editable = false
				yield(get_tree().create_timer(0.5), "timeout")
				update_output('<press space to take a photo>')
				state += 1
				$Jupiter.visible = true
				$JupiterAnimation.play("JupiterFlyby")
			else:
				yield(get_tree().create_timer(0.5), "timeout")
				update_output('Wrong command - ' + text)
		_:
			yield(get_tree().create_timer(0.5), "timeout")
			update_output('Unknown command - ' + text)


func _on_Output_ready():
	pass


func play_launch_sequence():
	$Camera2D.shaking = true
	yield(get_tree().create_timer(3), "timeout")
	$SkyChangeAnimation.play("SkyToLightSpace")
	yield(get_tree().create_timer(3), "timeout")
	update_output('UNEXPECTED TURBULENCE! EMERGENCY MODE ACTIVATED')
	$AlarmAnimation.play("Alarm")
	yield(get_tree().create_timer(3), "timeout")
	update_output('BACKUP ROUTINES ACTIVATED')
	yield(get_tree().create_timer(3), "timeout")
	$Camera2D.shaking = false
	$AlarmAnimation.stop()
	state += 1
	yield(get_tree().create_timer(3), "timeout")
	update_output('Receiving communication request from Ground Control...')
	yield(get_tree().create_timer(2.5), "timeout")
	update_output('<press enter to reestablish connection>')
	command_line.editable = true
