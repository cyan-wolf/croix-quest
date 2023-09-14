extends Node2D
class_name EnemyMeleeComponent

@onready var _melee_attack_timer: Timer = self.get_node("MeleeAttackTimer")

# This node must be added manually to the `EnemyMeleeComponent`.
# This hitbox is used for the melee attack.
@onready var _melee_attack_hitbox: Area2D = self.get_node("HitboxArea")

@onready var _enemy_component: EnemyComponent = self.get_parent().get_node("EnemyComponent")

## The melee damage that this enemy deals.
@export var _damage: int = 1

## The reciprocal of this value is the wait time (in seconds) between attacks.
@export var _attack_speed: float = 1.0

func _ready() -> void:
	_melee_attack_timer.wait_time = 1.0 / _attack_speed
	_melee_attack_timer.timeout.connect(_on_melee_attack_timer_timeout)

	if not _melee_attack_hitbox.is_in_group("enemy_melee_attack_hitbox"):
		print_debug(
			"Warning: The hitbox of the `EnemyMeleeComponent` from node ",
			"`%s` must be in the 'enemy_melee_attack_hitbox' group." % self.get_parent().name
		)


func _on_melee_attack_timer_timeout() -> void:
	if _enemy_component.get_current_state() != Util.EnemyState.ATTACKING:
		return

	var melee_attack_collison: CollisionShape2D = _melee_attack_hitbox.get_node("CollisionShape2D")

	# Enables and disables the melee attack each time the timer emits its `timeout` signal.
	melee_attack_collison.set_deferred("disabled", not melee_attack_collison.disabled)


func get_damage() -> int:
	return _damage

