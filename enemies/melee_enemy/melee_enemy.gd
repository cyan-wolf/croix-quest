extends CharacterBody2D

@export var _speed: float = 35.0

@export var health_component: HealthComponent

@onready var _player: Player = self.get_node("../Player")

@onready var _nav_agent: NavigationAgent2D = self.get_node("NavigationAgent2D")
@onready var _enemy_sprite: AnimatedSprite2D = self.get_node("AnimatedSprite2D")
@onready var _hitbox: Area2D = self.get_node("HitboxArea")

var _current_sprite_direction := Util.Direction.RIGHT

func _ready():
	_hitbox.area_entered.connect(_on_area_entered_hitbox)
	self.health_component.death.connect(_on_death)


func _on_area_entered_hitbox(other_hitbox: Area2D) -> void:
	if other_hitbox.is_in_group("bullet_hitbox"):
		# TODO: Make damage based on the bullet's `damage` value.
		self.health_component.take_damage(1)


func _on_death() -> void:
	self.queue_free()


func _physics_process(_delta: float) -> void:
	# Wait for things to process so that the navigation works.
	await self.get_tree().process_frame

	_set_target_pos(_player.position)

	var move_direction := self.position.direction_to(_nav_agent.get_next_path_position())

	self.velocity = move_direction * _speed
	_nav_agent.velocity = self.velocity

	# TODO: Make the enemy switch to "melee attack mode" when close 
	# enough to the player.
	if not _nav_agent.is_navigation_finished():
		self.move_and_slide()

	_update_sprite_facing_direction()


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

