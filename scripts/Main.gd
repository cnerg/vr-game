extends Node

var sources # all the radioactive sources in the scene

# Called when the node enters the scene tree for the first time.
func _ready():
	sources = get_tree().get_nodes_in_group("sources")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var player_pos = $Player.translation
	
	var voxel_text = ""
	var total_radiation = 0
	# iterate through all sources 
	for source in sources:
		var radiation = source.get_radiation(player_pos.x, player_pos.y, player_pos.z)
		total_radiation += radiation[0]
		
		# add text for the voxel position the player is in
		voxel_text += "\nvoxel:(%s, %s, %s)" % [radiation[1].x, \
			radiation[1].y, radiation[1].z]
	
	# set the label's text with total radiation and voxel positions
	$UserInterface/Label.text = "Radiation: %s" % total_radiation
	$UserInterface/Label.text += voxel_text
	
	
	
	
