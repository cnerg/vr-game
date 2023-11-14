extends Node

var sources # all the radioactive sources in the scene
var accumulated_radiation # total radiation accumulated over time

# Called when the node enters the scene tree for the first time.
func _ready():
	sources = get_tree().get_nodes_in_group("sources")
	accumulated_radiation = 0.0
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var player_pos = $Player/CameraJoint/Camera/GeigerCounter.global_transform.origin
	
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
	$TabScreen/RadiationText.text = "Accumulated Radiation: %s\n" % accumulated_radiation
	$TabScreen/RadiationText.text += "Total Radiation: %s" % total_radiation
	$TabScreen/RadiationText.text += voxel_text
	
	# set value on GeigerCounter
	$Player.set_GeigerCounter_value(total_radiation)
	
	# set timeout on ClickTimer for the click sound
	$Player.GC_click_sound.set_radiation(total_radiation)
	
	# toggle whether current voxels in the MCNPMeshes are shown if v is pressed.
	if Input.is_action_just_pressed("toggle_debug"):
		for source in sources:
			source.toggle_show_voxel()
		
	
