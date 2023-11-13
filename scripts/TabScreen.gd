extends Control

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# if TAB is pressed, display the TabScreen
	visible = Input.is_action_pressed("ui_focus_next")

func set_RadiationText(text):
	$RadiationText.text = text
