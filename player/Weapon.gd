extends Node2D

var weapon_type := "Shotgun"
var _bullet_speed: float = 1000.0
var _bullet_scene := preload("res://weapons/scenes/Bullet1.tscn")
var bullet_alive_time: float = 0.0
var damage = 0

@onready var sprite = $Sprite2D

func _process(_delta):
	self.look_at(self.get_global_mouse_position())

	if self.rotation_degrees > 90 or self.rotation_degrees < -90:
		sprite.flip_v = true
	else:
		sprite.flip_v = false

	if self.rotation_degrees >= 269:
		self.rotation_degrees = 90
	if self.rotation_degrees <= -269:
		self.rotation_degrees = -90

	if Input.is_action_just_pressed("Shoot"):
		_fire(weapon_type)

	if Input.is_action_just_pressed("Test"): #Switches weapons. TODO: Make another input that switches backwards and flags for picking them up
		if weapon_type == "Shotgun":
			weapon_type = "Gun"
		elif weapon_type == "Gun":
			weapon_type = "Sniper"
		elif weapon_type == "Sniper":
			weapon_type = "Shotgun"

	match weapon_type: #change texture of weapon depending on the weapon
		"Gun":
			sprite.texture = load("res://weapons/sprites/Pistol/pistol.png")
			sprite.scale = Vector2(0.5, 0.5)
			_bullet_speed = 1000.0
			bullet_alive_time = 0.5
			damage = 2
		"Shotgun":
			sprite.texture = load("res://weapons/sprites/Shotgun/Shotgun.png")
			sprite.scale = Vector2(0.5, 0.5)
			_bullet_speed = 500
			bullet_alive_time = 0.25
			damage = 3
		"Sniper":
			sprite.texture = load("res://weapons/sprites/Sniper/Sniper.png")
			sprite.scale = Vector2(0.5, 0.5)
			_bullet_speed = 2000
			bullet_alive_time = 5
			damage = 10

func _remove_bullet(bullet):
	bullet.queue_free()


func _fire(weapon_type): #Maybe change parameters for different _bullet_scene types?
	match weapon_type: #BASICALLY the switch statement, just add "[weapon_type]": to add a case. TODO: Add more weapons
		"Gun":
			var bullet_instance := _bullet_scene.instantiate()
			bullet_instance.position = self.global_position
			bullet_instance.rotation = self.rotation
			bullet_instance.lifetime = bullet_alive_time
			bullet_instance.damage = damage

			# Calculated using math.
			var impulse := Vector2(cos(self.rotation), sin(self.rotation)) * _bullet_speed

			bullet_instance.apply_impulse(impulse)
			self.get_tree().get_root().add_child(bullet_instance)
		"Shotgun":
			for i in range(3):
				var bullet_instance = _bullet_scene.instantiate()
				bullet_instance.position = self.global_position
				bullet_instance.rotation = self.rotation + (i - 1) * 0.1
				bullet_instance.lifetime = bullet_alive_time
				bullet_instance.damage = damage

				var impulse = Vector2(cos(bullet_instance.rotation), sin(bullet_instance.rotation)) * _bullet_speed
				bullet_instance.apply_impulse(impulse)
		
				self.get_tree().get_root().add_child(bullet_instance)	
		"Sniper":
			var bullet_instance := _bullet_scene.instantiate()
			bullet_instance.position = self.global_position
			bullet_instance.rotation = self.rotation
			bullet_instance.lifetime = bullet_alive_time
			bullet_instance.damage = damage

			# Calculated using math.
			var impulse := Vector2(cos(self.rotation), sin(self.rotation)) * _bullet_speed

			bullet_instance.apply_impulse(impulse)
			self.get_tree().get_root().add_child(bullet_instance)
