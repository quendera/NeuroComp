extends Node

var ID
var save_file_name
var FlipData
var Task = "Flip"
var PFlip = float(0.15)
var PTrans = float(0.05)
var PRwd = float(0.45)
var RwdSizeL = 4
var RwdSizeR = 4
var ValueMode #toggles value flip on or off. 0 is regular flip, 1 is value flip

var ActiveSide
var LargeSide #0 for left, 1 for right
var Score = 0
var Speed = 5
#var Iti = 500
var Trial = 0
var TrialStart
var MaxStreaks = 100

var RwdSide = "RightPoke"

var LastPokePos
var Streak = 0

var can_poke = 1
var CurrentTime
var TimerStart = 0
var Time = 0
var TimerType
var TimerOn

var Version

onready var sprt = preload("res://scenes/Flip/Stars.tscn")


var RandFlip = randf()
var RandValue = randf()
var RandReward = randf()

# Called when the node enters the scene tree for the first time.
func _ready():
	$Score.set_text("")
	ActiveSide = randi() % 2
	print(ActiveSide)
	Version = Global.Version
	init_file()
	start_stars()


func start_stars():
	var s = sprt.instance()
	$Scenario.add_child(s)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	CurrentTime = OS.get_ticks_msec()
	if (TimerStart + Time) - CurrentTime <= 0 and TimerOn == 1:
		TimerOn = 0
		call(TimerType)
#	var pos = $Player.position
#	#player_anim.global_position = player_anim.global_position.linear_interpolate(pos, delta *(Speed*0.2))
#	print(player_anim.position)

#func iti():
#	can_poke = 1
#	$Feedback.set_text("")
#	print("iti")

# Collects inputs
func _input(event):
	if Score >= 1000 :
		end_task()
	if event is InputEventMouse:
		pass
	else:
		if event is InputEventKey and !event.is_echo() and event.is_pressed():
			if event.scancode == KEY_Q:
				end_task()
			elif event.scancode == KEY_SPACE:
				if $Player.get_position()[0] < 400:  #Poke left
					if LastPokePos == 1:
						if Streak < MaxStreaks:
							Streak += 1
						else:
							end_task()
					LastPokePos = 0
					$Player.scale.x = -1
					if can_poke == 1:
						Trial += 1
						$Player.play_shoot()
						poke(int(0))
				elif $Player.get_position()[0] > 1580:   #Poke right
					if LastPokePos == 0:
						Streak += 1
					LastPokePos = 1
					$Player.scale.x = 1
					if can_poke == 1:
						Trial += 1
						$Player.play_shoot()
						poke(int(1))


		#MOVEMENT
			#Move Left
		elif event.scancode == KEY_LEFT and $Player.get_position()[0] > 300:
			move(-Speed)
			#Move Right
		elif event.scancode == KEY_RIGHT and $Player.get_position()[0] < 1680:
			move(Speed)


func move(direction):
	$Player.translate(Vector2(direction*Speed,0))
	$Player.play_walk()
	if direction > 0:
		$Player.scale.x = -1
	else:
		$Player.scale.x = 1



func poke(Side):
	var vec = Vector2(0,0)
	TrialStart = OS.get_ticks_msec()
	if Side == 0:
		RwdSide = "LeftPoke"
		vec = Vector2(randi()%215+425,randi()%130+730)
	else:
		RwdSide = "RightPoke"
		vec = Vector2(randi()%280+1260,randi()%130+730)
	print(vec)
	get_node(RwdSide).position = vec
	if can_poke == 1:
		if Side == ActiveSide:
			RandFlip = randf()
			RandValue = randf()
			RandReward = randf()
			can_poke = 0
			print("F ", RandFlip," V ", RandValue, " R ", RandReward)
			if RandValue <= PTrans:
				value_flip()
			if RandFlip <= PFlip:
				poke_flip()
			if RandReward <= PRwd:
				match Side:
					0: #left
						Score = Score + RwdSizeL
#						$Feedback.set_text(str("+",RwdSizeL))
						print("Reward of ", RwdSizeL, " to a score of ",Score)
					1: #right
						Score = Score + RwdSizeR
#						$Feedback.set_text(str("+",RwdSizeR))
						print("Reward of ", RwdSizeR, " to a score of ",Score)
						
				$ProgressBar.value = 1000-Score
#				$Score.set_text(str(1000-Score))
				get_node(RwdSide).play("reward")
			else:
				get_node(RwdSide).play("no_reward")
		else:
			can_poke = 0
			get_node(RwdSide).play("no_reward")
		can_poke = 0
#		timer(Iti, "iti")
		log_data("poke")


func timer(time, event):
	TimerStart = OS.get_ticks_msec()
	Time = time
	TimerType = event
	TimerOn = 1

func value_flip():
	pass
#	if RwdSizeL == 3:
#		RwdSizeL = 6
#		RwdSizeR = 3
#	elif RwdSizeL == 6:
#		RwdSizeL = 3
#		RwdSizeR = 6

func poke_flip():
	ActiveSide = abs(ActiveSide-1)
	print("flipped to ", ActiveSide)
	log_data("flip")


func init_file():
	ID = OS.get_unix_time()
	save_file_name = str(ID)
	
#build data dict
	FlipData = {
		"trial":[],
		"trial_time":[],
		"event":[],

		"score":[],

		
		#session metadata
		"subj_id":[],
		"task":[],
		"version":[],
		"start_time":[], #redundant
		
		#input
		
		#settings
		"max_streaks":[],
		"reward_size_left":[],
		"reward_size_right":[],
		"prob_flip":[],
		"prob_trans":[],
		"prob_rwd":[],
		"value_flip":[],
		"active_side":[],
		"large_side":[],
		"travel_speed":[],
		"iti":[],
		"streak":[],
		"log_time":[],
		"rand_flip":[],
		"rand_value":[],
		"rand_reward":[]
		}


func _on_LeftPoke_animation_finished():
	if $LeftPoke.animation == "empty" :
		pass
	else:
		$LeftPoke.play("empty")
#		$Feedback.set_text("")
		can_poke = 1


func _on_RightPoke_animation_finished():
	if $RightPoke.animation == "empty" :
		pass
	else:
		$RightPoke.play("empty")
#		$Feedback.set_text("")
		can_poke = 1


func log_data(Event):
		#trial info
		FlipData["trial"].push_back(Trial)
		FlipData["trial_time"].push_back(TrialStart)
		FlipData["event"].push_back(Event)

		FlipData["score"].push_back(Score)

		
		#session metadata
		FlipData["subj_id"].push_back(ID)
		FlipData["task"].push_back(Task)
		FlipData["version"].push_back(Version)
		FlipData["start_time"].push_back(ID) #redundant
		
		#input
		
		#settings
		FlipData["max_streaks"].push_back(MaxStreaks)
		FlipData["reward_size_left"].push_back(RwdSizeL)
		FlipData["reward_size_right"].push_back(RwdSizeR)
		FlipData["prob_flip"].push_back(PFlip)
		FlipData["prob_trans"].push_back(PTrans)
		FlipData["prob_rwd"].push_back(PRwd)
		FlipData["value_flip"].push_back(ValueMode)
		FlipData["active_side"].push_back(ActiveSide)
		FlipData["large_side"].push_back(LargeSide)
		FlipData["travel_speed"].push_back(Speed)
		FlipData["iti"].push_back(int(1))
		FlipData["streak"].push_back(Streak)
		FlipData["log_time"].push_back(CurrentTime)
		FlipData["rand_flip"].push_back(RandFlip)
		FlipData["rand_value"].push_back(RandValue)
		FlipData["rand_reward"].push_back(RandReward)


func end_task():
	var file = File.new()
	file.open(str("user://F", save_file_name, ".json"), file.WRITE)
	file.store_line(to_json(FlipData))
	file.close()
	Global.goto_scene("res://scenes/Main.tscn")