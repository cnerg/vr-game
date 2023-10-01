extends StaticBody

# arrays that contain the boundaries of voxels 
var bounds_x = []
var bounds_y = []
var bounds_z = []

# array that contains voxel centroids and radiation values
# index 0-2 are (x,y,z) of centroid
# index 3 is radiation value
# index 4 is relative error
var radiation_map = []

# maximum indices for the 3 axes and for radiation_map
var max_index_x = 0
var max_index_y = 0
var max_index_z = 0
var max_index = 0

# index of the last voxel queried from getRadiation()
var prev_index = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	var csv_file = File.new()
	csv_file.open("res://tank10.csv", File.READ)
	
	# Note: for the tank, all position data is in cm. Therefore, we divide by 
	# 100 to get meters.
	
	# get x boundaries
	var csv_line = csv_file.get_csv_line()
	for i in range(0, csv_line.size()):
		bounds_x.append(float(csv_line[i]) / 100);
		
	# get y boundaries
	csv_line = csv_file.get_csv_line()
	for i in range(0, csv_line.size()):
		bounds_y.append(float(csv_line[i]) / 100);
		
	# get z boundaries
	csv_line = csv_file.get_csv_line()
	for i in range(0, csv_line.size()):
		bounds_z.append(float(csv_line[i]) / 100);
		
	# calculate max x,y,z indices
	# (-1) there's one extra bound compared to number of spaces
	max_index_x = bounds_x.size() - 1
	max_index_y = bounds_y.size() - 1
	max_index_z = bounds_z.size() - 1
	
	# get voxel data
	while !csv_file.eof_reached(): 
		csv_line = csv_file.get_csv_line()
		var voxel = []
		for i in range(0, csv_line.size()):
			# first 3 values are x,y,z of centroid in cm, so divide by 100
			if i <= 2:
				voxel.append(float(csv_line[i]) / 100)
			# next 2 values are not in cm, so take them as is
			else:
				voxel.append(float(csv_line[i]))
		radiation_map.append(voxel)
	
	csv_file.close()
	
	# calculate max total index for radiation_map
	max_index = radiation_map.size()
	
	print("done loading tank\n")
	print(str(radiation_map[0]) + "\n")
	print("max index: " + str(max_index))
	print("max index x: " + str(max_index_x))
	print("max index y: " + str(max_index_y))
	print("max index z: " + str(max_index_z))
	
# returns the radiation value and the voxel at the input position
func get_radiation(x, y, z):
	# get the x_index based on input x
	var x_index = 0
	var rel_x = x - translation.x # position relative to this tank
	while x_index < bounds_x.size() and rel_x >= bounds_x[x_index]:
		#print("hey")
		x_index = x_index + 1
	
	#print(str(bounds_x[0]) + "," + str(bounds_x[1]))	
	
	# get the y_index based on input y
	var y_index = 0
	var rel_y = y - translation.y # position relative to this tank
	while y_index < bounds_y.size() and rel_y >= bounds_y[y_index]:
		y_index = y_index + 1
	
	# get the z_index based on input z
	var z_index = 0
	var rel_z = z - translation.z # position relative to this tank
	while z_index < bounds_z.size() and rel_z >= bounds_z[z_index]:
		z_index = z_index + 1
		
	# subtract 1 from indices to get the real index
	x_index = x_index - 1
	y_index = y_index - 1
	z_index = z_index - 1	

	var index = -1
	# check if input position is inside the radiation map
	# min index = 1
	# max index = size of array
	if x_index >= 0 and x_index < max_index_x and \
			y_index >= 0 and y_index < max_index_y and \
			z_index >= 0 and z_index < max_index_z:
		index = (x_index * max_index_y * max_index_z) + (y_index * max_index_z) \
				+ z_index
	var value = 0
	var centroid = Vector3.ZERO
	
	# only access the array for voxel info if we are in the voxel map
	if index >= 0 and index < max_index:
		value = radiation_map[index][3]
		centroid.x = radiation_map[index][0]
		centroid.y = radiation_map[index][1]
		centroid.z = radiation_map[index][2]
		
		if index != prev_index:
			# set mesh's position to voxel's centroid 
			$CurrentVoxel.translation.x = centroid.x
			$CurrentVoxel.translation.y = centroid.y
			$CurrentVoxel.translation.z = centroid.z
			
			# set size of mesh
			$CurrentVoxel.scale.x = bounds_x[x_index + 1] - bounds_x[x_index]
			$CurrentVoxel.scale.y = bounds_y[y_index + 1] - bounds_y[y_index]
			$CurrentVoxel.scale.z = bounds_z[z_index + 1] - bounds_z[z_index]
			
			# update prev_index to latest index queried
			prev_index = index
			
			# show the mesh
			$CurrentVoxel.visible = true
	else:
		# don't show the mesh if input position isn't a voxel in the map
		$CurrentVoxel.visible = false
		
	# return an array with the radiation value and the voxel position
	return [value, centroid]
	
