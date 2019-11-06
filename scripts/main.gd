extends Node2D

var TaskScn = preload("res://scenes/Flip/Flip.tscn")



# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _input(event):
	if event is InputEventKey and !event.is_echo() and event.is_pressed():
		if event.scancode == KEY_F:
			Global.goto_scene("res://scenes/Flip/Flip.tscn")
		if event.scancode == KEY_R:
			Global.goto_scene("res://scenes/Reversal.tscn")
		if event.scancode == KEY_S:
			Global.goto_scene("res://scenes/SSRTT.tscn")
		if event.scancode == KEY_V:
			$volume_test.play()
		if event.scancode == KEY_Q:
			get_tree().quit()
