extends SpringArm


var mouse_sensitivity = 0.5
var scroll_speed = 40


# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_toplevel(true)
	spring_length = 7

#func _process(delta):
#	pass

func _physics_process(delta):
	# zoom the camera in or out based on the scroll wheel
	if Input.is_action_just_released("scroll_up"):
		spring_length -= scroll_speed * delta
	if Input.is_action_just_released("scroll_down"):
		spring_length += scroll_speed * delta
	spring_length = clamp(spring_length, 0, 12)

func _unhandled_input(event):
	# move the camera if the RMB is held
	if event is InputEventMouseMotion and Input.is_action_pressed("right_mouse_button"):
		rotation_degrees.y -= event.relative.x * mouse_sensitivity
		rotation_degrees.x = clamp(rotation_degrees.x, -90.0, 90.0)
		
		rotation_degrees.x -= event.relative.y * mouse_sensitivity
		rotation_degrees.y = wrapf(rotation_degrees.y, 0.0, 360.0)
