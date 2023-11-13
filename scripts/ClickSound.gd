extends AudioStreamPlayer3D

const RADIATION_MIN = 0.00001 # radiation value that will cause no clicking
const RADIATION_MAX = 0.05 # radiation value that will cause the most clicking
const RADIATION_RANGE = RADIATION_MAX - RADIATION_MIN

const TIMEOUT_MIN = 0.01 # min period between clicks
const TIMEOUT_MAX = 1.0 # max period between clicks
const TIMEOUT_RANGE = TIMEOUT_MAX - TIMEOUT_MIN

const RAND_MIN = 0.0 # min time randomly added to timeout
const RAND_MAX = 0.5 # max time randomly added to timeout

var radiation_present = false # whether or not to play click sounds


# Called when the node enters the scene tree for the first time.
func _ready():
	$ClickTimer.start()

# set the timer's timeout based on how much radiation there is
func set_click_timer_timeout(radiation_value):
	# return early if the Geiger Counter will not be detecting radiation (no clicks)
	if radiation_value < RADIATION_MIN:
		radiation_present = false
		return
	else:
		radiation_present = true
	
	# how much radiation there is in the range of accepted radiation values
	var rad_clamped = clamp(radiation_value, RADIATION_MIN, RADIATION_MAX) - RADIATION_MIN
	# percentage of time we should wait is INVERSE to how much radiation there is
	var time_percent = 1.0 - (rad_clamped / RADIATION_RANGE)
	# scale how much random time is added by 1 - rad_percent
	# (more radiation = less random time)
	var rand_time = rand_range(RAND_MIN, RAND_MAX) * time_percent
	# set the timeout of the timer
	$ClickTimer.set_wait_time(TIMEOUT_MIN + rand_time + (TIMEOUT_RANGE * time_percent))
	

# play the click sound on Timer's timeout
func _on_ClickTimer_timeout():
	print($ClickTimer.wait_time)
	if radiation_present:
		play(0.3)
	else:
		stop()
	$ClickTimer.start()
