extends Node2D

const Projectile := preload("res://weapons/projectile/projectile.gd")

const SEGMENT_SCENE := preload("res://enemies/bosses/astral_lineus/segments/astral_lineus_segments.tscn")

# The direction that the boss' segments could face.
enum SegmentDirection {
	RIGHT = 0,
	LEFT = 1,
	DOWN = 2,
	TOP = 3, # possibly will be unused
}

signal perform_attack_1
signal perform_attack_2
signal perform_attack_3

@export var health_component: HealthComponent

@onready var _player: Player = SceneManager.find_player()

var _has_been_defeated := false

func _ready() -> void:
	self.perform_attack_1.connect(_async_on_perform_attack_1)
	self.perform_attack_2.connect(_async_on_perform_attack_2)
	self.perform_attack_3.connect(_async_on_perform_attack_3)

	self.health_component.death.connect(_on_death)

	# Play music.
	SceneManager.play_background_music("res://sounds/music/Orbital Colossus/Orbital Colossus.mp3")

	self.perform_attack_1.emit()

	# PLACEHOLDER FOR TESTING PURPOSES
	_summon_segment(self.global_position, SegmentDirection.LEFT)


# The boss "charges" horizontally from the sides of the map.
func _async_on_perform_attack_1() -> void:
	print_debug("TODO: In attack 1")

	await SceneManager.async_delay(1.0)

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


func _summon_segment(pos: Vector2, direction: SegmentDirection) -> void:
	var segments := SEGMENT_SCENE.instantiate()

	for segment in segments.get_children():
		var hitbox: Area2D = segment.get_node("HitboxArea")

		hitbox.area_entered.connect(_on_area_entered_segment_hitbox)
		
	segments.global_position = pos
	
	self.add_child(segments)


	

