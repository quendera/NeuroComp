extends Node2D

var TaskScn = preload("res://scenes/Flip.tscn")
var Task

var TaskNode


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
#	var TaskScript = load(String("res://scripts/" + Task))

#	TaskScn = load(String("res://scenes/" + Task))
#	TaskNode = TaskScn.instance()
#	TaskNode.set_script(TaskScript)
#	Task = $TaskPicker.get_item_text(0) #If you don't select anything, defaults to first option


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_F:
			Global.goto_scene("res://scenes/Flip.tscn")
		if event.scancode == KEY_R:
			Global.goto_scene("res://scenes/Reversal.tscn")
		if event.scancode == KEY_S:
			Global.goto_scene("res://scenes/SSRTT.tscn")

#func _on_TaskPicker_item_selected(ID):
#	Task = $TaskPicker.get_item_text(ID)
#	var TaskScript = load(String("res://scripts/" + Task))
#
#	TaskScn = load(String("res://scenes/" + Task))
#	TaskNode = TaskScn.instance()
#	add_child(TaskNode)
#
#	TaskNode.set_script(TaskScript)
#
