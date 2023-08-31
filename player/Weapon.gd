extends Node2D

const Projectile := preload("res://weapons/projectile/projectile.gd")

enum WeaponType {
	GUN = 0,
	SHOTGUN = 1,
	SNIPER = 2,
	SMG = 3,
}

const WEAPONS_DATA_PATH = "res://weapons/weapon_data"

@onready var _reload_timer = $WeaponReload
@onready var _weapon_sprite = $Sprite2D
@onready var _gun_shot_sfx_player: AudioStreamPlayer2D = self.get_node("GunShotPlayer")

# Determines whether the weapon can be used.
var _is_usable: bool = true

# A hash set that says what weapons the player can use.
# By default, the player can only use the regular gun (it's added in `_ready()`).
# But the player can gain more weapons by picking them up from the ground.
var _usable_weapons_set := {}

var _current_weapons_list: Array = []
var _current_weapon_type := WeaponType.GUN
var _is_reload_timer_on := false

# These fields should not be exported; these are set depending on the current weapon.
var _bullet_speed: float = 0
var _bullet_scene := preload("res://weapons/projectile/projectile.tscn")
var _weapon_reload_time: float = 0.1
var _bullet_alive_time: float = 0.0
var _bullet_damage: int = 0

func _ready() -> void:
	# Make sure the weapons list isn't empty.
	_add_weapon_type(WeaponType.GUN)


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
		if not _is_usable:
			return

		if not _is_reload_timer_on:
			_fire()
			_reload_timer.start()
			$muzzle.emitting = true
			_is_reload_timer_on = true
			$muzzle.restart()

	# Controls for selecting weapons.
	_manage_weapon_selection()


func _on_weapon_reload_timeout() -> void:
	_is_reload_timer_on = false


## Lets the player use the scroll wheel to change between the their usable weapons.
func _manage_weapon_selection() -> void:
	var current_weapon_index: int

	if Input.is_action_just_pressed("Weapon_Up"):
		current_weapon_index = (current_weapon_index + 1) % _current_weapons_list.size()
	
	if Input.is_action_just_pressed("Weapon_Down"):
		current_weapon_index = (current_weapon_index - 1) % _current_weapons_list.size()
	
	_current_weapon_type = _current_weapons_list[current_weapon_index]

	_change_stats_based_on_current_weapon(_current_weapon_type)


func _add_weapon_type(weapon_type: WeaponType) -> void:
	# Since GDScript doesn't have hash sets, this variable 
	# is technically a `Dictionary` with dummy values (i.e. null).
	_usable_weapons_set[weapon_type] = null

	# Update the weapons list since a new weapon might have been added.
	_adjust_weapons_list_using_usable_weapons_set()


# Called automatically by `_add_weapon_type`.
func _adjust_weapons_list_using_usable_weapons_set() -> void:
	# Reset the current weapons list since it will be adjusted.
	_current_weapons_list = []

	# Add the keys from the `_usable_weapons_set` (the actual values) to the weapons list.
	for weapon_type in _usable_weapons_set.keys():
		_current_weapons_list.push_back(weapon_type)


func _change_stats_based_on_current_weapon(weapon_type: int) -> void:
	# Load weapon data from JSON file based on weapon_type.
	var weapon_data = load_weapon_data(weapon_type)

	# Change weapon stats based on the loaded data.
	_weapon_sprite.texture = load(weapon_data["sprite_path"])

	_weapon_sprite.scale = Vector2(weapon_data["scale"][0], weapon_data["scale"][1])

	_bullet_speed = weapon_data["bullet_speed"]

	_bullet_alive_time = weapon_data["bullet_alive_time"]

	_weapon_reload_time = weapon_data["weapon_reload_time"]

	_bullet_damage = weapon_data["bullet_damage"]


func enable_weapon() -> void:
	_is_usable = true


func disable_weapon() -> void:
	_is_usable = false


func load_weapon_data(weapon_type: int) -> Dictionary:
	var weapon_file_path = WEAPONS_DATA_PATH + "/" + get_weapon_filename(weapon_type)
	var weapon_data = {}	

	if FileAccess.file_exists(weapon_file_path):
		var dataFile = FileAccess.open(weapon_file_path, FileAccess.READ)
		var parsedResults = JSON.parse_string(dataFile.get_as_text())
		
		if parsedResults is Dictionary:
			return parsedResults
		else:
			print("Bro tf you do, why is it giving me an error?")
			return {}
	else:
		print("Schizophrenic or something? This crap doesn't exist.")
		print(weapon_file_path)
		return {}


func get_weapon_filename(weapon_type: int) -> String:
	match weapon_type:
		WeaponType.GUN:
			return "gun.json"
		WeaponType.SHOTGUN:
			return "shotgun.json"
		WeaponType.SNIPER:
			return "sniper.json"
		WeaponType.SMG:
			return "smg.json"
		_:
			return "gun.json" # Default weapon data for unknown types.
	

# Maybe change parameters for different `_bullet_scene` types?
# TODO: Add more weapons.
func _fire() -> void:
	match _current_weapon_type:
		WeaponType.GUN:
			var bullet_instance := _bullet_scene.instantiate() as Projectile

			var bullet_rotation := self.rotation

			bullet_instance.initialize(
				self.global_position,
				bullet_rotation,
				_bullet_alive_time,
				_bullet_damage,
				Projectile.Source.PLAYER,
				# Calculated using math.
				Vector2(cos(bullet_rotation), sin(bullet_rotation)) * _bullet_speed
			)

			self.get_tree().get_root().add_child(bullet_instance)

		WeaponType.SHOTGUN:
			for i in range(3):
				var bullet_instance := _bullet_scene.instantiate() as Projectile

				var bullet_rotation := self.rotation + (i - 1) * 0.1

				bullet_instance.initialize(
					self.global_position,
					bullet_rotation,
					_bullet_alive_time,
					_bullet_damage,
					Projectile.Source.PLAYER,
					# Not calculated using math, calculated using MATHS #unitedkingdom
					Vector2(cos(bullet_rotation), sin(bullet_rotation)) * _bullet_speed
				)
		
				self.get_tree().get_root().add_child(bullet_instance)	

		WeaponType.SNIPER:
			var bullet_instance := _bullet_scene.instantiate() as Projectile

			var bullet_rotation := self.rotation

			bullet_instance.initialize(
				self.global_position,
				bullet_rotation,
				_bullet_alive_time,
				_bullet_damage,
				Projectile.Source.PLAYER,
				# Calculated using math.
				Vector2(cos(bullet_rotation), sin(bullet_rotation)) * _bullet_speed,
			)

			self.get_tree().get_root().add_child(bullet_instance)

		WeaponType.SMG:
			var bullet_instance := _bullet_scene.instantiate()

			var bullet_rotation := self.rotation + randf_range(-0.2, 0.2)

			bullet_instance.initialize(
				self.global_position,
				bullet_rotation,
				_bullet_alive_time,
				_bullet_damage,
				Projectile.Source.PLAYER,
				# Calculated using math.
				Vector2(cos(bullet_rotation), sin(bullet_rotation)) * _bullet_speed
			)

			self.get_tree().get_root().add_child(bullet_instance)

		# Do nothing if there is an unknown weapon.
		_:
			pass

	# TODO: Add different shooting sounds for different weapons.
	_gun_shot_sfx_player.play()

