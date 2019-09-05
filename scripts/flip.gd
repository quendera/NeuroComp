extends Node


var PFlip = float(0.3)
var PTrans = float(0.05)
var PRwd = float(0.9)
var RwdSizeL = 3
var RwdSizeR = 6
var ValueMode #toggles value flip on or off. 0 is regular flip, 1 is value flip
var RwdBool = 0
var ActiveSide
var LargeSide #0 for left, 1 for right
var Score = 0
var Speed = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	ActiveSide = randi() % 2
	print(ActiveSide)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# Collects inputs
func _input(event):
	if event is InputEventKey and !event.is_echo() and event.is_pressed():
		if event.scancode == KEY_D:
			Global.goto_scene("res://scenes/Main.tscn")
		
		#Poke left
		elif event.scancode == KEY_Q:
			poke(int(0))
		#Poke right
		elif event.scancode == KEY_P:
			poke(int(1))
			
	#MOVEMENT
		#Move Right
		elif event.scancode == KEY_RIGHT:
			move(1)
		#Move Left
		elif event.scancode == KEY_LEFT:
			move(-1)

func move(direction):
	$Player.translate(Vector2(direction*Speed,0))
	print($Player.get_position()[0])


func poke(Side):

	
	if Side == ActiveSide:
		var RandFlip = randf()
		var RandValue = randf()
		var RandReward = randf()
		
		print("F ", RandFlip," V ", RandValue, " R ", RandReward)
	
		if RandFlip <= PFlip:
			poke_flip()
		elif RandReward <= PRwd:
			match Side:
				0: #left
					Score = Score + RwdSizeL
					print("Reward of ", RwdSizeL, " to a score of ",Score)
				1: #right
					Score = Score + RwdSizeR
					print("Reward of ", RwdSizeR, " to a score of ",Score)
#			$AnimatedSprite.play("reward")
#		else:
#			$AnimatedSprite.play("no_reward")


func value_flip():
	match randi() % 2:
		0:
			RwdSizeL = 2*RwdSizeR
		1:
			RwdSizeR = 2*RwdSizeL

func poke_flip():
	ActiveSide = abs(ActiveSide-1)
	print("flipped to ", ActiveSide)