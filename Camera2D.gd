extends Camera2D

var shaking
var time = 0

func _ready():
	pass # Replace with function body.


func _process(delta):
	if shaking:
		time += delta	
		if time > 0.1:
			time = 0
			self.offset = Vector2(rand_range(-2, 2), rand_range(-2, 2))
