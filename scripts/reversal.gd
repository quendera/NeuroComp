extends Node


var StimDuration = 3000 #number in ms
var FeedbackDuration = 2000
var FixationDuration = 1000
var TimerStart = 0

var MaxTrials = 400
# frequency of every 7 experimental trials and at least once within maximally 15 experimental trials.
var HighStimuli 
var RandSide
var Choice

var InputsActive = 1

var RewardSize = 3
var PunishSize = -1

var CR = 0
var CRStreak = 0
var ReversalThreshold = (randi() % 5) + 6
var Score = 0

var Time
var Event
var CurrentTime
var TimerOn

var ReversalData

# Called when the node enters the scene tree for the first time.
func _ready():
	HighStimuli = randi() % 2
	print(HighStimuli)
	print(CR)
	CurrentTime = OS.get_ticks_msec()
	init_file()
	timer(1000, "fixation")



func init_file():
	var save_file_name = str(OS.get_unix_time())
	ReversalData = {
		"trial":[],
		"subj_id":[],
		"start_time":[],
		"task":[],
		"version":[],
		"key_down":[],
		"key_release":[],
		"key_id":[],
		"stim_duration":[],
		"feedback_duration":[],
		"fixation_duration":[],
		"timer_start":[],
		"":[],
		"mo_act_taken_pos":[],
		"mo_press_x":[],
		"mo_press_y":[],
		"ba_time":[], "ba_position":[], "ba_ID":[], "ba_age":[], 
		"sw_time":[], "sw_subwave_num":[], "sw_offset":[], "sw_flip" : [], "level":[],
		"device_current_time":OS.get_datetime(), "device_OS": OS.get_name(),
		"device_kb_locale":OS.get_locale(), "device_name":OS.get_model_name(),
		"device_screensize_x":OS.get_screen_size().x,"device_screensize_y":OS.get_screen_size().y,
		"device_timezone":OS.get_time_zone_info(),"device_dpi":OS.get_screen_dpi(),
		"device_IP": IP.get_local_addresses()
		}

func timer(time, event):
	TimerStart = OS.get_ticks_msec()
	Time = time
	Event = event
	TimerOn = 1


# Collects inputs
func _input(event):
	if event is InputEventKey and !event.is_echo() and event.is_pressed():
		if event.scancode == KEY_D:
			Global.goto_scene("res://scenes/Main.tscn")
		
		#choose left
		elif event.scancode == KEY_LEFT and InputsActive:
			print(Event)
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
		call(Event)

func choose(choice):
	
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

func reward():
	print("GOOD CHOICE")
	Score = Score + RewardSize
	CRStreak += 1
	CR += 1
	$Info.set_text("+ 10 POINTS")
	reverse()

func punish():
	print("BAD CHOICE")
	Score = Score + PunishSize
	CRStreak = 0
	$Info.set_text("- 5 POINTS" )
	reverse()



func reverse():
	if CRStreak == ReversalThreshold:
		HighStimuli = abs(HighStimuli-1) # 0 = coffee, 1 = scooter
		print("Reversed to ", HighStimuli)
		CRStreak = 0
		ReversalThreshold = (randi() % 5) + 6
		print("Rev. Threshold: " , ReversalThreshold)

func feedback():
	print("feedback end")
	$Info.set_scale(Vector2(10,10))
	$Info.set_text("+")
	timer(FixationDuration, "fixation")


func fixation():
	$Info.set_scale(Vector2(1,1))
	$Info.set_text("")
	print("fixation end")
	$LeftPoke.play("a")
	InputsActive = 1
	gen_stim()
	timer(StimDuration, "stim")

func gen_stim():
	RandSide = randi() % 2
	print(RandSide)
	if RandSide == 1: #SCOOTER ON THE RIGHT
		$LeftPoke.play("A")
		$RightPoke.play("B")
	else: 
		$LeftPoke.play("B")
		$RightPoke.play("A")
		

func stim():
	print("stim end")
	$LeftPoke.play("C")
	$RightPoke.play("C")
	InputsActive = 0
	timer(FeedbackDuration, "feedback")

