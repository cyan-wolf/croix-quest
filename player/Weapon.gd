extends Node2D

var bullet_speed = 1000
var bullet = preload("res://weapons/scenes/Bullet1.tscn")

func _process(_delta):
	look_at(get_global_mouse_position())
	if rotation_degrees > 90 or rotation_degrees < -90:
		$Sprite2D.flip_v = true
	else:
		$Sprite2D.flip_v = false

	

	if rotation_degrees >= 269:
		rotation_degrees = 90
	if rotation_degrees <= -269:
		rotation_degrees = -90

	if Input.is_action_just_pressed("Shoot"):
		_fire()

func _fire(): #Maybe change parameters for different bullet types?
	var bullet_instance = bullet.instantiate()
	bullet_instance.position = get_global_position()
	bullet_instance.rotation_degrees = rotation_degrees
	bullet_instance.apply_impulse(Vector2(), Vector2(bullet_speed, 0).rotated(global_rotation))
	get_tree().get_root().add_child(bullet_instance)#call_deferred("add_child", bullet_instance)
