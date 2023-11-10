extends Node2D

const Projectile := preload("res://weapons/projectile/projectile.gd")

const SEGMENT_SCENE := preload("res://enemies/bosses/astral_lineus/segments/astral_lineus_segments.tscn")

# The direction that the boss' segments could face.
enum SegmentDirection {
	RIGHT = 0,
	LEFT = 1,
	DOWN = 2,
	UP = 3, # possibly will be unused
}

signal perform_attack_1
signal perform_attack_2
signal perform_attack_3

@export var health_component: HealthComponent

## In pixels per second.
@export var attack_1_segment_speed: float = 20 * 16
## In seconds.
@export var attack_1_segment_despawn_time: float = 20

@onready var _player: Player = SceneManager.find_player()

var _attack_1_left_positions: Array[Vector2] = []
var _attack_1_right_positions: Array[Vector2] = []

var _has_been_defeated := false

func _ready() -> void:
	self.perform_attack_1.connect(_async_on_perform_attack_1)
	self.perform_attack_2.connect(_async_on_perform_attack_2)
	self.perform_attack_3.connect(_async_on_perform_attack_3)

	self.health_component.death.connect(_on_death)

	for n in self.get_node("../AstralLineusAttack1Positions/LeftPositions").get_children():
		_attack_1_left_positions.append(n.global_position)

	for n in self.get_node("../AstralLineusAttack1Positions/RightPositions").get_children():
		_attack_1_right_positions.append(n.global_position)

	# Play music.
	SceneManager.play_background_music("res://sounds/music/Orbital Colossus/Orbital Colossus.mp3")

	self.perform_attack_1.emit()


# The boss "charges" horizontally from the sides of the map.
func _async_on_perform_attack_1() -> void:
	print_debug("TODO: In attack 1")

	await SceneManager.async_delay(1.0)

	# Copy the position arrays as to not modify the original ones.
	var attack_1_left_pos_copy := _attack_1_left_positions.duplicate() # shallow copy
	var attack_1_right_pos_copy := _attack_1_right_positions.duplicate() # shallow copy

	# Summon segments of the boss that go from left -> right or vice versa.
	while len(attack_1_right_pos_copy) > 0:
		randomize()
		attack_1_left_pos_copy.shuffle()
		attack_1_right_pos_copy.shuffle()

		var left_pos: Vector2 = attack_1_left_pos_copy.pop_back()
		var rigth_pos: Vector2 = attack_1_right_pos_copy.pop_back()

		_async_summon_segment(
			left_pos, 
			SegmentDirection.RIGHT, 
			attack_1_segment_speed, 
			attack_1_segment_despawn_time,
		)

		await SceneManager.async_delay(2.0)

		_async_summon_segment(
			rigth_pos, 
			SegmentDirection.LEFT, 
			attack_1_segment_speed, 
			attack_1_segment_despawn_time,
		)

		await SceneManager.async_delay(2.0)

	if _has_been_defeated:
		# Async call (no need to wait for the cutscene to finish).
		_async_play_defeated_cutscene()
		return

	self.perform_attack_2.emit()


# The boss fires projectiles that explode into other projectiles,
# from the top of the map.
func _async_on_perform_attack_2() -> void:
	print_debug("TODO: In attack 2")

	await SceneManager.async_delay(1.0)

	if _has_been_defeated:
		# Async call (no need to wait for the cutscene to finish).
		_async_play_defeated_cutscene()
		return

	self.perform_attack_3.emit()


# The boss fires vertical lasers, from the top of the map.
func _async_on_perform_attack_3() -> void:
	print_debug("TODO: In attack 3")

	await SceneManager.async_delay(1.0)

	if _has_been_defeated:
		# Async call (no need to wait for the cutscene to finish).
		_async_play_defeated_cutscene()
		return

	self.perform_attack_1.emit()


func _on_death() -> void:
	_has_been_defeated = true


func _async_play_defeated_cutscene() -> void:
	print_debug("TODO: The boss has been defeated")


func _on_area_entered_segment_hitbox(other_hitbox: Area2D) -> void:
	# Logic for taking projectile damage.
	if other_hitbox.is_in_group("projectile_hitbox"):
		var projectile: Projectile = other_hitbox.get_parent()

		if projectile.is_from_player():
			self.health_component.take_damage(projectile.get_damage())

			SceneManager.async_shake_camera(0.9, 0.1) # async call

			print("HP:", self.health_component.get_health())


## Summons a segment moving with the given `speed` facing the given `direction` that despawns in the given 
## `despawn_time`. When this function is awaited, it returns when the segment despawns.
func _async_summon_segment(pos: Vector2, direction: SegmentDirection, speed: float, despawn_time: float) -> void:
	var segments := SEGMENT_SCENE.instantiate()

	# Makes the boss take damage when hit on the segments.
	for segment in segments.get_children():
		var hitbox: Area2D = segment.get_node("HitboxArea")

		hitbox.area_entered.connect(_on_area_entered_segment_hitbox)
		
	# Move the segments to `pos`.
	segments.global_position = pos
	
	# Rotate the segments to match the `direction`.
	match direction:
		SegmentDirection.LEFT:
			segments.rotate(TAU * 0.5)	# 180 deg

		SegmentDirection.RIGHT:
			segments.rotate(0.0)		# 0 deg

		SegmentDirection.DOWN:
			segments.rotate(TAU * 0.25)	# 90 deg

		SegmentDirection.UP:
			segments.rotate(TAU * 0.75)	# 270 deg
	
	self.add_child(segments)

	var elapsed := 0.0
	var dt := 0.01

	# Move the segments during the time given by `despawn_time`.
	while elapsed < despawn_time:
		# Calculates the magnitude of the displacement (`speed * dt`) times the local x
		# (forward) direction of the segments (`segments.global_transform.x`).
		var displacement: Vector2 = segments.global_transform.x * speed * dt

		# Move the segments.
		segments.global_position += displacement

		elapsed += dt
		await SceneManager.async_delay(dt)

	# Despawn after the time given by `despawn_time` has passed in the while loop above.
	segments.queue_free()
	
	
