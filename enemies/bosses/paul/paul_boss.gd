extends CharacterBody2D

signal perform_attack_1
signal perform_attack_2
signal perform_attack_3

## The scene of the melee enemy to be summoned.
@export var _melee_enemy_scene: PackedScene

## The scene of the ranged enemy to be summoned.
@export var _shooting_enemy_scene: PackedScene

# The enemy summon position markers need to be added manually under 
# an 'EnemySummonPositions' node.
var _enemy_summon_positions: Array[Node2D] = []

var _summoned_enemy_count := 0

var _has_been_defeated := false

func _ready() -> void:
	self.perform_attack_1.connect(_async_on_perform_attack_1)
	self.perform_attack_2.connect(_async_on_perform_attack_2)
	self.perform_attack_3.connect(_async_on_perform_attack_3)

	# Add the child nodes of 'EnemySummonPositions' to `_enemy_summon_positions`.
	_enemy_summon_positions.append_array(self.get_node("EnemySummonPositions").get_children())

	self.perform_attack_1.emit()

# A back-and-forth attack with a large club.
func _async_on_perform_attack_1() -> void:
	print_debug("DEBUG: In attack 1")

	await SceneManager.async_delay(2.0)

	if _has_been_defeated:
		# Async call (no need to wait for the cutscene to finish).
		_async_play_defeated_cutscene()
		return

	self.perform_attack_2.emit()


# A projectile attack.
func _async_on_perform_attack_2() -> void:
	print_debug("DEBUG: In attack 2")

	await SceneManager.async_delay(2.0)

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
	pass


func _on_summoned_enemy_death() -> void:
	_summoned_enemy_count -= 1

	print_debug(_summoned_enemy_count)
