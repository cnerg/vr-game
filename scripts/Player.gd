extends KinematicBody

export var speed = 2
var velocity = Vector3.ZERO

# paths to nodes to improve performance
onready var CameraJoint = $CameraJoint
onready var GC_ValueLabel = $CameraJoint/Camera/GeigerCounter/ValueLabel

func _physics_process(delta):
	var direction = Vector3.ZERO
	
	if Input.is_action_pressed("move_back"):
		direction += Vector3.BACK
	if Input.is_action_pressed("move_forward"):
		direction += Vector3.FORWARD
	if Input.is_action_pressed("move_right"):
		direction += Vector3.RIGHT
	if Input.is_action_pressed("move_left"):
		direction += Vector3.LEFT
	if Input.is_action_pressed("move_up"):
		direction += Vector3.UP
	if Input.is_action_pressed("move_down"):
		direction += Vector3.DOWN
	# allow player to sprint by pressing shift
	if Input.is_action_pressed("sprint"):
		speed = 4
	else:
		speed = 2
	
	# change rotation of the player based on movement
	if direction != Vector3.ZERO:
		# rotate the direction of motion so it's relative to the camera's position
		direction = direction.rotated(Vector3.UP, CameraJoint.rotation.y).normalized()
		# make the player look in the direction of motion
		# this changes the model's orientation
		# only do this if we're not zoomed in (1st person mode)
		if (CameraJoint.spring_length != 0):
			var look_direction = Vector2(direction.z, direction.x)
			rotation.y = look_direction.angle()
	
	velocity = direction * speed
	
	velocity = move_and_slide(velocity, Vector3.UP)
	
	# move the camera with the player
	CameraJoint.translation = translation
	
func set_GeigerCounter_value(value):
	GC_ValueLabel.text = "%.7f" % value
	
