extends Node


var StimDuration = 3000 #number in ms
var FeedbackDuration = 2000
var FixationDuration = 1000
var TimerStart = 0
var MaxTrials = 400

# frequency of every 7 experimental trials and at least once within maximally 15 experimental trials.
var HighSide

var RewardSize = 3
var PunishSize = 6

var CR = 0
var CRStreak = 0
var ReversalThreshold = (randi() % 5) + 6

var Score = 0

var ignore_inputs = false


signal fixation
signal feedback
signal stim

# Called when the node enters the scene tree for the first time.
func _ready():
	HighSide = randi() % 2
	print(HighSide)
	print(CR)
	



# Collects inputs
func _input(event):
	if event is InputEventKey and !event.is_echo() and event.is_pressed() and !ignore_inputs:
		if event.scancode == KEY_D:
			Global.goto_scene("res://scenes/Main.tscn")
		
		#choose left
		elif event.scancode == KEY_Q:
			choose(int(0))
		#choose right
		elif event.scancode == KEY_P:
			choose(int(1))
			timer(3000, "feedback")
			
	ignore_inputs = true

func timer(time, event):
	var CurrentTime = OS.get_ticks_msec()
	TimerStart = OS.get_ticks_msec()
	while CurrentTime < TimerStart + time:
		CurrentTime = OS.get_ticks_msec()
		print(CurrentTime)
	emit_signal(event)

func choose(Side):
	
	if Side == HighSide:
		print("GOOD CHOICE")
		Score = Score + RewardSize
		CRStreak += 1
		CR += 1
		reverse()
	
	elif Side != HighSide:
		print("BAD CHOICE")
		Score = Score + PunishSize
		CRStreak = 0
		reverse()



func reverse():
	if CRStreak == ReversalThreshold:
		HighSide = abs(HighSide-1)
		print("Reversed to ", HighSide)
		CRStreak = 0
		ReversalThreshold = (randi() % 5) + 6

func _on_feedback_timeout():
	ignore_inputs = false
	print("feedback")


func _on_fixation_timeout():
	ignore_inputs = false
	print("fixation")


func _on_stim_timeout():
	ignore_inputs = false
	print("stim")
