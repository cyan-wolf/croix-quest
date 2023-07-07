extends Node2D

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
