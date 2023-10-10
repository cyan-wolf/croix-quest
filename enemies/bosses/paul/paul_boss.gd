extends CharacterBody2D

const Projectile := preload("res://weapons/projectile/projectile.gd")

signal perform_attack_1
signal perform_attack_2
signal perform_attack_3

## The scene of the melee enemy to be summoned.
@export var _melee_enemy_scene: PackedScene

## The scene of the ranged enemy to be summoned.
@export var _shooting_enemy_scene: PackedScene

@export var health_component: HealthComponent

@export var _projectile_attack_damage: int = 1

## In pixels per second.
@export var _follow_speed: float = 3.0 * 16

@onready var _hitbox: Area2D = self.get_node("HitboxArea")

@onready var _player: Player = SceneManager.find_player()

# The enemy summon position markers need to be added manually under 
# an 'EnemySummonPositions' node.
var _enemy_summon_positions: Array[Node2D] = []

var _summoned_enemy_count := 0

var _has_been_defeated := false

var _is_following_player := false

func _ready() -> void:
	_hitbox.area_entered.connect(_on_area_entered_hitbox)

	self.perform_attack_1.connect(_async_on_perform_attack_1)
	self.perform_attack_2.connect(_async_on_perform_attack_2)
	self.perform_attack_3.connect(_async_on_perform_attack_3)

	# Add the child nodes of 'EnemySummonPositions' to `_enemy_summon_positions`.
	_enemy_summon_positions.append_array(self.get_node("../EnemySummonPositions").get_children())

	# Play music.
	SceneManager.play_background_music("res://sounds/music/Orbital Colossus/Orbital Colossus.mp3")

	self.perform_attack_1.emit()


func _physics_process(delta: float):
	if _is_following_player:
		var vel_direction := self.global_position.direction_to(_player.global_position)

		self.velocity = vel_direction * _follow_speed

	else:
		self.velocity = Vector2.ZERO

	var _col := self.move_and_collide(self.velocity * delta)


func _on_area_entered_hitbox(other_hitbox: Area2D) -> void:
	# Logic for taking projectile damage.
	if other_hitbox.is_in_group("projectile_hitbox"):
		var projectile: Projectile = other_hitbox.get_parent()

		if projectile.is_from_player():
			self.health_component.take_damage(projectile.get_damage())

			SceneManager.async_shake_camera(0.9, 0.1) # async call


# A back-and-forth attack with a large club.
func _async_on_perform_attack_1() -> void:
	print_debug("DEBUG: In attack 1")

	await SceneManager.async_delay(2.0)

	_is_following_player = true

	await SceneManager.async_delay(3.0)

	_is_following_player = false

	await SceneManager.async_delay(1.0)

	# TODO: Make the boss do a powerful melee attack here.

	await SceneManager.async_delay(1.0)

	if _has_been_defeated:
		# Async call (no need to wait for the cutscene to finish).
		_async_play_defeated_cutscene()
		return

	self.perform_attack_2.emit()


# A projectile attack.
func _async_on_perform_attack_2() -> void:
	print_debug("DEBUG: In attack 2")

	await SceneManager.async_delay(2.0)

	# The maximum angle spread of the projectiles.
	var max_angle_in_deg := 30.0

	# How many "pairs" of projectiles will be fired.
	var projectile_pair_amount := 10

	# Used to keep track the different angle spreads.
	var curr_angle_in_deg := 0.0

	while curr_angle_in_deg <= max_angle_in_deg:
		_fire_projectile(curr_angle_in_deg)

		if curr_angle_in_deg != 0.0:
			_fire_projectile(-curr_angle_in_deg)

		curr_angle_in_deg += max_angle_in_deg / projectile_pair_amount

		await SceneManager.async_delay(0.3)

	if _has_been_defeated:
		# Async call (no need to wait for the cutscene to finish).
		_async_play_defeated_cutscene()
		return

	self.perform_attack_3.emit()


# An attack that summons enemies.
func _async_on_perform_attack_3() -> void:
	print_debug("DEBUG: In attack 3")

	await SceneManager.async_delay(2.0)
	
	for i in range(len(_enemy_summon_positions)):
		# Stop spawning enemies if there are too many.
		if _summoned_enemy_count > len(_enemy_summon_positions):
			break

		var pos_marker: Node2D = _enemy_summon_positions[i]

		var enemy_to_summon: Node2D

		# Summon melee enemies for even indices.
		if i % 2 == 0:
			enemy_to_summon = _melee_enemy_scene.instantiate()

		# Summon shooting enemies for odd indices.
		else:
			enemy_to_summon = _shooting_enemy_scene.instantiate()

		# Move the enemy to the position marker.
		enemy_to_summon.global_position = pos_marker.global_position

		# Add the enemy to the scene.
		self.get_tree().current_scene.add_child(enemy_to_summon)
		_summoned_enemy_count += 1

		# Keep track of when enemies die.
		var enemy_component: EnemyComponent = enemy_to_summon.get_node("EnemyComponent")
		enemy_component.health_component.death.connect(_on_summoned_enemy_death)

	if _has_been_defeated:
		# Async call (no need to wait for the cutscene to finish).
		_async_play_defeated_cutscene()
		return

	self.perform_attack_1.emit()


func _async_play_defeated_cutscene() -> void:
	print_debug("DEBUG: The boss has been defeated")


func _fire_projectile(offset_angle_in_degrees: float) -> void:
	var projectile_scene := preload("res://weapons/projectile/projectile.tscn")
	var projectile: Projectile = projectile_scene.instantiate()

	# The projectile is fired from the boss' club (top-right corner of its sprite).
	var summon_pos := self.global_position + Vector2.UP * 32 + Vector2.RIGHT * 28

	var direction := summon_pos.direction_to(_player.global_position)
	direction = direction.rotated(deg_to_rad(offset_angle_in_degrees))

	var speed := 120.0

	projectile.initialize(
		summon_pos,
		30.0,
		_projectile_attack_damage,
		Projectile.Source.PAUL_BOSS,
		direction * speed,
	)

	self.get_tree().get_root().add_child(projectile)


func _on_summoned_enemy_death() -> void:
	_summoned_enemy_count -= 1

	print_debug(_summoned_enemy_count)
