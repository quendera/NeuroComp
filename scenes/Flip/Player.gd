extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var current_anim 

# Called when the node enters the scene tree for the first time.
func _ready():
	$KinematicBody2D/AnimatedSprite.play("idle")
	current_anim = "idle"

	
func _process(delta):
	if not $KinematicBody2D/AnimatedSprite.is_playing():
		if self.global_position.x > 1600:
			current_anim = "idle_dock"
			$KinematicBody2D/AnimatedSprite.play("idle_dock")
		elif self.global_position.x < 300:
			current_anim = "idle_dock"
			$KinematicBody2D/AnimatedSprite.play("idle_dock")
		else:
			current_anim = "idle"
			$KinematicBody2D/AnimatedSprite.play("idle")

		
func play_shoot():
	current_anim = "shoot"
	$KinematicBody2D/AnimatedSprite.play("shoot")

func play_walk():
	current_anim = "walk"
	$KinematicBody2D/AnimatedSprite.play("walk")


func _on_AnimatedSprite_animation_finished():

	$KinematicBody2D/AnimatedSprite.stop()
