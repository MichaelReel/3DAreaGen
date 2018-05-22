extends Spatial

export var speed = 1.0

# Intern variables.
var direction = Vector3(0.0, 0.0, 0.0)

func _input(event):
	if event.is_action_pressed("camera_forward"):
		direction.z = -1
	elif event.is_action_pressed("camera_backward"):
		direction.z = 1
	elif not Input.is_action_pressed("camera_forward") and not Input.is_action_pressed("camera_backward"):
		direction.z = 0

	if event.is_action_pressed("camera_left"):
		direction.x = -1
	elif event.is_action_pressed("camera_right"):
		direction.x = 1
	elif not Input.is_action_pressed("camera_left") and not Input.is_action_pressed("camera_right"):
		direction.x = 0

	if event.is_action_pressed("camera_down"):
		direction.y = -1
	elif event.is_action_pressed("camera_up"):
		direction.y = 1
	elif not Input.is_action_pressed("camera_down") and not Input.is_action_pressed("camera_up"):
		direction.y = 0
	


func _process(delta):
	translate(direction * speed * delta)
