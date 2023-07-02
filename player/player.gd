extends CharacterBody2D

const SPEED = 70
var used_speed = SPEED
var timer_on = false
var running = false

var input_direction: get = _get_input_direction
var sprite_direction = "Right": get = _get_sprite_direction

@onready var sprite = $AnimatedSprite2D

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

func set_animation(animation):
    #var direction = "Side" if sprite_direction in ["Left", "Right"] else sprite_direction    
    sprite.play(animation) #Add {+ direction} to animation if up and down sprite animations are implemented. Remember to edit the animation names too if it happens
    sprite.flip_h = (sprite_direction == "Left")

func _get_input_direction():
    var x = -int(Input.is_action_pressed("ui_left")) + int(Input.is_action_pressed("ui_right"))
    var y = -int(Input.is_action_pressed("ui_up")) + int(Input.is_action_pressed("ui_down"))
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
