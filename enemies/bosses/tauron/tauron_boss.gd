extends CharacterBody2D

const Projectile := preload("res://weapons/projectile/projectile.gd")

enum AttackState {
	NONE,
	STOMP,
	PROJECTILE,
	CHARGE,
}

signal perform_attack_1
signal perform_attack_2
signal perform_attack_3

@export var health_component: HealthComponent

## How much damage the stomp attack does.
@export var _stomp_attack_damage: int = 1

## How much damage the projectile attack does.
@export var _projectile_attack_damage: int = 1

## How much damage the charge (tackle) attack does.
@export var _charge_attack_damage: int = 1

@onready var _hitbox: Area2D = self.get_node("HitboxArea")
@onready var _stomp_attack_hitbox: Area2D = self.get_node("StompAttackHitboxArea")
@onready var _charge_attack_hitbox: Area2D = self.get_node("ChargeAttackHitboxArea")

var _current_attack_state := AttackState.NONE

var _has_been_defeated := false

func _ready() -> void:
	# Connect the necessary signals.
	_hitbox.area_entered.connect(_on_area_entered_hitbox)
	self.health_component.death.connect(_on_death)

	($StompAttackTimer as Timer).timeout.connect(_on_stomp_attack_timer_timeout)
	($ProjectileAttackTimer as Timer).timeout.connect(_on_projectile_attack_timer_timeout)
	($ChargeAttackTimer as Timer).timeout.connect(_on_charge_attack_timer_timeout)

	self.perform_attack_1.connect(_async_on_perform_attack_1)
	self.perform_attack_2.connect(_async_on_perform_attack_2)
	self.perform_attack_3.connect(_async_on_perform_attack_3)

	# Start the cycle of attacks.
	self.perform_attack_1.emit()


func _on_area_entered_hitbox(other_hitbox: Area2D) -> void:
	# Logic for taking projectile damage.
	if other_hitbox.is_in_group("projectile_hitbox"):
		var projectile: Projectile = other_hitbox.get_parent()

		self.health_component.take_damage(projectile.get_damage())


# A stomping attack.
func _async_on_perform_attack_1() -> void:
	# TODO: Attack logic goes here.
	print_debug("DEBUG: In phase 1")
	await SceneManager.async_delay(4.0)

	var jump_height := 20.0 * 16	# in pixels
	var jump_duration := 0.3		# in seconds

	# Wait for the boss to jump.
	await self.get_tree().create_tween().tween_property(
		self, 
		"global_position", 
		self.global_position + Vector2.UP * jump_height,
		jump_duration,
	).finished

	await SceneManager.async_delay(2.0)

	# Player position at the current moment.
	var player_pos: Vector2 = SceneManager.find_player().global_position

	self.global_position = player_pos + Vector2.UP * jump_height

	await SceneManager.async_delay(0.5)

	# This activates the stomp attack hitbox.
	_current_attack_state = AttackState.STOMP

	# TODO: Add a screen shake SFX when landing.

	# Wait for the boss to land where the player was.
	await self.get_tree().create_tween().tween_property(
		self, 
		"global_position", 
		player_pos,
		jump_duration,
	).finished

	await SceneManager.async_delay(2.0)

	# This deactivates the stomp attack hitbox.
	_current_attack_state = AttackState.NONE

	await SceneManager.async_delay(2.0)

	if _has_been_defeated:
		# Async call (no need to wait for the cutscene to finish).
		_async_play_defeated_cutscene()
		return

	self.perform_attack_2.emit()


# A projectile attack.
func _async_on_perform_attack_2() -> void:
	# TODO: Attack logic goes here.
	print_debug("DEBUG: In phase 2")
	await SceneManager.async_delay(4.0)

	if _has_been_defeated:
		# Async call (no need to wait for the cutscene to finish).
		_async_play_defeated_cutscene()
		return

	self.perform_attack_3.emit()


# A charging attack.
func _async_on_perform_attack_3() -> void:
	# TODO: Attack logic goes here.
	print_debug("DEBUG: In phase 3")
	await SceneManager.async_delay(4.0)

	if _has_been_defeated:
		# Async call (no need to wait for the cutscene to finish).
		_async_play_defeated_cutscene()
		return

	self.perform_attack_1.emit()


# Plays after the boss finishes its current phase and health is 0.
func _async_play_defeated_cutscene() -> void:
	# TODO
	print_debug("DEBUG: Tauron boss has died.")
	pass


func _on_death() -> void:
	_has_been_defeated = true


func _on_stomp_attack_timer_timeout() -> void:
	if _current_attack_state != AttackState.STOMP:
		return

	var stomp_attack_collison: CollisionShape2D = _stomp_attack_hitbox.get_node("CollisionShape2D")

	# Enables and disables the stomp attack each time the timer emits its `timeout` signal.
	stomp_attack_collison.set_deferred("disabled", not stomp_attack_collison.disabled)


# NOTE: This method might not be necessary, the projectiles could 
# just be fired in a loop.
func _on_projectile_attack_timer_timeout() -> void:
	if _current_attack_state != AttackState.PROJECTILE:
		return

	# TODO: Shoot projectiles.


func _on_charge_attack_timer_timeout() -> void:
	if _current_attack_state != AttackState.CHARGE:
		return

	var charge_attack_collison: CollisionShape2D = _charge_attack_hitbox.get_node("CollisionShape2D")

	# Enables and disables the stomp attack each time the timer emits its `timeout` signal.
	charge_attack_collison.set_deferred("disabled", not charge_attack_collison.disabled)