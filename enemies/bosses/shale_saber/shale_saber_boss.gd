extends CharacterBody2D

const Projectile := preload("res://weapons/projectile/projectile.gd")

signal perform_attack_1
signal perform_attack_2
signal perform_attack_3

enum AttackState {
	NONE = 0,
	ATTACK_1 = 1,
	ATTACK_2 = 2,
	ATTACK_3 = 3,
}

@export var health_component: HealthComponent

@export var _attack_1_melee_damage: int = 1
@export var _attack_1_duration_secs := 1.0
@export var _attack_1_projectile_speed := 8 * 16

@export var _attack_2_projectile_amount: int = 30
@export var _attack_2_projectile_speed := 20 * 16

## The radius away from the boss from which the player is safe from attack 3.
@export var _attack_3_safety_radius: float = 6 * 16

## In seconds.
@export var _attack_3_duration: float = 4.0

@export var _sword_projectile_sprite_frames: SpriteFrames

@onready var _hitbox: Area2D = self.get_node("HitboxArea")

@onready var _sword_with_hitbox: Node2D = self.get_node("ShaleSword")

@onready var _attack_3_snow_particles: GPUParticles2D = self.get_node("ShaleSaberSnowParticles")

var _current_attack_state := AttackState.NONE

var _has_been_defeated := false

func _ready() -> void:
	# Connect the necessary signals.
	_hitbox.area_entered.connect(_on_area_entered_hitbox)
	self.health_component.death.connect(_on_death)

	self.perform_attack_1.connect(_async_on_perform_attack_1)
	self.perform_attack_2.connect(_async_on_perform_attack_2)
	self.perform_attack_3.connect(_async_on_perform_attack_3)

	# Setup the boss health bar.
	SceneManager.find_boss_health_bar().initialize(
		self.health_component,
		"Shale Saber",
	)

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
	_current_attack_state = AttackState.ATTACK_1
	await SceneManager.async_delay(2.0)

	var dt := 0.01

	var attack_radius := 3 * 16

	var elapsed_t := 0.0

	# This code spins the sword around the boss for the duration 
	# given by `_attack_1_duration_secs`, and summons a few projectiles.
	while elapsed_t <= _attack_1_duration_secs:
		# Calculate the angle (in radians).
		var angle := lerpf(0, 3*TAU, elapsed_t / _attack_1_duration_secs)

		# Calculate the sword's position.
		var sword_pos := self.global_position \
			+ (Vector2.UP * attack_radius * sin(angle)) \
			+ (Vector2.RIGHT * attack_radius * cos(angle))

		# Calculate the direction the sword should face.
		var direction := self.global_position.direction_to(sword_pos)

		# Set the calculated values.
		_sword_with_hitbox.global_position = sword_pos
		_sword_with_hitbox.rotation = direction.angle()

		# Spawn projectiles ocasionally.
		if (floori(rad_to_deg(angle)) % 3 == 0):
			Projectile.start_building() \
				.with_global_pos(sword_pos) \
				.with_impulse(direction * _attack_1_projectile_speed) \
				.from_source(Projectile.Source.SHALE_SABER_BOSS) \
				.with_damage(1) \
				.add_to_scene()

		# This code is used to simulate the passage of time.
		elapsed_t += dt
		await SceneManager.async_delay(dt)

	if _has_been_defeated:
		# Async call (no need to wait for the cutscene to finish).
		_async_play_defeated_cutscene()
		return

	self.perform_attack_2.emit()


func _async_on_perform_attack_2() -> void:
	print_debug("TODO: In attack 2")
	_current_attack_state = AttackState.ATTACK_2
	await SceneManager.async_delay(2.0)

	# Lock onto a previous player position.
	var player_lock_on_pos: Vector2 = SceneManager.find_player().global_position

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

		# Spawn the projectile.
		Projectile.start_building() \
			.with_global_pos(proj_spawn_pos) \
			.with_impulse(direction * _attack_2_projectile_speed) \
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
	_current_attack_state = AttackState.ATTACK_3
	await SceneManager.async_delay(2.0)

	_attack_3_snow_particles.emitting = true

	var elapsed := 0.0
	# Indirectly controls how fast the player takes damage.
	var dt := 0.3

	while elapsed < _attack_3_duration:
		var dist := self.global_position.distance_to(SceneManager.find_player().global_position)

		if dist > _attack_3_safety_radius:
			# Placeholder effect.
			SceneManager.find_player().health_component.take_damage(1)

		elapsed += dt
		await SceneManager.async_delay(dt)

	_attack_3_snow_particles.emitting = false

	await SceneManager.async_delay(1.0)

	if _has_been_defeated:
		# Async call (no need to wait for the cutscene to finish).
		_async_play_defeated_cutscene()
		return

	self.perform_attack_1.emit()


func _async_play_defeated_cutscene() -> void:
	print_debug("Boss has been defeated")
	_current_attack_state = AttackState.NONE


func get_melee_attack_damage() -> int:
	return _attack_1_melee_damage



