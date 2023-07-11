extends Node2D

enum WeaponType {
	GUN = 0,
	SHOTGUN = 1,
	SNIPER = 2,
	SMG = 3,
}

@onready var _reload_timer = $WeaponReload
@onready var _weapon_sprite = $Sprite2D

var _weapon_types: Array = WeaponType.values() # YOOOOO if we want to make the player have only one at the start, we remove all but one, then as flags get completed we use push_back or some shit ('_'): what do you mean by this
var _current_weapon_index: int = 0
var _current_weapon_type := WeaponType.GUN
var _is_reload_timer_on := false

# These fields should not be exported; these are set depending on the current weapon.
var _bullet_speed: float = 0
var _bullet_scene := preload("res://weapons/scenes/Bullet1.tscn")
var _weapon_reload_time: float = 0.1
var _bullet_alive_time: float = 0.0
var _bullet_damage: int = 0

func _process(_delta) -> void:
	_reload_timer.wait_time = _weapon_reload_time

	self.look_at(self.get_global_mouse_position())

	if self.rotation_degrees > 90 or self.rotation_degrees < -90:
		_weapon_sprite.flip_v = true
	else:
		_weapon_sprite.flip_v = false

	if self.rotation_degrees >= 269:
		self.rotation_degrees = 90
	if self.rotation_degrees <= -269:
		self.rotation_degrees = -90

	if Input.is_action_pressed("Shoot"):
		if not _is_reload_timer_on:
			_fire()
			_reload_timer.start()
			$muzzle.emitting = true
			_is_reload_timer_on = true
			$muzzle.restart()
			
	if Input.is_action_just_pressed("Weapon_Up"): #Switches weapons. TODO: flags for picking them up
		_current_weapon_index = (_current_weapon_index + 1) % _weapon_types.size()
		_current_weapon_type = _weapon_types[_current_weapon_index]
	
	if Input.is_action_just_pressed("Weapon_Down"):
		_current_weapon_index = (_current_weapon_index - 1) % _weapon_types.size()
		_current_weapon_type = _weapon_types[_current_weapon_index]
	
	_change_stats_based_on_current_weapon()


func _on_weapon_reload_timeout() -> void:
	_is_reload_timer_on = false


func _change_stats_based_on_current_weapon() -> void:
	match _current_weapon_type: #change stats of weapon depending on the weapon
		WeaponType.GUN:
			_weapon_sprite.texture = load("res://weapons/sprites/Pistol/pistol.png")
			_weapon_sprite.scale = Vector2(0.5, 0.5)
			_bullet_speed = 1000
			_bullet_alive_time = 0.5
			_weapon_reload_time = 0.6
			_bullet_damage = 3

		WeaponType.SHOTGUN:
			_weapon_sprite.texture = load("res://weapons/sprites/Shotgun/Shotgun.png")
			_weapon_sprite.scale = Vector2(0.5, 0.5)
			_bullet_speed = 500
			_bullet_alive_time = 0.25
			_weapon_reload_time = 1
			_bullet_damage = 3

		WeaponType.SNIPER:
			_weapon_sprite.texture = load("res://weapons/sprites/Sniper/Sniper.png")
			_weapon_sprite.scale = Vector2(0.5, 0.5)
			_bullet_speed = 2000
			_bullet_alive_time = 5
			_weapon_reload_time = 2.5
			_bullet_damage = 10

		WeaponType.SMG:
			_weapon_sprite.texture = load("res://weapons/sprites/SMG/SMG.png")
			_weapon_sprite.scale = Vector2(0.5, 0.5)
			_bullet_speed = 750
			_bullet_alive_time = 0.3
			_weapon_reload_time = 0.1
			_bullet_damage = 1

		# Unknown weapon; use same stats as a regular gun.
		_:
			_weapon_sprite.texture = load("res://weapons/sprites/Pistol/pistol.png")
			_weapon_sprite.scale = Vector2(0.5, 0.5)
			_bullet_speed = 1000
			_bullet_alive_time = 0.5
			_weapon_reload_time = 0.6
			_bullet_damage = 3


# Maybe change parameters for different `_bullet_scene` types?
# TODO: Add more weapons.
func _fire() -> void: 
	match _current_weapon_type:
		WeaponType.GUN:
			var bullet_instance := _bullet_scene.instantiate()
			bullet_instance.position = self.global_position
			bullet_instance.rotation = self.rotation
			bullet_instance.lifetime = _bullet_alive_time
			bullet_instance.damage = _bullet_damage

			# Calculated using math.
			var impulse := Vector2(cos(self.rotation), sin(self.rotation)) * _bullet_speed

			bullet_instance.apply_impulse(impulse)
			self.get_tree().get_root().add_child(bullet_instance)

		WeaponType.SHOTGUN:
			for i in range(3):
				var bullet_instance = _bullet_scene.instantiate()
				bullet_instance.position = self.global_position
				bullet_instance.rotation = self.rotation + (i - 1) * 0.1
				bullet_instance.lifetime = _bullet_alive_time
				bullet_instance.damage = _bullet_damage

				# Not calculated using math, calculated using MATHS #unitedkingdom
				var impulse = Vector2(cos(bullet_instance.rotation), sin(bullet_instance.rotation)) * _bullet_speed
				bullet_instance.apply_impulse(impulse)
		
				self.get_tree().get_root().add_child(bullet_instance)	

		WeaponType.SNIPER:
			var bullet_instance := _bullet_scene.instantiate()
			bullet_instance.position = self.global_position
			bullet_instance.rotation = self.rotation
			bullet_instance.lifetime = _bullet_alive_time
			bullet_instance.damage = _bullet_damage

			# Calculated using math.
			var impulse := Vector2(cos(self.rotation), sin(self.rotation)) * _bullet_speed

			bullet_instance.apply_impulse(impulse)
			self.get_tree().get_root().add_child(bullet_instance)

		WeaponType.SMG:
			var random_number = randf_range(-0.2, 0.2) 
			var bullet_instance := _bullet_scene.instantiate()
			bullet_instance.position = self.global_position
			bullet_instance.rotation = self.rotation + random_number
			bullet_instance.lifetime = _bullet_alive_time
			bullet_instance.damage = _bullet_damage

			# Calculated using math.
			var impulse := Vector2(cos(bullet_instance.rotation), sin(bullet_instance.rotation)) * _bullet_speed

			bullet_instance.apply_impulse(impulse)
			self.get_tree().get_root().add_child(bullet_instance)

		# Do nothing if there is an unknown weapon.
		_:
			pass

