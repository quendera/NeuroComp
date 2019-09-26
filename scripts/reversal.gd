extends Node

var ID
var ReversalData
var Task = "Reversal"
var Version = "NeuroComp0.1"
var save_file_name

var StimDuration = 3000 #number in ms
var FeedbackDuration = 2000
var FixationDuration = 1000
var TimerStart = 0

var MaxTrials = 400
var Trial
var TrialStart
# frequency of every 7 experimental trials and at least once within maximally 15 experimental trials.
var HighStimuli 
var RandSide
var Choice
var ChoiceTime

var BLTrial = (randi() % 9) + 7
var BLCounter = 0
var BL = 0

var InputsActive = 1

var RewardSize = (randi() % 171) + 80
var PunishSize = (randi() % 171) + 80

var CR = 0
var CRStreak = 0
var ReversalThreshold = (randi() % 5) + 6
var Score = 0
var RewardProb = 0.8

var Time
var TimerType
var CurrentTime
var TimerOn
var Event

# Called when the node enters the scene tree for the first time.
func _ready():
	HighStimuli = randi() % 2
	print(HighStimuli)
	print(CR)
	CurrentTime = OS.get_ticks_msec()
	init_file()
	timer(1000, "fixation")
	Trial = 0
	Event = "task_start"
	log_data(Event)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	



func init_file():
	ID = OS.get_unix_time()
	save_file_name = str(ID)
	
#build data dict
	ReversalData = {
		"trial":[],
		"trial_start":[],
		"high_stim":[],
		"stim_layout":[],
		"cr":[],
		"cr_streak":[],
		"reversal_threshold":[],
		"score":[],
		"event":[],
		"subj_id":[],
		"task":[],
		"version":[],
		"start_time":[],
		"choice_time":[],
		"choice":[],
		"stim_duration":[],
		"feedback_duration":[],
		"fixation_duration":[],
		"max_trials":[],
		"reward_prob":[],
		"reward_size":[],
		"punish_size":[],
		}


func timer(time, event):
	TimerStart = OS.get_ticks_msec()
	Time = time
	TimerType = event
	TimerOn = 1


# Collects inputs
func _input(event):
	if event is InputEventKey and !event.is_echo() and event.is_pressed():
		ChoiceTime = OS.get_ticks_msec()
		if event.scancode == KEY_D:
			end_task()
		
		#choose left
		elif event.scancode == KEY_LEFT and InputsActive:
			print(TimerType)
			Time = 0
			Choice = 0
			choose(Choice)

		#choose right
		elif event.scancode == KEY_RIGHT and InputsActive:
			Time = 0
			Choice = 1
			choose(Choice)
			

#func timer(time, event):
#	var CurrentTime = OS.get_ticks_msec()
#	TimerStart = OS.get_ticks_msec()
#	while CurrentTime < TimerStart + time:
#		CurrentTime = OS.get_ticks_msec()
#		print(CurrentTime)
#	emit_signal(event)


func _process(delta):
	CurrentTime = OS.get_ticks_msec()
	if (TimerStart + Time) - CurrentTime <= 0 and TimerOn == 1:
		TimerOn = 0
		call(TimerType)

func choose(choice):
	if !BL:
		if choice == 0 and RandSide == 0 and HighStimuli == 0:
			punish()
		elif choice == 0 and RandSide == 0 and HighStimuli == 1:
			reward()
		elif choice == 0 and RandSide == 1 and HighStimuli == 0:
			reward()
		elif choice == 0 and RandSide == 1 and HighStimuli == 1:
			punish()
		elif choice == 1 and RandSide == 0 and HighStimuli == 0:
			reward()
		elif choice == 1 and RandSide == 0 and HighStimuli == 1:
			punish()
		elif choice == 1 and RandSide == 1 and HighStimuli == 0:
			punish()
		elif choice == 1 and RandSide == 1 and HighStimuli == 1:
			reward()
		Event = "choice"
		log_data(Event)
	else:
		if (choice - RandSide) == 0:
			reward_bl()
		else:
			punish_bl()
		Event = "choice_bl"
		log_data(Event)

func reward_bl():
	$Info.set_text(str("GOOD CHOICE"))
	Event = "reward_bl"
	log_data(Event)
	
func punish_bl():
	$Info.set_text(str("BAD CHOICE"))
	Event = "punish_bl"
	log_data(Event)

func reward():
	print("GOOD CHOICE")
	var RandP = rand_range(0,1)
	RewardSize = (randi() % 171) + 80
	print(RewardSize)
	$TotInfo.set_text(str(Score, " TOTAL POINTS"))
	if RandP <= RewardProb:
		Score = Score + RewardSize
		CRStreak += 1
		CR += 1
		$Info.set_text(str("+ ", RewardSize, " POINTS"))
		Event = "reward"
		log_data(Event)
	elif ReversalThreshold - CRStreak <= 1:
		Score = Score + RewardSize
		CRStreak += 1
		CR += 1
		$Info.set_text(str("+ ", RewardSize, " POINTS"))
		Event = "reward"
		log_data(Event)
	elif ReversalThreshold - CRStreak == ReversalThreshold:
		Score = Score + RewardSize
		CRStreak += 1
		CR += 1
		$Info.set_text(str("+ ", RewardSize, " POINTS"))
		Event = "reward"
		log_data(Event)
	else:
		Score = Score + PunishSize
		CRStreak += 1
		CR += 1
		$Info.set_text(str("- ", PunishSize, " POINTS"))
		Event = "pe"
		log_data(Event)
	reverse()

func punish():
	print("BAD CHOICE")
	PunishSize = (randi() % 171) + 80
	Score = Score - PunishSize
	CRStreak = 0
	$Info.set_text(str("- ", PunishSize, " POINTS"))
	$TotInfo.set_text(str(Score, " TOTAL POINTS"))
	Event = "punish"
	log_data(Event)
	reverse()

func reverse():
	if CRStreak == ReversalThreshold:
		HighStimuli = abs(HighStimuli-1) # 0 = coffee, 1 = scooter
		print("Reversed to ", HighStimuli)
		CRStreak = 0
		ReversalThreshold = (randi() % 5) + 6
		print("Rev. Threshold: " , ReversalThreshold)
		Event = "reversal"
		log_data(Event)


func feedback():
	print("feedback end")
	$TotInfo.set_text("")
	$Info.set_text("")
	$FixationArrow.visible = 1
	timer(FixationDuration, "fixation")


func fixation():
	$FixationArrow.visible = 0
	print("fixation end")
	InputsActive = 1
	print(BLTrial, ",",BLCounter)
	if Trial < MaxTrials:
		if BLCounter != BLTrial:
			gen_stim()
		elif BLCounter == BLTrial:
			gen_bl()
	elif Trial == MaxTrials:
		end_task()
	timer(StimDuration, "stim")

func gen_bl():
	BL = 1
	RandSide = randi() % 2
	print(RandSide)
	TrialStart = OS.get_ticks_msec()
	if RandSide == 1: #
		$LeftPoke.play("D")
		$RightPoke.play("E")
	else: 
		$LeftPoke.play("E")
		$RightPoke.play("D")
	Trial += 1
	BLCounter = 0
	Event = "bl_trial"
	log_data(Event)
	BLTrial = (randi() % 16) + 7


func gen_stim():
	RandSide = randi() % 2
	print(RandSide)
	TrialStart = OS.get_ticks_msec()
	if RandSide == 1: #SCOOTER ON THE RIGHT
		$LeftPoke.play("A")
		$RightPoke.play("B")
	else: 
		$LeftPoke.play("B")
		$RightPoke.play("A")
	Trial += 1
	BLCounter += 1
	BL = 0
	Event = "trial_start"
	log_data(Event)

func stim():
	print("stim end")
	$LeftPoke.play("C")
	$RightPoke.play("C")
	InputsActive = 0
	timer(FeedbackDuration, "feedback")
	


func log_data(Event):
		#trial info
		ReversalData["trial"].push_back(Trial)
		ReversalData["trial_start"].push_back(TrialStart)
		ReversalData["high_stim"].push_back(HighStimuli)
		ReversalData["stim_layout"].push_back(RandSide)
		ReversalData["cr"].push_back(CR)
		ReversalData["cr_streak"].push_back(CRStreak)
		ReversalData["reversal_threshold"].push_back(ReversalThreshold)
		ReversalData["score"].push_back(Score)
		ReversalData["event"].push_back(Event)
		
		#session metadata
		ReversalData["subj_id"].push_back(ID)
		ReversalData["task"].push_back(Task)
		ReversalData["version"].push_back(Version)
		ReversalData["start_time"].push_back(ID) #redundant
		
		#input
		ReversalData["choice_time"].push_back(ChoiceTime)
		ReversalData["choice"].push_back(Choice)
		
		#settings
		ReversalData["stim_duration"].push_back(StimDuration)
		ReversalData["feedback_duration"].push_back(FeedbackDuration)
		ReversalData["fixation_duration"].push_back(FixationDuration)
		ReversalData["max_trials"].push_back(MaxTrials)
		ReversalData["reward_prob"].push_back(RewardProb)
		ReversalData["reward_size"].push_back(RewardSize)
		ReversalData["punish_size"].push_back(PunishSize)
		

func end_task():
	var file = File.new()
	file.open(str("user://R", save_file_name, ".json"), file.WRITE)
	file.store_line(to_json(ReversalData))
	file.close()
	Global.goto_scene("res://scenes/Main.tscn")
	