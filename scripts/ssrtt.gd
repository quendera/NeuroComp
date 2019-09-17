extends Node


var StimDuration = 3000 #number in ms
var FeedbackDuration = 2000
var FixationDuration = 500
var TimerStart = int(0)

var MaxTrials = 64
var MaxBlocks =  
# frequency of every 7 experimental trials and at least once within maximally 15 experimental trials.
var ProbSS =  0.25 
var RandSS
var Choice

var InputsActive = 1

var RewardSize = 3
var PunishSize = -1

var Score = 0

var RandSide

var Time
var Event
var CurrentTime
var TimerOn
var PressTime
var SSTime = 2000
var SSTrial


var SSRTData

var SSTimeAdjust = 50

# Called when the node enters the scene tree for the first time.
func _ready():
	RandSide = randi() % 2
	CurrentTime = OS.get_ticks_msec()
	init_file()
	timer(1000, "fixation")



func init_file():
	var save_file_name = str(OS.get_unix_time())
	SSRTData = {
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
		PressTime = OS.get_ticks_msec()	
		Time = 0
		
		if event.scancode == KEY_D:
			Global.goto_scene("res://scenes/Main.tscn")
		
		#choose left
		elif event.scancode == KEY_LEFT and InputsActive:
			print(Event)
			Choice = 0
			choose(Choice, PressTime)

		#choose right
		elif event.scancode == KEY_RIGHT and InputsActive:
			Choice = 1
			choose(Choice, PressTime)
			

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

func choose(choice, press_time):
	if choice != RandSide:
		punish()
	elif SSTrial and press_time > int(TimerStart+SSTime):
		punish()
	else:
		reward()

func reward():
	print("GOOD CHOICE")
	Score = Score + RewardSize
	if SSTrial:
		SSTime += SSTimeAdjust
		print("SS CORRECT ", SSTime)
	$Info.set_text("+ 10 POINTS")
#	reverse()

func punish():
	print("BAD CHOICE")
	Score = Score + PunishSize
	if SSTrial:
		SSTime -= SSTimeAdjust
		print("SS ERROR ", SSTime)
	$Info.set_text("- 5 POINTS" )
#	reverse()


func feedback():
	print("feedback end")
	$Info.set_scale(Vector2(10,10))
	$Info.set_text("+")
	timer(FixationDuration, "fixation")


func fixation():
	$Info.set_scale(Vector2(1,1))
	$Info.set_text("")
	print("fixation end")
	InputsActive = 1
	gen_stim()
	timer(StimDuration, "stim")

func gen_stim():
	RandSide = randi() % 2
	print("RAndSide " , RandSide)
	RandSS = randf()
	if RandSS < ProbSS:
		SSTrial = 1
		timer(SSTime,"stop_sign")
	print(RandSide)
	$Arrow.visible = 1
	if RandSide == 0: #arrow points left
		$Arrow.flip_h = 1
	else: 
		$Arrow.flip_h = 0

func stop_sign():
	pass
	
func stim():
	print("stim end")
	$Arrow.visible = 0
	InputsActive = 0
	timer(FeedbackDuration, "feedback")

