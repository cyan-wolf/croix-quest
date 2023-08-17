extends Node2D

const QueenBoss := preload("res://enemies/bosses/queen/queen_boss.gd")

# Emitting one of these signals corresponds with starting a different "phase" of the boss.
# Phase cycle: 'Attack 1' -> 'Attack 2' -> 'Fall to ground' -> 'Attack 1' (etc.)
signal perform_attack_1
signal perform_attack_2
signal fall_to_ground

@onready var _player: Player = SceneManager.find_player()
@onready var _queen_boss_scene: PackedScene = preload("res://enemies/bosses/queen/queen_boss.tscn")
@onready var _bullet_scene := preload("res://weapons/projectile/projectile.tscn")
@onready var _attack_1_positions: Array[Vector2]

var _queen_boss: QueenBoss

func _ready() -> void:
	self.get_node("../QueenBossFightLoreManager").start_boss_fight.connect(_on_start_boss_fight)
	self.perform_attack_1.connect(_async_on_perform_attack_1)
	self.perform_attack_2.connect(_async_on_perform_attack_2)
	self.fall_to_ground.connect(_async_on_fall_to_the_ground)

	for n in self.get_node("Attack1Positions").get_children():
		_attack_1_positions.push_back((n as Node2D).global_position)


func _on_start_boss_fight() -> void:
	# Spawn the boss.
	_queen_boss = _queen_boss_scene.instantiate() as QueenBoss
	self.get_tree().get_root().add_child(_queen_boss)
	_queen_boss.global_position = self.get_node("BossFightSpawnPosition").global_position

	# Start performing 'Attack 1'.
	self.perform_attack_1.emit()


func _async_on_perform_attack_1() -> void:
	var attack_pos_amount := len(_attack_1_positions)

	var teleport_positions := Util.choose_random_elements_from_array(
		_attack_1_positions, attack_pos_amount) as Array[Vector2]

	for teleport_pos in teleport_positions:
		_teleport_queen(teleport_pos)

		_fire_bullet_from_queen_towards_player()

		await SceneManager.async_delay(5.0)
	
	# Perform 'Attack 2' once finished with the current phase.
	self.perform_attack_2.emit()


func _async_on_perform_attack_2() -> void:

	# Placeholder
	_teleport_queen(Vector2(5 * 16, -5 * 16))
	await SceneManager.async_delay(5.0)

	# Fall to the ground once finished with the current phase.
	self.fall_to_ground.emit()


func _async_on_fall_to_the_ground() -> void:

	# Placeholder
	_teleport_queen(Vector2(10 * 16, -10 * 16))
	await SceneManager.async_delay(5.0)

	# Perform 'Attack 1' once finished with the current phase.
	self.perform_attack_1.emit()


func _teleport_queen(to_position: Vector2) -> void:
	# TODO: Play a particle effect and SFX here. 
	_queen_boss.global_position = to_position


# FIXME: Make the bullet's fired by the queen not hit her.
# BUG: The reason the bullets aren't appearing is because the queen's bullets are hitting the queen.
func _fire_bullet_from_queen_towards_player() -> void:
	var bullet_instance := _bullet_scene.instantiate()

	var bullet_direction := _queen_boss.global_position.direction_to(_player.global_position)
	var bullet_speed := 2

	# Set the bullet values.
	bullet_instance.global_position = _queen_boss.global_position
	bullet_instance.rotation = bullet_direction.angle()
	bullet_instance.lifetime = 10.0
	bullet_instance.damage = 1

	# Calculated using math.
	var impulse := bullet_direction * bullet_speed

	bullet_instance.apply_impulse(impulse)
	self.get_tree().get_root().add_child(bullet_instance)

