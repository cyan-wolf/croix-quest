extends CharacterBody2D

# Emitting one of these signals corresponds with starting a different "phase" of the boss.
# Phase cycle: 'Attack 1' -> 'Attack 2' -> 'Fall to ground' -> 'Attack 1' (etc.)
signal perform_attack_1
signal perform_attack_2
signal fall_to_ground

signal teleport

const BossFightManager := preload("res://maps/intro_castle/boss_fight/boss_fight_manager/queen_boss_fight_manager.gd")

@onready var _boss_fight_manager: BossFightManager = self.get_node("../QueenBossFightManager")

@export var health_component: HealthComponent

@onready var _hitbox: Area2D = self.get_node("HitboxArea")
@onready var _queen_sprite: AnimatedSprite2D = self.get_node("QueenCroixNPCSprite")

@onready var _queen_teleport_particle_emitter: GPUParticles2D = _boss_fight_manager.get_node("queen_boss_teleport_particles")
@onready var _queen_shield_particle_emitter: GPUParticles2D = _boss_fight_manager.get_node("queen_shield_particles")

@onready var _player: Player = SceneManager.find_player()

@onready var _attack_1_teleport_positions: Array[Vector2]
# Stores position and rotation in order to know in which direction to shoot the projectiles.
@onready var _attack_2_projectile_pos_and_rot_left: Array[Node2D]
@onready var _attack_2_projectile_pos_and_rot_right: Array[Node2D]

var _should_take_damage := true

func _ready() -> void:
	_hitbox.area_entered.connect(_on_area_entered_hitbox)

	self.perform_attack_1.connect(_async_on_perform_attack_1)
	self.perform_attack_2.connect(_async_on_perform_attack_2)
	self.fall_to_ground.connect(_async_on_fall_to_the_ground)

	for n in _boss_fight_manager.get_node("Attack1TeleportPositions").get_children():
		_attack_1_teleport_positions.push_back((n as Node2D).global_position)

	for n in _boss_fight_manager.get_node("Attack2ProjectilePositions/LeftPositions").get_children():
		_attack_2_projectile_pos_and_rot_left.push_back(n)

	for n in _boss_fight_manager.get_node("Attack2ProjectilePositions/RightPositions").get_children():
		_attack_2_projectile_pos_and_rot_right.push_back(n)

	await SceneManager.async_delay(0.5)

	# Start performing 'Attack 1'.
	self.perform_attack_1.emit()


func _process(_delta: float) -> void:
	# Make the Queen's sprite always face the player.
	if _player.global_position.x < self.global_position.x:
		_queen_sprite.flip_h = true
	else:
		_queen_sprite.flip_h = false


func _on_area_entered_hitbox(other_hitbox: Area2D) -> void:
	if other_hitbox.is_in_group("projectile_hitbox"):
		var projectile: Projectile = other_hitbox.get_parent()

		if projectile.is_from_player() and _should_take_damage:
			self.health_component.take_damage(projectile.get_damage())


func _async_on_perform_attack_1() -> void:
	var attack_pos_amount := len(_attack_1_teleport_positions)

	var teleport_positions := Util.choose_random_elements_from_array(
		_attack_1_teleport_positions, attack_pos_amount) as Array[Vector2]

	for teleport_pos in teleport_positions:
		await self.async_teleport_queen(teleport_pos)

		# Async call.
		self.async_play_animation("attack", 1.5, "float")
		await SceneManager.async_delay(1.0)

		_fire_projectile_from_queen_towards_player()
		await SceneManager.async_delay(0.5)

	# Perform 'Attack 2' once finished with the current phase.
	self.perform_attack_2.emit()


func _async_on_perform_attack_2() -> void:
	var attack_2_teleport_pos: Vector2 = _boss_fight_manager \
		.get_node("Attack2TeleportPosition") \
		.global_position

	await self.async_teleport_queen(attack_2_teleport_pos)

	# Enable shield particles.
	_queen_shield_particle_emitter.global_position = self.global_position
	_queen_shield_particle_emitter.emitting = true

	# Enable shield collision.
	self.enable_shield()

	await SceneManager.async_delay(1.5)
	# Async call.
	self.async_play_animation("attack", 1.5, "float")

	for pos_and_rot in _attack_2_projectile_pos_and_rot_left:

		_fire_projectile_in_game_world(
			pos_and_rot.global_position,
			Vector2.from_angle(pos_and_rot.rotation),
		)

	await SceneManager.async_delay(1.5)
	# Async call.
	self.async_play_animation("attack", 1.5, "float")

	for pos_and_rot in _attack_2_projectile_pos_and_rot_right:
		_fire_projectile_in_game_world(
			pos_and_rot.global_position,
			Vector2.from_angle(pos_and_rot.rotation),
		)

	await SceneManager.async_delay(1.5)

	# Disables shield particles.
	_queen_shield_particle_emitter.emitting = false

	await SceneManager.async_delay(1.0)

	# Disables shield collision.
	self.disable_shield()

	# Fall to the ground once finished with the current phase.
	self.fall_to_ground.emit()


func _async_on_fall_to_the_ground() -> void:
	var landing_pos: Vector2 = _boss_fight_manager \
		.get_node("FallToGroundLandingPosition") \
		.global_position

	await self.create_tween().tween_property(self, "global_position", landing_pos, 0.5).finished

	await SceneManager.async_delay(5.0)

	# Perform 'Attack 1' once finished with the current phase.
	self.perform_attack_1.emit()


## Only enables the shield's collision, the particles are handled by the boss fight manager.
func enable_shield() -> void:
	_should_take_damage = false


## Only disables the shield's collision, the particles are handled by the boss fight manager.
func disable_shield() -> void:
	_should_take_damage = true


## Plays `animation_name` for the specified `duration`.
## Once finished, the animation given by `fallback_animation` starts playing.
func async_play_animation(
		animation_name: StringName, 
		duration_in_secs: float, 
		fallback_animation: StringName = &"idle") -> void:
	_queen_sprite.play(animation_name)

	await SceneManager.async_delay(duration_in_secs)

	_queen_sprite.play(fallback_animation)


func set_animation(animation_name: StringName) -> void:
	_queen_sprite.play(animation_name)


func _fire_projectile_from_queen_towards_player() -> void:
	_fire_projectile_in_game_world(
		self.global_position, 
		self.global_position.direction_to(_player.global_position),
	)


func _fire_projectile_in_game_world(pos: Vector2, direction: Vector2) -> void:
	var projectile_speed := 120.0 # speed in pixels per second

	Projectile.start_building() \
		.with_global_pos(pos) \
		.with_impulse(direction * projectile_speed) \
		.from_source(Projectile.Source.QUEEN_BOSS) \
		.with_damage(1) \
		.add_to_scene()


# This method needs to be on this script, since otherwise the game will crash 
# when the Queen boss is freed in the middle of teleporting.
func async_teleport_queen(to_position: Vector2) -> void:
	var queen_to_move: Node2D = self

	queen_to_move.hide()

	var queen_previous_position: Vector2 = queen_to_move.global_position
	queen_to_move.global_position = to_position

	# Show the particles at the Queen's previous position.
	_queen_teleport_particle_emitter.global_position = queen_previous_position
	_queen_teleport_particle_emitter.emitting = true

	await SceneManager.async_delay(_queen_teleport_particle_emitter.lifetime)

	_queen_teleport_particle_emitter.global_position = queen_to_move.global_position

	# Show the particles at the Queen's new position.
	_queen_teleport_particle_emitter.emitting = true

	await SceneManager.async_delay(_queen_teleport_particle_emitter.lifetime)

	queen_to_move.show()

