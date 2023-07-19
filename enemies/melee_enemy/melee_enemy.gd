extends CharacterBody2D

enum EnemyState {
	IDLE = 0,
	FOLLOWING = 1,
	ATTACKING = 2,
}

@export var _speed: float = 35.0
@export var _damage: int = 1
## The minimum distance before the enemy starts following the player.
@export var _min_player_follow_distance: float = 80.0
## The reciprocal of this value is the wait time (in seconds) between attacks.
@export var _attack_speed: float = 1.0

@export var health_component: HealthComponent

@onready var _player: Player = self.get_node("../Player")

@onready var _nav_agent: NavigationAgent2D = self.get_node("NavigationAgent2D")
@onready var _enemy_sprite: AnimatedSprite2D = self.get_node("AnimatedSprite2D")

@onready var _hitbox: Area2D = self.get_node("HitboxArea")
@onready var _melee_attack_hitbox: Area2D = self.get_node("MeleeAttackHitboxArea")
@onready var _melee_attack_timer: Timer = self.get_node("MeleeAttackTimer")

var _current_state := EnemyState.IDLE
var _current_sprite_direction := Util.Direction.RIGHT

func _ready():
	_hitbox.area_entered.connect(_on_area_entered_hitbox)
	self.health_component.death.connect(_on_death)

	_melee_attack_timer.wait_time = 1.0 / _attack_speed
	_melee_attack_timer.timeout.connect(_on_melee_attack_timer_timeout)


func _on_area_entered_hitbox(other_hitbox: Area2D) -> void:
	if other_hitbox.is_in_group("bullet_hitbox"):
		# TODO: Make damage based on the bullet's `damage` value.
		self.health_component.take_damage(1)


func _on_melee_attack_timer_timeout() -> void:
	if _current_state != EnemyState.ATTACKING:
		return

	var melee_attack_collison: CollisionShape2D = _melee_attack_hitbox.get_node("CollisionShape2D")

	# Enables and disables the melee attack each time the timer emits its `timeout` signal.
	melee_attack_collison.set_deferred("disabled", not melee_attack_collison.disabled)


func _on_death() -> void:
	self.queue_free()


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
	
		self.velocity = move_direction * _speed
		_nav_agent.velocity = self.velocity

		self.move_and_slide()

	# Do nothing here if the enemy is supposed to be idle or attacking.
	else:
		pass

	_update_sprite_facing_direction()


func get_damage() -> int:
	return _damage


func _update_current_enemy_state() -> void:
	# The enemy should be idle if the player is too far away.
	if self.global_position.distance_to(_player.global_position) > _min_player_follow_distance:
		_current_state = EnemyState.IDLE
		_enemy_sprite.play("idle")

	# The enemy should be attacking if it has "reached" (gotten close enough)
	# to the player.
	elif _nav_agent.is_navigation_finished():
		_current_state = EnemyState.ATTACKING
		_enemy_sprite.play("attacking")

	# Otherwise, it should be following the player.
	else:
		_current_state = EnemyState.FOLLOWING
		_enemy_sprite.play("following")


func _set_target_pos(pos: Vector2) -> void:
	_nav_agent.target_position = pos


# Turns the sprite direction `Direction` enum into an equivalent vector.
func _get_sprite_facing_direction_as_vector() -> Vector2:
	match _current_sprite_direction:
		Util.Direction.RIGHT:
			return Vector2.RIGHT

		Util.Direction.LEFT:
			return Vector2.LEFT

		# Unreachable.
		_:
			return Vector2.RIGHT


func _flip_sprite_depending_on_direction() -> void:
	match _current_sprite_direction:
		Util.Direction.RIGHT:
			_enemy_sprite.flip_h = false
			
		Util.Direction.LEFT:
			_enemy_sprite.flip_h = true


func _update_sprite_facing_direction() -> void:
	# The current sprite facing direction.
	var facing_direction: Vector2 = _get_sprite_facing_direction_as_vector()

	# The direction that the player is in from the enemy's perspective.
	var direction_to_player: Vector2 = self.global_position.direction_to(_player.global_position)

	# Calculated using math.
	# The expression `facing_direction.dot(direction_to_player)` is negative when 
	# the enemy sprite is not facing towards the player.
	var enemy_should_face_player: bool = (facing_direction.dot(direction_to_player) < 0)

	# Since the enemy's sprite is not facing the player, it should be turned around.
	if enemy_should_face_player:
		match _current_sprite_direction:
			Util.Direction.RIGHT:
				_current_sprite_direction = Util.Direction.LEFT

			Util.Direction.LEFT:
				_current_sprite_direction = Util.Direction.RIGHT

	_flip_sprite_depending_on_direction()

