extends Node


var StimDuration = 3000 #number in ms
var FeedbackDuration = 2000
var FixationDuration = 1000
var TimerStart = 0

var MaxTrials = 400
# frequency of every 7 experimental trials and at least once within maximally 15 experimental trials.
var HighStimuli 
var HighSide

var InputsActive = 1

var RewardSize = 3
var PunishSize = -1

var CR = 0
var CRStreak = 0
var ReversalThreshold = (randi() % 5) + 6
var Score = 0
signal fixation
signal feedback
signal stim

# Called when the node enters the scene tree for the first time.
func _ready():
	HighStimuli = randi() % 2
	print(HighStimuli)
	print(CR)

# Collects inputs
func _input(event):
	if event is InputEventKey and !event.is_echo() and event.is_pressed():
		if event.scancode == KEY_D:
			Global.goto_scene("res://scenes/Main.tscn")
		
		#choose left
		elif event.scancode == KEY_Q and InputsActive:
			print("pressed q")
			choose(int(0))

		#choose right
		elif event.scancode == KEY_P and InputsActive:
			choose(int(1))
			

func timer(time, event):
	var CurrentTime = OS.get_ticks_msec()
	TimerStart = OS.get_ticks_msec()
	while CurrentTime < TimerStart + time:
		CurrentTime = OS.get_ticks_msec()
#		print(CurrentTime)
	emit_signal(event)

func choose(Side):
	
	if Side == HighStimuli:
		print("GOOD CHOICE")
		Score = Score + RewardSize
		CRStreak += 1
		CR += 1
		reverse()
	
	elif Side != HighStimuli:
		print("BAD CHOICE")
		Score = Score + PunishSize
		CRStreak = 0
		reverse()
	print("Score: " , Score)
	



func reverse():
	if CRStreak == ReversalThreshold:
		HighStimuli = abs(HighStimuli-1)
		print("Reversed to ", HighStimuli)
		CRStreak = 0
		ReversalThreshold = (randi() % 5) + 6
		print("Rev. Threshold: " , ReversalThreshold)

func _on_feedback_timeout():
	print("feedback end")
	timer(FixationDuration, "fixation")



func _on_fixation_timeout():
	print("fixation end")
	InputsActive = 1
	timer(StimDuration, "stim")




func _on_stim_timeout():
	print("stim end")
	InputsActive = 0
	timer(int(100), "feedback")

