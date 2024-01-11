extends Panel

func _on_LevelButton1_pressed():
	Global.load_scene("res://scenes/Level1.tscn")
	
func _on_LevelButton1_mouse_entered():
	$HBoxContainer/ColorRect/TextureRect1.visible = true

func _on_LevelButton1_mouse_exited():
	$HBoxContainer/ColorRect/TextureRect1.visible = false
