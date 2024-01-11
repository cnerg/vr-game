extends Control

var show_pause # whether the pause screen is visible or not
var InstObj # reference to the InstObj of this level

func _ready():
	show_pause = false
	visible = false;
	$CanvasLayer.visible = false
	$CanvasLayer2.visible = false

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		get_tree().quit() # default behavior to quit game
		
func _on_LevelSelectButton_pressed():
	# change scene to Level Select scene
	Global.go_to_scene("res://scenes/LevelSelect.tscn")
	# unpause the game
	get_tree().paused = false
	# allow player to move mouse around
	Input.call_deferred("set_mouse_mode", Input.MOUSE_MODE_VISIBLE)

func _on_QuitButton_pressed():
	# send notification to quit game
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)
	
func _unhandled_key_input(event):
	if event.is_action_pressed("esc"):
		show_pause = !show_pause
		visible = show_pause
		$CanvasLayer.visible = show_pause
		$CanvasLayer2.visible = show_pause
		InstObj.visible = show_pause
		get_tree().paused = show_pause
		if show_pause:
			# let player move mouse (in case he is fully zoomed in)
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			
