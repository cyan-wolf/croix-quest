extends Node2D
class_name CheckpointComponent

const Checkpoint := preload("res://util/checkpoint/checkpoint.gd")

# Used to mark if the player has passed a checkpoint before in the current dungeon.
var _has_checkpoint_pos := false

# This has the zero vector as a dummy starting value since Godot doesn't support optional value types.
var _last_checkpoint_pos := Vector2.ZERO 

func try_to_use(checkpoint: Checkpoint) -> void:
	if not checkpoint.has_been_used_before():
		# TODO
		pass

