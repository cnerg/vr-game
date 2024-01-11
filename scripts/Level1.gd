extends Node

var sources # all the radioactive sources in the scene
var accumulated_radiation # total radiation accumulated over time

# bools for objectives
onready var saw_cylinder = false # whether the player has seen the cylinder
onready var reached_end_zone = false # whether the player has made it to the end of the level
onready var lvl_complete = false # prevent player from spamming "f" at the EndZone

# paths to nodes to improve performance
onready var GC_ClickSound = $Player/CameraJoint/Camera/GeigerCounter/ClickSound
onready var GeigerCounter = $Player/CameraJoint/Camera/GeigerCounter
onready var PlayerCamera = $Player/CameraJoint/Camera
onready var Player = $Player
onready var Cylinder = $RadioactiveRoom/Cylinder
onready var GlassWall = $RadioactiveRoom/GlassWall
onready var RadiationText = $TabScreen/RadiationText
onready var ReachEndZoneObj = $InstObj1/VBoxContainer/Objectives1/VBoxContainer/CheckBox
onready var SeeCylinderObj = $InstObj1/VBoxContainer/Objectives1/VBoxContainer/CheckBox2
onready var CompLvlText = $CompLvlText
onready var LvlCompleteScreen  = $LvlCompleteScreen
onready var RadiationReceived = $LvlCompleteScreen/RadiationReceived

# Called when the node enters the scene tree for the first time.
func _ready():
	sources = get_tree().get_nodes_in_group("sources")
	accumulated_radiation = 0.0
	# pass reference of InstObj to PauseScreen
	$PauseScreen.InstObj = $InstObj1
	# hide InstObj (pause screen is not visible at start)
	$InstObj1.visible = false
	# hide the CompLvlText prompt when player isn't in EndZone
	CompLvlText.visible = false
	# set the next level
	LvlCompleteScreen.next_level = 1 # TODO change this to 2
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var player_pos = GeigerCounter.global_transform.origin
	
	var voxel_text = ""
	var total_radiation = 0
	var index = 1
	# iterate through all sources 
	for source in sources:
		var radiation = source.get_radiation(player_pos.x, player_pos.y, player_pos.z)
		total_radiation += radiation[0]
		
		# add text for the voxel position the player is in
		voxel_text += "\n%s. %s   [%s, %s, %s]   %s" % [index, source.name, radiation[1].x, \
			radiation[1].y, radiation[1].z, radiation[0]]
		
		# increment index
		index += 1
		
	accumulated_radiation += total_radiation * delta
	
	# set the label's text with total radiation and voxel positions
	RadiationText.text = "Accumulated Radiation: %s\n" % accumulated_radiation
	RadiationText.text += "Total Radiation: %s" % total_radiation
	RadiationText.text += voxel_text
	
	# set value on GeigerCounter
	Player.set_GeigerCounter_value(total_radiation)
	
	# set timeout on ClickTimer for the click sound
	GC_ClickSound.set_radiation(total_radiation)
	
	# toggle whether current voxels in the MCNPMeshes are shown if v is pressed.
	if Input.is_action_just_pressed("toggle_debug"):
		for source in sources:
			source.toggle_show_voxel()
	
	if !saw_cylinder:
		if Global.camera_sees_object(PlayerCamera, Cylinder, [GlassWall]):
			# make sure the objective cannot be completed more than once
			saw_cylinder = true
			# check off the objective
			SeeCylinderObj.pressed = true
			# show a notification for the objective that was completed
			$ObjNotif.add_notification(SeeCylinderObj.text)
		
	# show LvlCompleteScreen if the player presses "f" in the EndZone
	if CompLvlText.visible and Input.is_action_pressed("interact") and !lvl_complete:
		# prevent this from happening more than once
		lvl_complete = true
		complete_level()


func complete_level():	
	# remove PauseScreen to prevent player from pressing "esc" to open it
	$PauseScreen.queue_free()
	# prevent TabScreen from being opened
	$TabScreen.lvl_complete = true
	# reparent Objectives node as child of LvlCompleteScreen
	var objectives = $InstObj1/VBoxContainer/Objectives1
	$InstObj1/VBoxContainer.remove_child(objectives)
	LvlCompleteScreen.add_child(objectives)
	# move objectives to a better position
	objectives.rect_position = RadiationReceived.rect_position
	objectives.rect_position.y += RadiationReceived.rect_size.y + 20
	# set the total radiation received
	LvlCompleteScreen.set_RadiationReceived(accumulated_radiation)
	
	# pause the game
	get_tree().paused = true
	# let player move mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# show the screen
	LvlCompleteScreen.show()
	
	

func _on_EndZone_body_entered(body):
	if body == Player:
		# show the CompLvlText prompt
		CompLvlText.visible = true
		if !reached_end_zone:
			# make sure the objective cannot be completed more than once
			reached_end_zone = true
			# check off the objective
			ReachEndZoneObj.pressed = true
			# show a notification for the objective that was completed
			$ObjNotif.add_notification(ReachEndZoneObj.text)


func _on_EndZone_body_exited(body):
	if body == Player:
		# hide the CompLvlText prompt
		CompLvlText.visible = false
