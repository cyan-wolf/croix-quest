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

## How many projectiles are fired in a second.
@export var _projectile_fire_speed: float = 2.0

## How many projectiles are fired in a phase.
@export var _projectile_amount: int = 10

## How much damage the charge (tackle) attack does.
@export var _charge_attack_damage: int = 1

## Speed in pixels per second.
@export var _charge_attack_speed: float = 14.0 * 16

## Duration in seconds.
@export var _charge_attack_duration: float = 0.5

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

	# Play music.
	SceneManager.play_background_music("res://sounds/music/Orbital Colossus/Orbital Colossus.mp3")

	# Start the cycle of attacks.
	self.perform_attack_1.emit()


func _on_area_entered_hitbox(other_hitbox: Area2D) -> void:
	# Logic for taking projectile damage.
	if other_hitbox.is_in_group("projectile_hitbox"):
		var projectile: Projectile = other_hitbox.get_parent()

		if projectile.is_from_player():
			self.health_component.take_damage(projectile.get_damage())

			SceneManager.async_shake_camera(0.9, 0.1) # async call


func _physics_process(delta: float) -> void:
	self.move_and_collide(self.velocity * delta)


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

	SceneManager.async_shake_camera(1.5, 0.2) # async call

	await SceneManager.async_delay(2.0)

	# This deactivates the stomp attack hitbox.
	_current_attack_state = AttackState.NONE
	_stomp_attack_hitbox.get_node("CollisionShape2D").set_deferred("disabled", true)

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
	await SceneManager.async_delay(1.0)

	for _i in range(_projectile_amount):
		_fire_projectile()

		await SceneManager.async_delay(1 / _projectile_fire_speed)

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

	var prev_player_pos: Vector2 = SceneManager.find_player().global_position

	var charge_velocity := self.global_position.direction_to(prev_player_pos) * _charge_attack_speed

	self.velocity = charge_velocity

	# This activates the charge attack hitbox.
	_current_attack_state = AttackState.CHARGE

	await SceneManager.async_delay(_charge_attack_duration)

	self.velocity = Vector2.ZERO

	# This deactivates the charge attack hitbox.
	_current_attack_state = AttackState.NONE
	_charge_attack_hitbox.get_node("CollisionShape2D").set_deferred("disabled", true)

	if _has_been_defeated:
		# Async call (no need to wait for the cutscene to finish).
		_async_play_defeated_cutscene()
		return

	self.perform_attack_1.emit()


# Plays after the boss finishes its current phase and health is 0.
func _async_play_defeated_cutscene() -> void:
	# TODO
	print_debug("DEBUG: Tauron boss has died.")

	# Stop playing the music that started when the boss appeared.
	SceneManager.stop_playing_background_music()
	pass


func _fire_projectile() -> void:
	# The projectile is fired from the boss' mouth.
	# The mouth is located some pixels down from the boss' origin.
	var mouth_pos := self.global_position - Vector2.UP * 20

	var direction := mouth_pos.direction_to(SceneManager.find_player().global_position)
	var speed := 120.0

	Projectile.start_building() \
		.with_global_pos(mouth_pos) \
		.with_impulse(direction * speed) \
		.from_source(Projectile.Source.TAURON_BOSS) \
		.with_damage(_projectile_attack_damage) \
		.add_to_scene()


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


func get_stomp_attack_damage() -> int:
	return _stomp_attack_damage


func get_charge_attack_damage() -> int:
	return _charge_attack_damage

