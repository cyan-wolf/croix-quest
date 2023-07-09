extends Node2D

var _bullet_speed: float = 1000.0
var _bullet_scene := preload("res://weapons/scenes/Bullet1.tscn")

func _process(_delta):
	self.look_at(self.get_global_mouse_position())

	if self.rotation_degrees > 90 or self.rotation_degrees < -90:
		$Sprite2D.flip_v = true
	else:
		$Sprite2D.flip_v = false

	if self.rotation_degrees >= 269:
		self.rotation_degrees = 90
	if self.rotation_degrees <= -269:
		self.rotation_degrees = -90

	if Input.is_action_just_pressed("Shoot"):
		_fire()


func _fire(): #Maybe change parameters for different _bullet_scene types?
	var bullet_instance := _bullet_scene.instantiate()
	bullet_instance.position = self.global_position
	bullet_instance.rotation = self.rotation

	# Calculated using math.
	var impulse := Vector2(cos(self.rotation), sin(self.rotation)) * _bullet_speed

	bullet_instance.apply_impulse(impulse)
	self.get_tree().get_root().add_child(bullet_instance)#call_deferred("add_child", bullet_instance)

