extends StaticBody


var radiation_array = []
var center_x = 10.5
var center_y = 10.5
var center_z = 10.5


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
		radiation_array.append(block)
	
	csv_file.close()
	print(radiation_array[0])

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
