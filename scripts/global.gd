extends Node

var current_scene = null
var Dict = {}

func _ready():
	randomize()
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)
	Dict["init_time"] = OS.get_unix_time()
	print(Dict)
	var file = File.new()
#	if !file.file_exists("user://Data"):
#		file.open_compressed("user://Data",File.WRITE)
#		file.store_32(device_ID.x)
#		file.store_32(device_ID.y)
#		file.close()
#	else:
#		file.open_compressed("user://deviceID",File.READ)
#		device_ID.x = int(file.get_32())
#		device_ID.y = int(file.get_32())
#		file.close()
#	if file.file_exists("user://hiscores"):
#		file.open_compressed("user://hiscores",File.READ)
#		global.max_level = int(file.get_32())
#		file.close()
	
func goto_scene(path):
	# This function will usually be called from a signal callback,
	# or some other function in the current scene.
	# Deleting the current scene at this point is
	# a bad idea, because it may still be executing code.
	# This will result in a crash or unexpected behavior.
	
	# The solution is to defer the load to a later time, when
	# we can be sure that no code from the current scene is running:
	
	call_deferred("_deferred_goto_scene", path)


func _deferred_goto_scene(path):
	# It is now safe to remove the current scene
	current_scene.free()
	
	# Load the new scene.
	var s = ResourceLoader.load(path)
	
	# Instance the new scene.
	current_scene = s.instance()
	
	# Add it to the active scene, as child of root.
	get_tree().get_root().add_child(current_scene)
	
	# Optionally, to make it compatible with the SceneTree.change_scene() API.
	get_tree().set_current_scene(current_scene)