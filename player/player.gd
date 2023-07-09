extends CharacterBody2D
class_name Player

const SPEED = 70
var used_speed = SPEED
var timer_on = false
var running = false

var input_direction: get = _get_input_direction
var sprite_direction = "Right": get = _get_sprite_direction

# Contains the player's health value.
@export var health_component: HealthComponent

@onready var sprite = $AnimatedSprite2D
@onready var weapon_sprite = $Weapon/Sprite2D

func _physics_process(_delta):
	#print_debug($RunCountdown.time_left)
	velocity = input_direction * used_speed
	move_and_slide()
	if input_direction == Vector2.ZERO or input_direction == Vector2(0, 0):
		set_animation("Idle")
		used_speed = SPEED
		timer_on = false
		running = false
		$RunCountdown.stop()
	else:
		if timer_on == false:
			$RunCountdown.start()
		timer_on = true
		if running:
			set_animation("Run")
		else:
			set_animation("Walk")


func _process(_delta: float) -> void:
	# DEBUG: The player takes damage if the 'Number Pad 1' key is pressed.
	if Input.is_action_just_pressed("debug_1"):
		self.health_component.take_damage(1)


func set_animation(animation):
	#var direction = "Side" if sprite_direction in ["Left", "Right"] else sprite_direction    
	sprite.play(animation) #Add {+ direction} to animation if up and down sprite animations are implemented. Remember to edit the animation names too if it happens
	sprite.flip_h = (sprite_direction == "Left")
	#weapon_sprite.flip_h = (sprite_direction == "Left") #ANTHONY REMEMBER TO FIX THIS GOD DAMN

func _get_input_direction():
	var x = -int(Input.is_action_pressed("move_left")) + int(Input.is_action_pressed("move_right"))
	var y = -int(Input.is_action_pressed("move_up")) + int(Input.is_action_pressed("move_down"))
	input_direction = Vector2(x, y).normalized() #Without normalized, diagonal movement is faster than horizontal or vertical
	return input_direction

func _get_sprite_direction():
	match input_direction:
		Vector2.LEFT:
			sprite_direction = "Left"
		Vector2.RIGHT:
			sprite_direction = "Right"
	return sprite_direction

func _on_timer_timeout():
	used_speed *= 1.65
	running = true
	$InitialDashParticles.emitting = true
	$InitialDashSFX.play()