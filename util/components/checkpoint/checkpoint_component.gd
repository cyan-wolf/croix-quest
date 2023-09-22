extends Node2D
class_name CheckpointComponent

const Checkpoint := preload("res://util/checkpoint/checkpoint.gd")

# This has the zero vector as a dummy starting value since Godot doesn't support optional value types.
var _last_checkpoint_pos := Vector2.ZERO 

## Try to use the checkpoint if it hasn't been used before.
func try_to_use(checkpoint: Checkpoint) -> void:
	if not checkpoint.has_been_used_before():
		_set_checkpoint_pos(checkpoint.global_position)


## Called at the start of the scene to mark the "first" checkpoint.
func initialize(starting_pos: Vector2) -> void:
	_set_checkpoint_pos(starting_pos)


func get_last_checkpoint_pos() -> Vector2:
	return _last_checkpoint_pos


func _set_checkpoint_pos(pos: Vector2) -> void:
	_last_checkpoint_pos = pos

