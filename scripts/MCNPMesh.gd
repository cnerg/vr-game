extends Spatial

# arrays that contain the boundaries of voxels 
var bounds_x = []
var bounds_y = []
var bounds_z = []

# array that contains voxel centroids and radiation values
# index 0 is a Vector3 of the centroid position
# index 1 is radiation value
# index 2 is relative error
var radiation_map = []

# maximum indices for the 3 axes and for radiation_map
var max_index_x = 0
var max_index_y = 0
var max_index_z = 0
var max_index = 0

# index of the last voxel queried from getRadiation()
var prev_index = -1

# bool for whether the y or z axis is considered the vertical axis in the MCNP file
var y_is_up = true

# bool for whether to show the current voxel mesh
var show_voxel = false

# Used to get the x,y,z boundaries of the voxels in the radiation map
# units is the units of the boundaries. (Ex. if boundaries are in cm, units 
# 	would be 1/100)
func get_bounds(csv_line, units):
	var bounds = []
	for i in range(0, csv_line.size()):
		bounds.append(float(csv_line[i]) * units); 
	return bounds

# Initializes the MCNP mesh. 
# This should be called ONCE in the child class's _ready() function.
# y_is_up_IN should be true if the MCNP file designates y as the vertical axis
#		and false if it designates z as the vertical axis.
func initialize(csv_file_name, y_is_up_IN, units_IN):	
	var csv_file = File.new()
	csv_file.open(csv_file_name, File.READ)
	
	# set internal variables
	y_is_up = y_is_up_IN
	var units = units_IN
	
	# get x,y,z boundaries
	bounds_x = get_bounds(csv_file.get_csv_line(), units)
	if y_is_up:
		bounds_y = get_bounds(csv_file.get_csv_line(), units)
		bounds_z = get_bounds(csv_file.get_csv_line(), units)
	else:
		bounds_z = get_bounds(csv_file.get_csv_line(), units)
		bounds_y = get_bounds(csv_file.get_csv_line(), units)
		
	# calculate max x,y,z indices 
	# (-1) there's one extra bound compared to number of spaces
	max_index_x = bounds_x.size() - 1
	max_index_y = bounds_y.size() - 1
	max_index_z = bounds_z.size() - 1
	
	# default y and z indices, where y = 1, z = 2
	var up_index = 1
	var forward_index = 2
	# swap them if z is up 
	if !y_is_up:
		up_index = 2
		forward_index = 1
	
	# get voxel data
	while !csv_file.eof_reached(): 
		var csv_line = csv_file.get_csv_line()
		var voxel = []
		var voxel_centroid = Vector3.ZERO
		if csv_line.size() == 5:
			# first 3 values are x,y,z of centroid in cm, so multiply by units
			voxel_centroid.x = float(csv_line[0]) * units
			voxel_centroid.y = float(csv_line[up_index]) * units
			voxel_centroid.z = float(csv_line[forward_index]) * units
			voxel.append(voxel_centroid)
			for i in range(3, csv_line.size()):
				voxel.append(float(csv_line[i]))
			radiation_map.append(voxel)
	
	csv_file.close()
	
	# calculate max total index for radiation_map
	max_index = radiation_map.size()
	
	# hide the current voxel mesh on startup
	$CurrentVoxel.visible = show_voxel


# returns the index of the largest value in the array that is still smaller 
# than the input value, otherwise -1
func binary_search(array, value):
	var lower = 0
	var upper = array.size() - 1
	var center = 0
	
	# if the input value is lower than the smallest value in the array or 
	# larger than the biggest value in the array, it's not in the array
	if value < array[lower] or value > array[upper]:
		return -1
		
	while lower < upper:
		center = (lower + upper) / 2
		# if lower and upper are right next to each other and value is between 
		# them, return the lower index
		if lower + 1 == upper:
			if value >= array[lower] and value < array[upper]:
				return lower
			else: 
				return -1
		elif value > array[center]:
			lower = center
		elif value < array[center]:
			upper = center
	
	# default return to catch any other cases			
	return -1 
	
	
# returns the radiation value and the voxel at the input position
func get_radiation(x, y, z):
	# initialize return values
	var centroid = Vector3.ZERO
	var value = 0
	
	# get indices
	var x_index = binary_search(bounds_x, x - translation.x)
	var y_index = binary_search(bounds_y, y - translation.y)
	var z_index = binary_search(bounds_z, z - translation.z)
	
	# return early if any indices are -1 (indicates player is not in radiation map)
	if x_index == -1 or y_index == -1 or z_index == -1:
		$CurrentVoxel.visible = false
		return [value, centroid]	

	# calculate index of voxel that the player is in
	# if z is considered the vertical axis in the MCNP mesh, we need to calculate
	# the index with y as the smallest (since y was swapped with z on initialization,
	# and MCNP indexes with z as the smallest)
	var index = 0
	if y_is_up:
		index = (x_index * max_index_y * max_index_z) + (y_index * max_index_z) \
				+ z_index
	else:
		index = (x_index * max_index_z * max_index_y) + (z_index * max_index_y) \
				+ y_index
	
	# get the voxel's centroid and value
	centroid = radiation_map[index][0]
	value = radiation_map[index][1]

	# update the voxel mesh if we are in a different voxel
	# only update and show the voxel if we want it shown
	if index != prev_index and show_voxel:
		# set mesh's position to voxel's centroid 
		$CurrentVoxel.translation = centroid
		
		# set size of mesh
		$CurrentVoxel.scale.x = bounds_x[x_index + 1] - bounds_x[x_index]
		$CurrentVoxel.scale.y = bounds_y[y_index + 1] - bounds_y[y_index]
		$CurrentVoxel.scale.z = bounds_z[z_index + 1] - bounds_z[z_index]
		
		# update prev_index to latest index queried
		prev_index = index
		
		# show the mesh
		$CurrentVoxel.visible = true
		
	# return an array with the radiation value and the voxel position
	return [value, centroid]
	
# toggles whether the current voxel mesh is shown or not
func toggle_show_voxel():
	show_voxel = !show_voxel
	$CurrentVoxel.visible = show_voxel
