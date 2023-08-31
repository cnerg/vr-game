extends KinematicBody


export var speed = 7
var velocity = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	var direction = Vector3.ZERO
	
	if Input.is_action_pressed("move_back"):
		direction.z += 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_up"):
		direction.y += 1
	if Input.is_action_pressed("move_down"):
		direction.y -= 1
		
	if direction != Vector3.ZERO:
		# rotate the direction so it's relative to the camera's position
		direction = direction.rotated(Vector3.UP, $CameraJoint.rotation.y).normalized()
		# make the player look in the direction of motion
		var look_direction = Vector2(velocity.z, velocity.x)
		rotation.y = look_direction.angle()
	
	velocity.x = direction.x * speed
	velocity.y = direction.y * speed
	velocity.z = direction.z * speed
	
	velocity = move_and_slide(velocity, Vector3.UP)
	
	# move the camera with the player
	$CameraJoint.translation = translation
	$CameraJoint.translation.y = $CameraJoint.translation.y
