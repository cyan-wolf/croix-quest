extends CharacterBody2D

@export var _speed: float = 35.0

@onready var _nav_agent: NavigationAgent2D = self.get_node("NavigationAgent2D")
@onready var _enemy_sprite: AnimatedSprite2D = self.get_node("AnimatedSprite2D")
@onready var _player: Player = self.get_node("../Player")

var _current_sprite_direction := Util.Direction.RIGHT

func _process(_delta: float) -> void:
	match _current_sprite_direction:
		Util.Direction.RIGHT:
			_enemy_sprite.flip_h = false
		
		Util.Direction.LEFT:
			_enemy_sprite.flip_h = true


func _physics_process(_delta: float) -> void:
	# TEMP
	await self.get_tree().process_frame
	_set_target_pos(_player.position)

	var move_direction := self.position.direction_to(_nav_agent.get_next_path_position())

	self.velocity = move_direction * _speed
	_nav_agent.velocity = self.velocity

	self.move_and_slide()


func _set_target_pos(pos: Vector2) -> void:
	_nav_agent.target_position = pos


# TODO: fix this
func _set_sprite_direction() -> void:
	var enemy_facing_direction: Vector2

	match _current_sprite_direction:
		Util.Direction.RIGHT:
			enemy_facing_direction = Vector2.RIGHT

		Util.Direction.LEFT:
			enemy_facing_direction = Vector2.LEFT

	var enemy_should_face_player: bool = (enemy_facing_direction.dot(_player.global_position) < 0)

	if enemy_should_face_player:
		# Turn the sprite direction to the opposite side.
		match _current_sprite_direction:
			Util.Direction.RIGHT:
				_current_sprite_direction = Util.Direction.LEFT

			Util.Direction.LEFT:
				_current_sprite_direction = Util.Direction.RIGHT
		
	# Do nothing since the enemy is already facing the player.
	else:
		pass

