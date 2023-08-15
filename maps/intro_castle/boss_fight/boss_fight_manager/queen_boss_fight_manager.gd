extends Node2D

const QueenBoss := preload("res://enemies/bosses/queen/queen_boss.gd")

# Emitting one of these signals corresponds with starting a different "phase" of the boss.
# Phase cycle: 'Attack 1' -> 'Attack 2' -> 'Fall to ground' -> 'Attack 1' (etc.)
signal perform_attack_1
signal perform_attack_2
signal fall_to_ground

@onready var _queen_boss_scene: PackedScene = preload("res://enemies/bosses/queen/queen_boss.tscn")

var _queen_boss: QueenBoss

func _ready() -> void:
	self.get_node("../QueenBossFightLoreManager").start_boss_fight.connect(_on_start_boss_fight)
	self.perform_attack_1.connect(_async_on_perform_attack_1)
	self.perform_attack_2.connect(_async_on_perform_attack_2)
	self.fall_to_ground.connect(_async_on_fall_to_the_ground)


func _on_start_boss_fight() -> void:
	# Spawn the boss.
	_queen_boss = _queen_boss_scene.instantiate() as QueenBoss
	self.get_tree().get_root().add_child(_queen_boss)
	_queen_boss.global_position = self.get_node("BossFightSpawnPosition").global_position

	# Start performing 'Attack 1'.
	self.perform_attack_1.emit()


func _async_on_perform_attack_1() -> void:

	# Placeholder
	_queen_boss.global_position = Vector2(0, 0)
	await SceneManager.async_delay(5.0)
	
	# Perform 'Attack 2' once finished with the current phase.
	self.perform_attack_2.emit()


func _async_on_perform_attack_2() -> void:

	# Placeholder
	_queen_boss.global_position = Vector2(5 * 16, -5 * 16)
	await SceneManager.async_delay(5.0)

	# Fall to the ground once finished with the current phase.
	self.fall_to_ground.emit()


func _async_on_fall_to_the_ground() -> void:

	# Placeholder
	_queen_boss.global_position = Vector2(10 * 16, -10 * 16)
	await SceneManager.async_delay(5.0)

	# Perform 'Attack 1' once finished with the current phase.
	self.perform_attack_1.emit()

