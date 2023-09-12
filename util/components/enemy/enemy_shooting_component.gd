extends Node2D

@onready var _shooting_attack_timer: Timer = self.get_node("ShootingAttackTimer")

@onready var _enemy_component: EnemyComponent = self.get_parent().get_node("EnemyComponent")

## The projectile damage that this enemy deals.
@export var _damage: int = 1

## The reciprocal of this value is the wait time (in seconds) between shots.
@export var _fire_speed: float = 1.0

func _ready() -> void:
	_shooting_attack_timer.wait_time = 1.0 / _fire_speed
	_shooting_attack_timer.timeout.connect(_on_shooting_attack_timer_timeout)


func _on_shooting_attack_timer_timeout() -> void:
	# TODO
	pass


