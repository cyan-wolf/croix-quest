extends CharacterBody2D

const Projectile := preload("res://weapons/projectile/projectile.gd")

signal perform_attack_1
signal perform_attack_2
signal perform_attack_3

@export var health_component: HealthComponent

@export var _attack_2_projectile_amount: int = 30

@export var _sword_projectile_sprite_frames: SpriteFrames

@onready var _hitbox: Area2D = self.get_node("HitboxArea")

@onready var _player: Player = SceneManager.find_player()

var _has_been_defeated := false

func _ready() -> void:
	# Connect the necessary signals.
	_hitbox.area_entered.connect(_on_area_entered_hitbox)
	self.health_component.death.connect(_on_death)

	self.perform_attack_1.connect(_async_on_perform_attack_1)
	self.perform_attack_2.connect(_async_on_perform_attack_2)
	self.perform_attack_3.connect(_async_on_perform_attack_3)

	# Play music.
	SceneManager.play_background_music("res://sounds/music/Orbital Colossus/Orbital Colossus.mp3")

	# Start the cycle of attacks.
	self.perform_attack_1.emit()


func _on_area_entered_hitbox(other_hitbox: Area2D) -> void:
	# Logic for taking projectile damage.
	if other_hitbox.is_in_group("projectile_hitbox"):
		var projectile: Projectile = other_hitbox.get_parent()

		if projectile.is_from_player():
			self.health_component.take_damage(projectile.get_damage())

			SceneManager.async_shake_camera(0.9, 0.1) # async call


func _on_death() -> void:
	_has_been_defeated = true


func _async_on_perform_attack_1() -> void:
	print_debug("TODO: In attack 1")
	await SceneManager.async_delay(2.0)

	if _has_been_defeated:
		# Async call (no need to wait for the cutscene to finish).
		_async_play_defeated_cutscene()
		return

	self.perform_attack_2.emit()


func _async_on_perform_attack_2() -> void:
	print_debug("TODO: In attack 2")
	await SceneManager.async_delay(2.0)

	# Lock onto a previous player position.
	var player_lock_on_pos := _player.global_position

	await SceneManager.async_delay(0.2)

	# Used to calculate how many steps to divide a full turn (360 deg) so that the required 
	# amount of projectiles are fired (given by `_attack_2_projectile_amount`).
	var steps := (360 / _attack_2_projectile_amount) - 1

	# The distance away from the locked on position from which the 
	# projectiles will spawn.
	var proj_spawn_dist := 20 * 16

	# Get the required amount of angles that cover a full turn of a circle.
	for angle in range(0, 360, steps):
		await SceneManager.async_delay(0.12)

		# Use math to get the positions of a circle of radius given by
		# `proj_spawn_dist`, centered at the locked on position.
		var proj_spawn_pos := player_lock_on_pos \
			+ (Vector2.UP * proj_spawn_dist * sin(deg_to_rad(angle))) \
			+ (Vector2.RIGHT * proj_spawn_dist * cos(deg_to_rad(angle)))

		var direction := proj_spawn_pos.direction_to(player_lock_on_pos)
		var speed := 20 * 16

		# Spawn the projectile.
		Projectile.start_building() \
			.with_global_pos(proj_spawn_pos) \
			.with_impulse(direction * speed) \
			.from_source(Projectile.Source.SHALE_SABER_BOSS) \
			.with_damage(1) \
			.can_pass_through_wall_edges(true) \
			.with_lifetime(10.0) \
			.with_sprite_frames(_sword_projectile_sprite_frames) \
			.add_to_scene()
		

	if _has_been_defeated:
		# Async call (no need to wait for the cutscene to finish).
		_async_play_defeated_cutscene()
		return

	self.perform_attack_3.emit()


func _async_on_perform_attack_3() -> void:
	print_debug("TODO: In attack 3")
	await SceneManager.async_delay(2.0)

	if _has_been_defeated:
		# Async call (no need to wait for the cutscene to finish).
		_async_play_defeated_cutscene()
		return

	self.perform_attack_1.emit()


func _async_play_defeated_cutscene() -> void:
	print_debug("Boss has been defeated")

