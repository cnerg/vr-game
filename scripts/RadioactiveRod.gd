extends StaticBody

# array that contains voxel extents and radiation values
var radiation_map = []

# offsets for where the center of the radiation map is defined
var center_x = 10.5
var center_y = 10.5
var center_z = 10.5

# maximum indices for the voxels in the radiation_map array
var max_index_x = 19
var max_index_y = 19
var max_index_z = 19

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
	if x >= 0 and x <= max_index_x and \
	        y >= 0 and y <= max_index_y and \
	        z >= 0 and z <= max_index_z:
		index = (y * max_index_y * max_index_y) + (z * max_index_z) + x
	var value = 0
	var voxel_position = Vector3.ZERO
	# only access the array for voxel info if we are in the voxel map
	if !(index < 0 or index >= max_index_x * max_index_y * max_index_z):
		value = radiation_map[index][0]
		voxel_position.x = radiation_map[index][1]
		voxel_position.z = radiation_map[index][2]
		voxel_position.y = radiation_map[index][3]
	
	# return an array with the radiation value and the voxel position
	return [value, voxel_position]
	
	
