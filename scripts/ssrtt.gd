extends Node

var ID
var SSRTTData
var Task = "SSRTT"
var Version = Global.Version
var save_file_name

var StimDuration = 3000 #number in ms
var FeedbackDuration = 1000
var FixationDuration = 500
var TimerStart = int(0)


var MaxTrials = 256
# frequency of every 7 experimental trials and at least once within maximally 15 experimental trials.
var ProbSS =  0.25 
var RandSS
var Choice
var ChoiceTime

var InputsActive = 1

var Score = 0

var RandSide

var Time
var Event
var EventLog
var CurrentTime
var TimerOn
var PressTime
var SSTime = 200
var SSTrial

var Trial = 0
var TrialStart

var SSRTData

var SSTimeAdjust = 50
var TimerStartss = 0
var Timess = 0
var Eventss
var TimerssOn = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$Arrow.visible = 0
	$Fixation.visible = 1
	$Info.set_text("")
	RandSide = randi() % 2
	CurrentTime = OS.get_ticks_msec()
	init_file()
	timer(FixationDuration, "fixation")



func init_file():
	ID = OS.get_unix_time()
	save_file_name = str(ID)
	
#build data dict
	SSRTTData = {
		"trial":[],
		"trial_start":[],
		"stim_layout":[],
		"rand_ss":[],
		"ss_trial":[],
		"event":[],
		"time":[],
		"ss_time":[],
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
		"ss_prob":[],
		"ss_adjust":[],
		"score":[],
		}

func timer(time, event):
	TimerStart = OS.get_ticks_msec()
	Time = time
	Event = event
	TimerOn = 1

func timerss(time, event):
	TimerStartss = OS.get_ticks_msec()
	Timess = time
	Eventss = event
	TimerssOn = 1

# Collects inputs
func _input(event):
	if event is InputEventKey and !event.is_echo() and event.is_pressed():
		ChoiceTime = OS.get_ticks_msec()
		if event.scancode == KEY_Q:
			end_task()
		
		#choose left
		elif event.scancode == KEY_LEFT and InputsActive:
#			print(Event)
			Choice = 0
			PressTime = OS.get_ticks_msec()
			choose(Choice, PressTime)
			Time = 0
		#choose right
		elif event.scancode == KEY_RIGHT and InputsActive:
			Choice = 1
			PressTime = OS.get_ticks_msec()
			choose(Choice, PressTime)
			Time = 0
			

func _process(delta):
	CurrentTime = OS.get_ticks_msec()
	if (TimerStart + Time) - CurrentTime <= 0 and TimerOn == 1:
		TimerOn = 0
		call(Event)
		print("called ",Event)
	elif (TimerStartss + Timess) - CurrentTime <= 0 and TimerssOn == 1:
		TimerssOn = 0
		call(Eventss)

func choose(choice, press_time):
	EventLog = "choice"
	log_data(EventLog)
	if choice != RandSide:
		punish()
	elif SSTrial:
		punish()
	else:
		reward()


func reward():
#	print("GOOD CHOICE")
	if SSTrial:
		SSTime += SSTimeAdjust
		print("SS CORRECT ", SSTime)
	$Info.set_text("CERTO")
	Score += 1
	EventLog = "reward"
	log_data(EventLog)

func punish():
	if SSTrial and SSTime > 50:
		SSTime -= SSTimeAdjust
		print("SS ERROR ", SSTime)
	$Info.set_text("ERRADO")
	Score -= 1
	EventLog = "punish"
	log_data(EventLog)


func feedback():
	$Info.set_text("")
	if SSTrial and Choice == 2:
		reward()
		Eventss = "show_fixation"
		timerss(FeedbackDuration, Eventss)
	elif !SSTrial and Choice == 2:
		punish()
		Eventss = "show_fixation"
		timerss(FeedbackDuration, Eventss)
	else:
		show_fixation()

func show_fixation():
	$Info.set_text("")
	$Fixation.visible = 1
	timer(FixationDuration, "fixation")

func fixation():
	$Info.set_scale(Vector2(1,1))
	$Info.set_text("")
#	$Fixation.visible = 0
	InputsActive = 1
	if Trial == MaxTrials:
		end_task()
	else:
		gen_stim()

func gen_stim():
	RandSide = randi() % 2
	RandSS = randf()
	Trial += 1
	TimerStart = OS.get_ticks_msec()
	if RandSS < ProbSS:
		SSTrial = 1
		timerss(SSTime,"stop_sign")
#		print("SS")
	else:
		SSTrial = 0
#	print(RandSide)
	$Arrow.visible = 1
	if RandSide == 0: #arrow points left
		$Arrow.flip_h = 1
	else: 
		$Arrow.flip_h = 0
	EventLog = "start_trial"
	log_data(EventLog)
	print("score= ",Score)
	Choice = 2
	timer(StimDuration, "stim")


func stop_sign():
	EventLog = "stop_sign"
	log_data(EventLog)
	$SS.play()
	
func stim():
	$Arrow.visible = 0
	$Fixation.visible = 0
	InputsActive = 0
	timer(FeedbackDuration, "feedback")


func log_data(EventLog):
		#trial info
		SSRTTData["trial"].push_back(Trial)
		SSRTTData["trial_start"].push_back(TrialStart)
		SSRTTData["stim_layout"].push_back(RandSide)
		SSRTTData["rand_ss"].push_back(RandSS)
		SSRTTData["ss_trial"].push_back(SSTrial)
		SSRTTData["event"].push_back(EventLog)
		SSRTTData["ss_time"].push_back(SSTime)
		SSRTTData["time"].push_back(CurrentTime)
		
		#session metadata
		SSRTTData["subj_id"].push_back(ID)
		SSRTTData["task"].push_back(Task)
		SSRTTData["version"].push_back(Version)
		SSRTTData["start_time"].push_back(ID) #redundant
		
		#input
		SSRTTData["choice_time"].push_back(ChoiceTime)
		SSRTTData["choice"].push_back(Choice)
		SSRTTData["score"].push_back(Score)
		
		#settings
		SSRTTData["stim_duration"].push_back(StimDuration)
		SSRTTData["feedback_duration"].push_back(FeedbackDuration)
		SSRTTData["fixation_duration"].push_back(FixationDuration)
		SSRTTData["max_trials"].push_back(MaxTrials)
		SSRTTData["ss_prob"].push_back(ProbSS)
		SSRTTData["ss_adjust"].push_back(SSTimeAdjust)

func end_task():
	var file = File.new()
	file.open(str("user://S", save_file_name, ".json"), file.WRITE)
	file.store_line(to_json(SSRTTData))
	file.close()
	Global.goto_scene("res://scenes/Main.tscn")
	