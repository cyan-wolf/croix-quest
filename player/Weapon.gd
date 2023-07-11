extends Node2D

var weapon_types = ["Gun", "Shotgun", "Sniper", "SMG"] #YOOOOO if we want to make the player have only one at the start, we remove all but one, then as flags get completed we use push_back or some shit
var current_weapon_index = 0
var weapon_type := "Gun"


var _bullet_speed: float = 0
var _bullet_scene := preload("res://weapons/scenes/Bullet1.tscn")
var weapon_reload_time: float = 0.1
var bullet_alive_time: float = 0.0
var damage = 0
var rTimer_on = false

@onready var reload_timer = $WeaponReload
@onready var sprite = $Sprite2D

func _process(_delta):
	reload_timer.wait_time = weapon_reload_time

	self.look_at(self.get_global_mouse_position())

	if self.rotation_degrees > 90 or self.rotation_degrees < -90:
		sprite.flip_v = true
	else:
		sprite.flip_v = false

	if self.rotation_degrees >= 269:
		self.rotation_degrees = 90
	if self.rotation_degrees <= -269:
		self.rotation_degrees = -90

	if Input.is_action_pressed("Shoot"):
		if not rTimer_on:
			_fire(weapon_type)
			reload_timer.start()
			$muzzle.emitting = true
			rTimer_on = true
			$muzzle.restart()
	
	if Input.is_action_just_pressed("Weapon_Up"): #Switches weapons. TODO: Make another input that switches backwards and flags for picking them up
		current_weapon_index = (current_weapon_index + 1) % weapon_types.size()
		weapon_type = weapon_types[current_weapon_index]
	
	if Input.is_action_just_pressed("Weapon_Down"):
		current_weapon_index = (current_weapon_index - 1) % weapon_types.size()
		weapon_type = weapon_types[current_weapon_index]
	

	match weapon_type: #change stats of weapon depending on the weapon
		"Gun":
			sprite.texture = load("res://weapons/sprites/Pistol/pistol.png")
			sprite.scale = Vector2(0.5, 0.5)
			_bullet_speed = 1000
			bullet_alive_time = 0.5
			weapon_reload_time = 0.6
			damage = 3
		"Shotgun":
			sprite.texture = load("res://weapons/sprites/Shotgun/Shotgun.png")
			sprite.scale = Vector2(0.5, 0.5)
			_bullet_speed = 500
			bullet_alive_time = 0.25
			weapon_reload_time = 1
			damage = 3
		"Sniper":
			sprite.texture = load("res://weapons/sprites/Sniper/Sniper.png")
			sprite.scale = Vector2(0.5, 0.5)
			_bullet_speed = 2000
			bullet_alive_time = 5
			weapon_reload_time = 2.5
			damage = 10
		"SMG":
			sprite.texture = load("res://weapons/sprites/SMG/SMG.png")
			sprite.scale = Vector2(0.5, 0.5)
			_bullet_speed = 750
			bullet_alive_time = 0.3
			weapon_reload_time = 0.1
			damage = 1


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
		"SMG":
			var random_number = randf_range(-0.2, 0.2) 
			var bullet_instance := _bullet_scene.instantiate()
			bullet_instance.position = self.global_position
			bullet_instance.rotation = self.rotation + random_number
			bullet_instance.lifetime = bullet_alive_time
			bullet_instance.damage = damage

			# Calculated using math.
			var impulse := Vector2(cos(bullet_instance.rotation), sin(bullet_instance.rotation)) * _bullet_speed

			bullet_instance.apply_impulse(impulse)
			self.get_tree().get_root().add_child(bullet_instance)


func _on_weapon_reload_timeout():
	rTimer_on = false
