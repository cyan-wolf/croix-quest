extends Node2D

# This component is mainly in charge of changing the enemy's state depending on 
# the distance to the player and making the enemy move towards the player.

# Additionally, it manages the health and sprite animation of the enemy (this could 
# be subject to change).

enum EnemyState {
	IDLE = 0,
	FOLLOWING = 1,
	ATTACKING = 2,
}

signal state_changed(old_state: EnemyState, new_state: EnemyState)

const Projectile := preload("res://weapons/projectile/projectile.gd")

@export var _sprite: AnimatedSprite2D
@export var _speed: float = 35.0
@export var _damage: int = 1
## The minimum distance before the enemy can follow the player.
@export var _min_player_follow_distance: float = 80.0

# This is the same as the `target_desired_distance` field on the nav agent.
## The minimun distance before the enemy can attack the player.
@export var _min_player_attack_distance: float = 32.0

## The reciprocal of this value is the wait time (in seconds) between attacks.
# @export var _attack_speed: float = 1.0

@export var health_component: HealthComponent

@onready var _player: Player = SceneManager.find_player()

# This is the "main" node of the enemy.
@onready var _char_body: CharacterBody2D = self.get_parent()

@onready var _nav_agent: NavigationAgent2D = self.get_node("NavigationAgent2D")

# The hitbox used for when taking damage.
# This node must be added manually to the `EnemyComponent`. 
@onready var _hitbox: Area2D = self.get_node("HitboxArea")

# TODO: Seperate the melee attack stuff into a `MeleeAttackComponent`.
# The `MeleeAttackComponent` should react to signals (or some other way) sent 
# by this node.

# @onready var _melee_attack_hitbox: Area2D = self.get_node("MeleeAttackHitboxArea")
# @onready var _melee_attack_timer: Timer = self.get_node("MeleeAttackTimer")

var _current_state := EnemyState.IDLE
# var _current_sprite_direction := Util.Direction.RIGHT

func _ready():
	_hitbox.area_entered.connect(_on_area_entered_hitbox)
	self.health_component.death.connect(_on_death)

	_nav_agent.target_desired_distance = _min_player_attack_distance

	# _melee_attack_timer.wait_time = 1.0 / _attack_speed
	# _melee_attack_timer.timeout.connect(_on_melee_attack_timer_timeout)


func _on_area_entered_hitbox(other_hitbox: Area2D) -> void:
	if other_hitbox.is_in_group("projectile_hitbox"):
		var projectile: Projectile = other_hitbox.get_parent()

		if projectile.is_from_player():
			self.health_component.take_damage(projectile.get_damage())


# func _on_melee_attack_timer_timeout() -> void:
# 	if _current_state != EnemyState.ATTACKING:
# 		return

# 	var melee_attack_collison: CollisionShape2D = _melee_attack_hitbox.get_node("CollisionShape2D")

# 	# Enables and disables the melee attack each time the timer emits its `timeout` signal.
# 	melee_attack_collison.set_deferred("disabled", not melee_attack_collison.disabled)


func _on_death() -> void:
	# Free the `_char_body` since `self` only refers to the `EnemyComponent`.
	_char_body.queue_free()


func _physics_process(_delta: float) -> void:
	# Wait for things to process so that the navigation works.
	await self.get_tree().process_frame

	# This needs to be done every frame, because otherwise the AI 
	# loses track of the player.
	_set_target_pos(_player.global_position)

	_update_current_enemy_state()

	# Actually move the enemy only if it's supposed to be following the player.
	if _current_state == EnemyState.FOLLOWING:
		var move_direction := self.global_position.direction_to(_nav_agent.get_next_path_position())
	
		_char_body.velocity = move_direction * _speed
		_nav_agent.velocity = _char_body.velocity

		_char_body.move_and_slide()

	# Do nothing here if the enemy is supposed to be idle or attacking.
	else:
		pass

	_update_sprite_facing_direction()


func get_damage() -> int:
	return _damage


func _update_current_enemy_state() -> void:
	# The enemy should be idle if the player is too far away.
	if self.global_position.distance_to(_player.global_position) > _min_player_follow_distance:
		var old_state := _current_state
		_current_state = EnemyState.IDLE
		self.state_changed.emit(old_state, _current_state)

		_sprite.play("idle")

	# The enemy should be attacking if it has "reached" (gotten close enough)
	# to the player.
	elif _nav_agent.is_navigation_finished():
		var old_state := _current_state
		_current_state = EnemyState.ATTACKING
		self.state_changed.emit(old_state, _current_state)

		_sprite.play("attack")

	# Otherwise, it should be following the player.
	else:
		var old_state := _current_state
		_current_state = EnemyState.FOLLOWING
		self.state_changed.emit(old_state, _current_state)

		_sprite.play("follow")


func _set_target_pos(pos: Vector2) -> void:
	_nav_agent.target_position = pos


func _update_sprite_facing_direction() -> void:
	# The enemy is to the left of the player, so the sprite should face normally.
	if self.global_position.x < _player.global_position.x:
		_sprite.flip_h = false

	# The enemy is to the right of the player, so the sprite should be flipped.
	else:
		_sprite.flip_h = true


# # Turns the sprite direction `Direction` enum into an equivalent vector.
# func _get_sprite_facing_direction_as_vector() -> Vector2:
# 	match _current_sprite_direction:
# 		Util.Direction.RIGHT:
# 			return Vector2.RIGHT

# 		Util.Direction.LEFT:
# 			return Vector2.LEFT

# 		# Unreachable.
# 		_:
# 			return Vector2.RIGHT


# func _flip_sprite_depending_on_direction() -> void:
# 	match _current_sprite_direction:
# 		Util.Direction.RIGHT:
# 			_sprite.flip_h = false
			
# 		Util.Direction.LEFT:
# 			_sprite.flip_h = true


# func _update_sprite_facing_direction() -> void:
# 	# The current sprite facing direction.
# 	var facing_direction: Vector2 = _get_sprite_facing_direction_as_vector()

# 	# The direction that the player is in from the enemy's perspective.
# 	var direction_to_player: Vector2 = self.global_position.direction_to(_player.global_position)

# 	# Calculated using math.
# 	# The expression `facing_direction.dot(direction_to_player)` is negative when 
# 	# the enemy sprite is not facing towards the player.
# 	var enemy_should_face_player: bool = (facing_direction.dot(direction_to_player) < 0)

# 	# Since the enemy's sprite is not facing the player, it should be turned around.
# 	if enemy_should_face_player:
# 		match _current_sprite_direction:
# 			Util.Direction.RIGHT:
# 				_current_sprite_direction = Util.Direction.LEFT

# 			Util.Direction.LEFT:
# 				_current_sprite_direction = Util.Direction.RIGHT

# 	_flip_sprite_depending_on_direction()

