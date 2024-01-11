extends Panel

# create an array as a queue for objectives
var objectives = []
# only show a new notification if we aren't showing one now
onready var showing_notification = false

func _ready():
	visible = false
	modulate.a = 0

func _process(delta):
	if objectives and !showing_notification:
		show_notification(objectives.pop_front())

func add_notification(objective):
	objectives.push_back(objective)

func show_notification(objective):
	showing_notification = true
	visible = true
	$Label.text = "Objective Complete: %s" % objective
	# play the fade in and fade out animation
	$AnimationPlayer.play("Fade")
	# hide the notification after 3s
	$Timer.start(3.0)
	
func _on_Timer_timeout():
	# hide the notification
	visible = false
	# allow the next notification to be shown
	showing_notification = false
	
