extends Control

onready var lvl_complete = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# display the TabScreen when TAB is pressed, but only when we haven't 
	# completed the level
	if !lvl_complete:
		visible = Input.is_action_pressed("ui_focus_next")

func set_RadiationText(text):
	$RadiationText.text = text
