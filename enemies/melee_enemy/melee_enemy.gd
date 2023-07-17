extends CharacterBody2D

@export var _speed: float = 35.0

@onready var _nav_agent: NavigationAgent2D = self.get_node("NavigationAgent2D")
@onready var _enemy_sprite: AnimatedSprite2D = self.get_node("AnimatedSprite2D")
@onready var _player: Player = self.get_node("../Player")

var _current_sprite_direction := Util.Direction.RIGHT

func _physics_process(_delta: float) -> void:
	# TEMP
	await self.get_tree().process_frame
	_set_target_pos(_player.position)

	var move_direction := self.position.direction_to(_nav_agent.get_next_path_position())

	self.velocity = move_direction * _speed
	_nav_agent.velocity = self.velocity

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
		# Turn the sprite direction to the opposite side.
		match _current_sprite_direction:
			Util.Direction.RIGHT:
				_current_sprite_direction = Util.Direction.LEFT

			Util.Direction.LEFT:
				_current_sprite_direction = Util.Direction.RIGHT

	_flip_sprite_depending_on_direction()

