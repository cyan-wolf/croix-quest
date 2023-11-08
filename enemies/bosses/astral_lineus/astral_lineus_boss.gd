extends Node2D

const Projectile := preload("res://weapons/projectile/projectile.gd")

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


func _async_on_perform_attack_1() -> void:
	print_debug("TODO: In attack 1")

	await SceneManager.async_delay(1.0)

	if _has_been_defeated:
		# Async call (no need to wait for the cutscene to finish).
		_async_play_defeated_cutscene()
		return

	self.perform_attack_2.emit()


func _async_on_perform_attack_2() -> void:
	print_debug("TODO: In attack 2")

	await SceneManager.async_delay(1.0)

	if _has_been_defeated:
		# Async call (no need to wait for the cutscene to finish).
		_async_play_defeated_cutscene()
		return

	self.perform_attack_3.emit()


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


