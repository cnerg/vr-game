extends StaticBody

# array that contains voxel extents and radiation values
var radiation_map = []

# offsets for where the center of the radiation map is defined
var center_x = 10.5
var center_y = 10.5
var center_z = 10.5

# maximum indices for the voxels in radiation_map
var max_index_x = 19
var max_index_y = 19
var max_index_z = 19

# maximum index for the radiation_map array (it's calculated in _ready())
var max_index = 0

# index of the last voxel queried from getRadiation()
var prev_index = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	var csv_file = File.new()
	csv_file.open("res://points.csv", File.READ)
	csv_file.get_csv_line() # skip past first line of labels
	
	# copy all values of the csv file into an array
	while !csv_file.eof_reached(): 
		var csv_line = csv_file.get_csv_line()
		var block = []
		for i in range(0, csv_line.size()):
			block.append(float(csv_line[i]))
		radiation_map.append(block)
	
	csv_file.close()
	
	# calculate the maximum index of the radiation map array
	max_index = max_index_x * max_index_y * max_index_z

# returns the radiation value and the voxel at the input position
func get_radiation(x, y, z):
	# find input x,y,z with respect to the source
	# because we define the center to NOT be at (0,0,0), we have to add the
	# center as an offset.
	x = floor(center_x + x - translation.x)
	y = floor(center_y + y - translation.y)
	z = floor(center_z + z - translation.z)

	var index = -1
	# check if we are in the voxel map
	if x >= 0 and x < max_index_x and \
			y >= 0 and y < max_index_y and \
			z >= 0 and z < max_index_z:
		index = (y * max_index_z * max_index_x) + (z * max_index_x) + x
	var value = 0
	var voxel_start_pos = Vector3.ZERO
	
	# only access the array for voxel info if we are in the voxel map
	if !(index < 0 or index >= max_index):
		value = radiation_map[index][0]
		voxel_start_pos.x = radiation_map[index][1]
		voxel_start_pos.z = radiation_map[index][2]
		voxel_start_pos.y = radiation_map[index][3]
		
		# change the mesh if the voxel changed 
		if (prev_index != index):
			var voxel_end_pos = Vector3.ZERO
			voxel_end_pos.x = radiation_map[index][4]
			voxel_end_pos.z = radiation_map[index][5]
			voxel_end_pos.y = radiation_map[index][6]
			
			# set mesh's position to voxel's centroid 
			# don't forget to add the offset of the center of the rod
			$CurrentVoxel.translation.x = (voxel_end_pos.x + voxel_start_pos.x) / 2 - center_x
			$CurrentVoxel.translation.y = (voxel_end_pos.y + voxel_start_pos.y) / 2 - center_y
			$CurrentVoxel.translation.z = (voxel_end_pos.z + voxel_start_pos.z) / 2 - center_z
			
			# set size of mesh
			$CurrentVoxel.scale.x = voxel_end_pos.x - voxel_start_pos.x
			$CurrentVoxel.scale.y = voxel_end_pos.y - voxel_start_pos.y
			$CurrentVoxel.scale.z = voxel_end_pos.z - voxel_start_pos.z
			
			# show the mesh
			$CurrentVoxel.visible = true
				
	else:
		# don't show the mesh if input position isn't a voxel in the map
		$CurrentVoxel.visible = false
		
	# update prev_index to latest index queried
	prev_index = index
	
	# return an array with the radiation value and the voxel position
	return [value, voxel_start_pos]
	
	
