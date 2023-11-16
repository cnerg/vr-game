extends AudioStreamPlayer3D

const RADIATION_MIN = 0.000001 # radiation value that will cause no clicking
const RADIATION_MAX = 0.1 # radiation value that will cause the most clicking

const SOUND_START = 0.3 # when the click sound plays in the .ogg file

var radiation = 0 # total radiation at Geiger Counter's location

	
func _process(delta):
	# the more radiation there is, the more likely a sound will be played
	var random = rand_range(RADIATION_MIN, RADIATION_MAX)
	if random < radiation:
		play(SOUND_START)

# set the timer's timeout based on how much radiation there is
func set_radiation(value):
	radiation = value
