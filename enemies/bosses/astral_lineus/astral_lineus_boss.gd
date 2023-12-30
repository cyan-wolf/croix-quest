extends Node2D

const DEFEATED_SCENE := preload("res://enemies/bosses/astral_lineus/defeated/astral_lineus_boss_defeated.tscn")

const Attack2Pod := preload("res://enemies/bosses/astral_lineus/attacks/astral_lineus_attack_2_pod.gd")

const SEGMENT_SCENE := preload("res://enemies/bosses/astral_lineus/segments/astral_lineus_segments.tscn")
const ATTACK_2_POD_SCENE := preload("res://enemies/bosses/astral_lineus/attacks/astral_lineus_attack_2_pod.tscn")
const ATTACK_3_LASER_SCENE := preload("res://enemies/bosses/astral_lineus/attacks/astral_lineus_attack_3_laser.tscn")
const ATTACK_3_INDICATOR_SCENE := preload("res://enemies/bosses/astral_lineus/attacks/astral_lineus_attack_3_indicator.tscn")

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
@export var _attack_1_segment_speed: float = 20 * 16
## In seconds.
@export var _attack_1_segment_despawn_time: float = 20

@export var _attack_1_head_segment_damage: int = 3
@export var _attack_1_body_segment_damage: int = 1
@export var _attack_1_tail_segment_damage: int = 1

@export var _attack_2_duration: float = 15.0

@export var _attack_3_laser_damage: int = 2

var _attack_1_left_positions: Array[Vector2] = []
var _attack_1_right_positions: Array[Vector2] = []

var _attack_2_pod_landing_positions: Array[Vector2] = []

var _attack_3_laser_positions: Array[Vector2] = []

func _ready() -> void:
	self.perform_attack_1.connect(_async_on_perform_attack_1)
	self.perform_attack_2.connect(_async_on_perform_attack_2)
	self.perform_attack_3.connect(_async_on_perform_attack_3)

	self.health_component.death.connect(_on_death)

	for n in self.get_node("../AstralLineusAttack1Positions/LeftPositions").get_children():
		_attack_1_left_positions.append(n.global_position)

	for n in self.get_node("../AstralLineusAttack1Positions/RightPositions").get_children():
		_attack_1_right_positions.append(n.global_position)

	for n in self.get_node("../AstralLineusAttack2Positions/Attack2PodLandingPositions").get_children():
		_attack_2_pod_landing_positions.append(n.global_position)

	for n in self.get_node("../AstralLineusAttack3Positions/Attack3LaserPositions").get_children():
		_attack_3_laser_positions.append(n.global_position)

	# Setup the boss health bar.
	SceneManager.find_boss_health_bar().initialize(
		self.health_component,
		"Astral Lineus",
	)

	# Play music.
	SceneManager.play_background_music("res://sounds/music/Orbital Colossus/Orbital Colossus.mp3")

	self.perform_attack_1.emit()


# The boss "charges" horizontally from the sides of the map.
func _async_on_perform_attack_1() -> void:
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
			_attack_1_segment_speed, 
			_attack_1_segment_despawn_time,
		)

		await SceneManager.async_delay(2.0)

		_async_summon_segment(
			rigth_pos, 
			SegmentDirection.LEFT, 
			_attack_1_segment_speed, 
			_attack_1_segment_despawn_time,
		)

		await SceneManager.async_delay(2.0)

	self.perform_attack_2.emit()


# The boss fires projectiles that explode into other projectiles,
# from the top of the map.
func _async_on_perform_attack_2() -> void:
	var segment_pos: Vector2 = self \
		.get_node("../AstralLineusAttack2Positions/Attack2FiringPositionMarker") \
		.global_position

	# This is just for visual effects.
	_async_summon_segment(
		segment_pos,
		SegmentDirection.DOWN,
		0 * 16,	# the segments should not move in this case
		_attack_2_duration * 0.75 # remove some seconds since it's taking too long to despawn for some reason,	
	)

	# Make a copy of the pod landing positions since the code below uses `.pop_back()` which 
	# mutates the list.
	var attack_2_landing_positions_copy = _attack_2_pod_landing_positions.duplicate() # shallow copy

	# Shuffle the copy of the list so that `.pop_back()` returns random elements.
	randomize()
	attack_2_landing_positions_copy.shuffle()

	while len(attack_2_landing_positions_copy) > 0:
		# Calculate how long the pod should take to land.
		var duration := _attack_2_duration / len(_attack_2_pod_landing_positions)

		var landing_pos: Vector2 = attack_2_landing_positions_copy.pop_back()
		
		# Instantiate the pod scene.
		var pod: Attack2Pod = ATTACK_2_POD_SCENE.instantiate()
		pod.global_position = segment_pos
		self.get_tree().current_scene.add_child(pod)

		# Waits for the tween to finish moving the pod to its landing position.
		await self.get_tree() \
			.create_tween() \
			.tween_property(pod, "global_position", landing_pos, duration) \
			.finished

		# Async call.
		# The pod explodes into a lot of projectiles moving in random directions.
		pod.async_explode_into_projectiles(15, 1, 6 * 16)

	await SceneManager.async_delay(1.0)

	self.perform_attack_3.emit()


# The boss fires vertical lasers, from the top of the map.
func _async_on_perform_attack_3() -> void:
	await SceneManager.async_delay(1.0)

	var _attack_3_laser_positions_copy := _attack_3_laser_positions.duplicate() # shallow copy

	randomize()
	_attack_3_laser_positions_copy.shuffle()

	# These probably should be exported.
	var indicator_duration := 0.5
	var laser_despawn_duration := 1.0
	var duration_between_lasers := 0.3

	for laser_pos in _attack_3_laser_positions_copy:
		# Show an indicator showing where the laser will "land" before actually 
		# summoning the laser.
		var indicator := ATTACK_3_INDICATOR_SCENE.instantiate()
		indicator.global_position = laser_pos
		self.add_child(indicator)

		# Remove the indicator before summoning the laser.
		await SceneManager.async_delay(indicator_duration)
		indicator.hide()
		indicator.queue_free()

		# Summon the laser.
		var laser := ATTACK_3_LASER_SCENE.instantiate()
		laser.global_position = laser_pos
		self.add_child(laser)

		# Despawn the laser asynchronously.
		var async_laser_despawner := func():
			await SceneManager.async_delay(laser_despawn_duration)
			# Check to see if the laser hasn't been freed yet.
			if is_instance_valid(laser):
				laser.queue_free()

		async_laser_despawner.call() # async call

		await SceneManager.async_delay(duration_between_lasers)

	self.perform_attack_1.emit()


func _on_death() -> void:
	self.hide()

	# Replace the boss with its defeated version, in order to 
	# show the defeat animation.
	var defeated_version := DEFEATED_SCENE.instantiate()
	defeated_version.global_position = self.global_position
	self.get_tree().current_scene.add_child(defeated_version)

	self.queue_free()


func _on_area_entered_segment_hitbox(other_hitbox: Area2D) -> void:
	# Logic for taking projectile damage.
	if other_hitbox.is_in_group("projectile_hitbox"):
		var projectile: Projectile = other_hitbox.get_parent()

		if projectile.is_from_player():
			self.health_component.take_damage(projectile.get_damage())

			SceneManager.async_shake_camera(0.9, 0.1) # async call


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
	
	
func get_head_segment_damage() -> int:
	return _attack_1_head_segment_damage


func get_body_segment_damage() -> int:
	return _attack_1_body_segment_damage


func get_tail_segment_damage() -> int:
	return _attack_1_tail_segment_damage


func get_attack_3_laser_damage() -> int:
	return _attack_3_laser_damage


