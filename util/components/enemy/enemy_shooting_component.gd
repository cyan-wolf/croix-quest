extends Node2D

const Projectile := preload("res://weapons/projectile/projectile.gd")

@onready var _shooting_attack_timer: Timer = self.get_node("ShootingAttackTimer")

@onready var _enemy_component: EnemyComponent = self.get_parent().get_node("EnemyComponent")

@onready var _player: Player = SceneManager.find_player()

## The projectile damage that this enemy deals.
@export var _projectile_damage: int = 1

## The projectile's speed.
@export var _projectile_speed: float = 120.0

## The reciprocal of this value is the wait time (in seconds) between shots.
@export var _fire_speed: float = 1.0

## The sprite frames that the fired projectile will use; if `null`, the default sprite is used.
@export var _projectile_sprite_frames: SpriteFrames = null

var _projectile_scene := preload("res://weapons/projectile/projectile.tscn")

func _ready() -> void:
	_shooting_attack_timer.wait_time = 1.0 / _fire_speed
	_shooting_attack_timer.timeout.connect(_on_shooting_attack_timer_timeout)


func _on_shooting_attack_timer_timeout() -> void:
	if _enemy_component.get_current_state() != Util.EnemyState.ATTACKING:
		return

	_shoot()


func _shoot() -> void:
	var direction := self.global_position.direction_to(_player.global_position)

	Projectile.start_building() \
		.with_global_pos(self.global_position) \
		.with_impulse(direction * _projectile_speed) \
		.from_source(Projectile.Source.ENEMY) \
		.with_damage(_projectile_damage) \
		.with_sprite_frames(_projectile_sprite_frames) \
		.add_to_scene()

