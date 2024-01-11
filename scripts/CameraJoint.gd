extends SpringArm

var mouse_sensitivity = 0.5
var scroll_speed = 40
const MAX_SPRING_LENGTH = 7;
const INITIAL_SPRING_LENGTH = 3;

# paths to nodes to improve performance
onready var GeigerCounter = $Camera/GeigerCounter

# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_toplevel(true)
	spring_length = 0 # start in 1st person mode

func _physics_process(delta):
	# calculate the absolute zoom amount based on whether we scroll in or out
	var zoom = 0;
	if Input.is_action_just_released("scroll_up") and spring_length > 0:
		zoom = -1 * scroll_speed * delta 	# scroll up is zooming in
	elif Input.is_action_just_released("scroll_down") and spring_length < MAX_SPRING_LENGTH:
		zoom = scroll_speed * delta 		# scroll down is zooming out
		
	spring_length = clamp(spring_length + zoom, 0, MAX_SPRING_LENGTH)
	# make geiger counter move in opposite direction so it appears stationary
	GeigerCounter.translation.z -= zoom
	
	# if the player is fully zoomed in (1st person mode), move mouse to center of screen and
	# lock it there
	if (spring_length == 0) :
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else :
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _unhandled_input(event):
	# move the camera if the mouse is moving and either the RMB is held or the player is
	# fully zoomed in (1st person mode)
	if event is InputEventMouseMotion and (Input.is_action_pressed("right_mouse_button") \
			or spring_length == 0):
		# note: changing rotation_degrees.x means rotating around the x-axis, 
		# 		which would be rotating the camera up or down. 
		#		changing rotation_degrees.y means rotating around the y-axis,
		#		which would be rotating the camera left or right
		# note: event is mouse's motion. Thus, if event.relative.x changes, the 
		# 		mouse has moved left or right. 
		
		# rotate the camera left or right
		rotation_degrees.y -= event.relative.x * mouse_sensitivity
		rotation_degrees.y = wrapf(rotation_degrees.y, 0.0, 360.0)
		
		# rotate the camera up or down
		rotation_degrees.x -= event.relative.y * mouse_sensitivity
		rotation_degrees.x = clamp(rotation_degrees.x, -90.0, 90.0)
		
