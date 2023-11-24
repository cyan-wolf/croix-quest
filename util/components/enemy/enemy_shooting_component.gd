extends Node2D

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

## The offset (from the enemy's (0, 0) position) from where the projectile is fired.
@export var _fire_offset_position: Vector2 = Vector2.ZERO

## The scale of the projectile.
@export var _projectile_scale: float = 1.0

var _current_fire_offset: Vector2

func _ready() -> void:
	_shooting_attack_timer.wait_time = 1.0 / _fire_speed
	_shooting_attack_timer.timeout.connect(_on_shooting_attack_timer_timeout)

	if _projectile_sprite_frames == null:
		_projectile_sprite_frames = Projectile.DEFAULT_PROJECTILE_SPRITE_FRAMES


func _process(_delta: float) -> void:
	if _enemy_component.is_sprite_facing_left():
		_current_fire_offset = _fire_offset_position

	else:
		_current_fire_offset = _fire_offset_position
		# Flip the x position since the enemy's sprite is flipped.
		_current_fire_offset.x *= -1


func _on_shooting_attack_timer_timeout() -> void:
	if _enemy_component.get_current_state() != Util.EnemyState.ATTACKING:
		return

	_shoot()


func _shoot() -> void:
	var projectile_spawn_pos := self.global_position + _current_fire_offset

	var direction := projectile_spawn_pos.direction_to(_player.global_position)

	Projectile.start_building() \
		.with_global_pos(projectile_spawn_pos) \
		.with_impulse(direction * _projectile_speed) \
		.from_source(Projectile.Source.ENEMY) \
		.with_damage(_projectile_damage) \
		.with_sprite_frames(_projectile_sprite_frames) \
		.with_scale(_projectile_scale) \
		.add_to_scene()

