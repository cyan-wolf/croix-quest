extends AnimatableBody2D

const REQUIRED_MANA_AMOUNT_TO_MOVE: int = 1

@onready var _interaction_component: InteractionComponent = self.get_node("InteractionComponent")

@onready var _starting_position: Vector2 = self.global_position

## In pixels per second.
@export var _speed: float = 50.0

var _velocity := Vector2.ZERO
var _is_moving := false

func _ready() -> void:
	_interaction_component.interact.connect(_on_player_interact)


func _physics_process(delta: float) -> void:
	if not _is_moving:
		return

	var col := self.move_and_collide(_velocity * _speed * delta)

	if col != null:
		_is_moving = false


func _on_player_interact() -> void:
	# The player can't change the rock's direction when its moving.
	if _is_moving:
		return

	var player: Player = SceneManager.find_player()

	if player.mana_component.has_enough_mana(REQUIRED_MANA_AMOUNT_TO_MOVE):
		player.mana_component.use_mana(REQUIRED_MANA_AMOUNT_TO_MOVE)

		_is_moving = true
		
		var dir_to_move_in := player.global_position.direction_to(self.global_position)

		_velocity = _align_direction_to_nearest_cartesian_vector(dir_to_move_in)


func _align_direction_to_nearest_cartesian_vector(direction: Vector2) -> Vector2:
	var abs_x := absf(direction.x)
	var abs_y := absf(direction.y)

	# Determine whether the vector is pointing more towards x or y.
	if abs_x >= abs_y:
		# Use the sign to determine the direction within the axis.
		if direction.x >= 0:
			direction = Vector2.RIGHT
		else:
			direction = Vector2.LEFT		
	else:
		# Use the sign to determine the direction within the axis.
		if direction.y >= 0:
			direction = Vector2.DOWN
		else:
			direction = Vector2.UP

	return direction


## Resets the rock's position to its starting position.
func reset_to_starting_position() -> void:
	_is_moving = false
	self.global_position = _starting_position

