extends Panel

onready var animation = 0

func _process(delta):
	if !$AnimationPlayer.is_playing():
		$AnimationPlayer.play("Move%s" % animation)
		animation = (animation + 1) % 4
		
		
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		get_tree().quit() # default behavior to quit game

func _on_StartButton_pressed():
	# change scene to Level Select scene
	Global.go_to_scene("res://scenes/LevelSelect.tscn")

func _on_QuitButton_pressed():
	# send notification to quit game
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)
