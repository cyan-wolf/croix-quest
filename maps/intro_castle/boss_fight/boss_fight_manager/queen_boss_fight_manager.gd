extends Node2D

const QueenBoss := preload("res://enemies/bosses/queen/queen_boss.gd")
const Projectile := preload("res://weapons/projectile/projectile.gd")

# Emitting one of these signals corresponds with starting a different "phase" of the boss.
# Phase cycle: 'Attack 1' -> 'Attack 2' -> 'Fall to ground' -> 'Attack 1' (etc.)
signal perform_attack_1
signal perform_attack_2
signal fall_to_ground

@export var _queen_defeated_dialog: DialogResource

@onready var _player: Player = SceneManager.find_player()
@onready var _queen_boss_scene: PackedScene = preload("res://enemies/bosses/queen/queen_boss.tscn")
@onready var _projectile_scene := preload("res://weapons/projectile/projectile.tscn")
@onready var _attack_1_teleport_positions: Array[Vector2]
# Stores position and rotation in order to know in which direction to shoot the projectiles.
@onready var _attack_2_projectile_pos_and_rot_left: Array[Node2D]
@onready var _attack_2_projectile_pos_and_rot_right: Array[Node2D]

@onready var _queen_teleport_particle_emitter: GPUParticles2D = self.get_node("queen_boss_teleport_particles")
@onready var _queen_shield_particle_emitter: GPUParticles2D = self.get_node("queen_shield_particles")
@onready var _queen_laser: Node2D = self.get_node("QueenLaser")
@onready var _boss_theme_player: AudioStreamPlayer = self.get_node("BossThemePlayer")

var _queen_boss: QueenBoss
var _queen_has_been_defeated := false

func _ready() -> void:
	self.get_node("../QueenBossFightLoreManager").start_boss_fight.connect(_on_start_boss_fight)
	self.perform_attack_1.connect(_async_on_perform_attack_1)
	self.perform_attack_2.connect(_async_on_perform_attack_2)
	self.fall_to_ground.connect(_async_on_fall_to_the_ground)

	for n in self.get_node("Attack1TeleportPositions").get_children():
		_attack_1_teleport_positions.push_back((n as Node2D).global_position)

	for n in self.get_node("Attack2ProjectilePositions/LeftPositions").get_children():
		_attack_2_projectile_pos_and_rot_left.push_back(n)

	for n in self.get_node("Attack2ProjectilePositions/RightPositions").get_children():
		_attack_2_projectile_pos_and_rot_right.push_back(n)


func _on_start_boss_fight() -> void:
	_boss_theme_player.play()

	# Spawn the boss.
	_queen_boss = _queen_boss_scene.instantiate() as QueenBoss

	self.get_tree().current_scene.add_child(_queen_boss)
	_queen_boss.global_position = self.get_node("BossFightSpawnPosition").global_position

	# Further setup the boss fight manager now that the Queen has been spawned.
	_queen_boss.health_component.death.connect(_async_on_queen_defeat)
	_queen_boss.set_animation("float")

	# Start performing 'Attack 1'.
	self.perform_attack_1.emit()


func _async_on_perform_attack_1() -> void:
	var attack_pos_amount := len(_attack_1_teleport_positions)

	var teleport_positions := Util.choose_random_elements_from_array(
		_attack_1_teleport_positions, attack_pos_amount) as Array[Vector2]

	for teleport_pos in teleport_positions:
		await _async_teleport_queen(teleport_pos)

		# Async call.
		_queen_boss.async_play_animation("attack", 1.5, "float")
		await SceneManager.async_delay(1.0)

		_fire_projectile_from_queen_towards_player()
		await SceneManager.async_delay(0.5)
	
	if _queen_has_been_defeated:
		# Async call (no need to wait for the cutscene to finish).
		_async_play_queen_defeated_cutscene()
		return

	# Perform 'Attack 2' once finished with the current phase.
	self.perform_attack_2.emit()


func _async_on_perform_attack_2() -> void:
	var attack_2_teleport_pos: Vector2 = (self.get_node("Attack2TeleportPosition") as Node2D).global_position

	await _async_teleport_queen(attack_2_teleport_pos)

	# Enable shield particles.
	_queen_shield_particle_emitter.global_position = _queen_boss.global_position
	_queen_shield_particle_emitter.emitting = true

	# Enable shield collision.
	_queen_boss.enable_shield()

	await SceneManager.async_delay(1.5)
	# Async call.
	_queen_boss.async_play_animation("attack", 1.5, "float")

	for pos_and_rot in _attack_2_projectile_pos_and_rot_left:

		_fire_projectile_in_game_world(
			pos_and_rot.global_position,
			Vector2.from_angle(pos_and_rot.rotation),
		)

	await SceneManager.async_delay(1.5)
	# Async call.
	_queen_boss.async_play_animation("attack", 1.5, "float")

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
	_queen_boss.disable_shield()

	if _queen_has_been_defeated:
		# Async call (no need to wait for the cutscene to finish).
		_async_play_queen_defeated_cutscene()
		return

	# Fall to the ground once finished with the current phase.
	self.fall_to_ground.emit()


func _async_on_fall_to_the_ground() -> void:
	var landing_pos: Vector2 = self.get_node("FallToGroundLandingPosition").global_position

	await self.create_tween().tween_property(_queen_boss, "global_position", landing_pos, 0.5).finished

	await SceneManager.async_delay(5.0)

	if _queen_has_been_defeated:
		# Async call (no need to wait for the cutscene to finish).
		_async_play_queen_defeated_cutscene()
		return

	# Perform 'Attack 1' once finished with the current phase.
	self.perform_attack_1.emit()


func _async_on_queen_defeat() -> void:
	_queen_has_been_defeated = true


# TODO: Finish this part by making the Queen heal herself and 
# defeating you instead.
func _async_play_queen_defeated_cutscene() -> void:
	
	var defeat_pos: Vector2 = self.get_node("FallToGroundLandingPosition").global_position

	await _async_teleport_queen(defeat_pos)

	# TODO: Replace with a "defeated" animation.
	_queen_boss.set_animation("idle")

	DialogManager.start_dialog(_queen_defeated_dialog)
	await DialogManager.ended_dialog

	SceneManager.add_world_state(Util.WorldState.CUTSCENE_PLAYING)

	await SceneManager.async_delay(1.0)

	_queen_laser.global_position = _player.global_position
	_queen_laser.show()

	# TODO: Play some SFX here and some sort of on-screen effect.

	await SceneManager.async_delay(0.3)

	SceneManager.remove_world_state(Util.WorldState.CUTSCENE_PLAYING)

	# Continue the story by going to the forest outside the castle.
	SceneManager.load_scene_file(
		"res://maps/intro_area_outside_castle/forest_outside_castle/forest_outisde_castle.tscn"
	)


func _async_teleport_queen(to_position: Vector2) -> void:
	# TODO: Play some SFX here. 

	_queen_boss.hide()

	var queen_previous_position := _queen_boss.global_position
	_queen_boss.global_position = to_position

	# Show the particles at the Queen's previous position.
	_queen_teleport_particle_emitter.global_position = queen_previous_position
	_queen_teleport_particle_emitter.emitting = true

	await SceneManager.async_delay(_queen_teleport_particle_emitter.lifetime)

	_queen_teleport_particle_emitter.global_position = _queen_boss.global_position

	# Show the particles at the Queen's new position.
	_queen_teleport_particle_emitter.emitting = true

	await SceneManager.async_delay(_queen_teleport_particle_emitter.lifetime)

	_queen_boss.show()


func _fire_projectile_from_queen_towards_player() -> void:
	_fire_projectile_in_game_world(
		_queen_boss.global_position, 
		_queen_boss.global_position.direction_to(_player.global_position),
	)


func _fire_projectile_in_game_world(pos: Vector2, direction: Vector2) -> void:
	var projectile_speed := 120.0 # speed in pixels per second

	Projectile.start_building() \
		.with_global_pos(pos) \
		.with_impulse(direction * projectile_speed) \
		.from_source(Projectile.Source.QUEEN_BOSS) \
		.with_damage(1) \
		.add_to_scene()

