extends Panel

var next_level # number of the next level

# Called when the node enters the scene tree for the first time.
func _ready():
	# hide the level complete screen on startup
	visible = false
	$CanvasLayer.visible = false
	modulate.a = 0

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		get_tree().quit() # default behavior to quit game

func _on_LevelSelectButton_pressed():	
	# change scene to Level Select scene
	Global.go_to_scene("res://scenes/LevelSelect.tscn")
	
func _on_QuitButton_pressed():
	# send notification to quit game
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)

func _on_ContinueButton_pressed():
	# go to next level
	Global.load_scene("res://scenes/Level%s.tscn" % next_level)

func show():
	visible = true
	$CanvasLayer.visible = true
	$AnimationPlayer.play("FadeIn")
