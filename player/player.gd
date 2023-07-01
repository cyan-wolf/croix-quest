extends CharacterBody2D

const SPEED = 70

var input_direction: get = _get_input_direction
var sprite_direction = "Right": get = _get_sprite_direction

@onready var sprite = $AnimatedSprite2D

func _physics_process(_delta):
    velocity = input_direction * SPEED
    move_and_slide()
    if input_direction == Vector2.ZERO or input_direction == Vector2(0, 0):
        set_animation("Idle")
    else:
        set_animation("Walk")

func set_animation(animation):
    #var direction = "Side" if sprite_direction in ["Left", "Right"] else sprite_direction    
    sprite.play(animation) #Add {+ direction} to animation if up and down sprite animations are implemented
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