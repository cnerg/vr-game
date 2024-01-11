extends Node

onready var loading_scene = preload("res://scenes/LoadingScreen.tscn")
var current_scene

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)

# Use this function for loading in scenes which take a long time to load
# next_scene: filepath to the scene you want
func load_scene(next_scene):
	# add loading scene to root
	var loading_scene_instance = loading_scene.instance()
	get_tree().get_root().call_deferred("add_child", loading_scene_instance)
	
	# start loading the next scene
	var loader = ResourceLoader.load_interactive(next_scene)
	# check for errors
	if loader == null:
		print("error occurred while getting the NEXT scene")
		pass
	
	# remove current scene from root
	current_scene.queue_free()
	# wait for 0.5s for loading scene to appear
	yield(get_tree().create_timer(1), "timeout")
	
	# load next scene using poll()
	# poll() needs to be in a loop because it loads data in chunks
	while true: 
		var status = loader.poll()
		# a chunk of data was loaded
		if status == OK:
			# update progress bar according to amount of data loaded
			var progress_bar = loading_scene_instance.get_node("./CanvasLayer2/ProgressBar")
			progress_bar.value = float(loader.get_stage()) / loader.get_stage_count() * 100
		
		# finished loading next scene	
		elif status == ERR_FILE_EOF:
			# create instance of next scene
			var next_scene_instance = loader.get_resource().instance()
			# add it to root
			get_tree().get_root().call_deferred("add_child", next_scene_instance)
			# set it as the new current_scene
			current_scene = next_scene_instance
			# remove loading scene
			loading_scene_instance.queue_free()
			# housekeeping to make sure game is unpaused and player can move mouse
			make_game_playable()
			return
			
		# an error occurred while loading
		else:
			print("error occurred when loading NEXT scene")
			return

# Use this function to change to scenes that load quickly
# This is a replacement of the change_scene() function
# next_scene: filepath to the scene you want
func go_to_scene(next_scene):
	# use call_deferred because the current_scene might still be executing code
	# call_deferred runs when nothing else is running
	call_deferred("_deferred_go_to_scene", next_scene)

func _deferred_go_to_scene(next_scene):
	# remove the current scene
	current_scene.free()
	# load the next scene
	var s = ResourceLoader.load(next_scene)
	# instance the next scene
	current_scene = s.instance()
	# Add it to the active scene, as child of root.
	get_tree().root.add_child(current_scene)
	# housekeeping to make sure game is unpaused and player can move mouse
	make_game_playable()
	
func make_game_playable():
	# unpause the game
	get_tree().paused = false
	# let player move mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
