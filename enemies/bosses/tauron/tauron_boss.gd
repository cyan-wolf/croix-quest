extends CharacterBody2D

const Projectile := preload("res://weapons/projectile/projectile.gd")

signal perform_attack_1
signal perform_attack_2
signal perform_attack_3

@export var health_component: HealthComponent

@onready var _hitbox: Area2D = self.get_node("HitboxArea")

var _has_been_defeated := false

func _ready() -> void:
	# Connect the necessary signals.
	_hitbox.area_entered.connect(_on_area_entered_hitbox)
	self.health_component.death.connect(_on_death)

	self.perform_attack_1.connect(_async_on_perform_attack_1)
	self.perform_attack_2.connect(_async_on_perform_attack_2)
	self.perform_attack_3.connect(_async_on_perform_attack_3)


func _on_area_entered_hitbox(other_hitbox: Area2D) -> void:
	# Logic for taking projectile damage.
	if other_hitbox.is_in_group("projectile_hitbox"):
		var projectile: Projectile = other_hitbox.get_parent()

		self.health_component.take_damage(projectile.get_damage())


# A stomping attack.
func _async_on_perform_attack_1() -> void:
	# TODO: Attack logic goes here.

	if _has_been_defeated:
		# Async call (no need to wait for the cutscene to finish).
		_async_play_defeated_cutscene()
		return

	self.perform_attack_2.emit()


# A projectile attack.
func _async_on_perform_attack_2() -> void:
	# TODO: Attack logic goes here.

	if _has_been_defeated:
		# Async call (no need to wait for the cutscene to finish).
		_async_play_defeated_cutscene()
		return

	self.perform_attack_3.emit()


# A charging attack.
func _async_on_perform_attack_3() -> void:
	# TODO: Attack logic goes here.

	if _has_been_defeated:
		# Async call (no need to wait for the cutscene to finish).
		_async_play_defeated_cutscene()
		return

	self.perform_attack_1.emit()


# Plays after the boss finishes its current phase and health is 0.
func _async_play_defeated_cutscene() -> void:
	# TODO
	pass


func _on_death() -> void:
	_has_been_defeated = true

