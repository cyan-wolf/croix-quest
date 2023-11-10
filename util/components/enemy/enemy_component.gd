extends Node2D
class_name EnemyComponent

# This component is mainly in charge of changing the enemy's state depending on 
# the distance to the player and making the enemy move towards the player.

# Additionally, it manages the health and sprite animation of the enemy.



signal state_changed(old_state: Util.EnemyState, new_state: Util.EnemyState)

const Projectile := preload("res://weapons/projectile/projectile.gd")

@export var _sprite: AnimatedSprite2D
@export var _speed: float = 35.0
## The minimum distance before the enemy can follow the player.
@export var _min_player_follow_distance: float = 80.0

# This is the same as the `path_desired_distance` field on the nav agent.
## The minimun distance before the enemy can attack the player.
@export var _min_player_attack_distance: float = 32.0

@export var health_component: HealthComponent

@onready var _player: Player = SceneManager.find_player()

# This is the "main" node of the enemy.
@onready var _char_body: CharacterBody2D = self.get_parent()

# Used for the enemy's AI.
@onready var _nav_agent: NavigationAgent2D = self.get_node("NavigationAgent2D")

# The hitbox used for when taking damage.
# This node must be added manually to the `EnemyComponent`. 
@onready var _hitbox: Area2D = self.get_node("HitboxArea")

var _current_state := Util.EnemyState.IDLE

func _ready():
	# Make the health `Resource` unique so that different enemies can have 
	# different health values.
	self.health_component = self.health_component.duplicate(true)

	_hitbox.area_entered.connect(_on_area_entered_hitbox)
	self.health_component.death.connect(_on_death)

	_nav_agent.path_desired_distance = _min_player_attack_distance


func _on_area_entered_hitbox(other_hitbox: Area2D) -> void:
	if other_hitbox.is_in_group("projectile_hitbox"):
		var projectile: Projectile = other_hitbox.get_parent()

		if projectile.is_from_player():
			self.health_component.take_damage(projectile.get_damage())


func _on_death() -> void:
	# Free the `_char_body` since `self` only refers to the `EnemyComponent`.
	_char_body.queue_free()


func _physics_process(_delta: float) -> void:
	# Wait for things to process so that the navigation works.
	await self.get_tree().process_frame

	# This can't be done immediately after setting the target position.
	_update_current_enemy_state()

	# This needs to be done every frame, because otherwise the AI 
	# loses track of the player.
	_set_target_pos(_player.global_position)

	# Actually move the enemy only if it's supposed to be following the player.
	if _current_state == Util.EnemyState.FOLLOWING:
		var move_direction := self.global_position.direction_to(_nav_agent.get_next_path_position())
	
		_char_body.velocity = move_direction * _speed
		_nav_agent.velocity = _char_body.velocity

		_char_body.move_and_slide()

	# Do nothing here if the enemy is supposed to be idle or attacking.
	else:
		pass

	_update_sprite_facing_direction()


func get_current_state() -> Util.EnemyState:
	return _current_state


## Returns `true` is the sprite is facing left, `false` otherwise.
func is_sprite_facing_left() -> bool:
	return not _sprite.flip_h


func _update_current_enemy_state() -> void:
	var dist_to_player := self.global_position.distance_to(_player.global_position)

	# The enemy should be attacking if it has "reached" (gotten close enough)
	# to the player.
	if _nav_agent.is_navigation_finished():
		var old_state := _current_state
		_current_state = Util.EnemyState.ATTACKING
		self.state_changed.emit(old_state, _current_state)

		_sprite.play("attack")

	# The enemy should be idle if the player is too far away.
	elif dist_to_player > _min_player_follow_distance:
		var old_state := _current_state
		_current_state = Util.EnemyState.IDLE
		self.state_changed.emit(old_state, _current_state)

		_sprite.play("idle")

	# Otherwise, it should be following the player.
	else:
		var old_state := _current_state
		_current_state = Util.EnemyState.FOLLOWING
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

