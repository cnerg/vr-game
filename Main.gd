extends Node

var rods # all the radioactive rods in the scene

# Called when the node enters the scene tree for the first time.
func _ready():
	rods = get_tree().get_nodes_in_group("rods")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var player_translation = $Player.translation
	
	var voxel_text = ""
	var radiation_value = 0
	# iterate through all rods 
	for rod in rods:
		# find player x,y,z with respect to the rod
		var x = floor(rod.center_x + player_translation.x - rod.translation.x)
		var y = floor(rod.center_y + player_translation.y - rod.translation.y)
		var z = floor(rod.center_z + player_translation.z - rod.translation.z)
	
		# get the data of the voxel we are in
		var index = -1
		# check if we are in the voxel map
		if x >= 0 and x <= 19 and y >= 0 and y <= 19 and z >= 0 and z <= 19:
			index = (y * 19 * 19) + (z * 19) + x
		var value = 0
		var voxel_position = Vector3.ZERO
		# only access the array for voxel info if we are in the voxel map
		if !(index < 0 or index > 6858):
			value = $RadioactiveRod.radiation_array[index][0]
			voxel_position.x = $RadioactiveRod.radiation_array[index][1]
			voxel_position.z = $RadioactiveRod.radiation_array[index][2]
			voxel_position.y = $RadioactiveRod.radiation_array[index][3]
		# add text for the voxel position the player is in
		voxel_text += "\nvoxel: (%s," % voxel_position.x
		voxel_text += "%s," % voxel_position.y
		voxel_text += "%s)" % voxel_position.z
		radiation_value += value
	
	# prepend the radiation value 
	$UserInterface/Label.text = "Radiation: %s" % radiation_value
	$UserInterface/Label.text += voxel_text
	
#	$UserInterface/Label.text += "\nplayer: (%s," % $Player.translation.x
#	$UserInterface/Label.text += "%s," % $Player.translation.y
#	$UserInterface/Label.text += "%s)" % $Player.translation.z
#	$UserInterface/Label.text += "\nrod: (%s," % $RadioactiveRod.translation.x
#	$UserInterface/Label.text += "%s," % $RadioactiveRod.translation.y
#	$UserInterface/Label.text += "%s)" % $RadioactiveRod.translation.z
	
	
	
