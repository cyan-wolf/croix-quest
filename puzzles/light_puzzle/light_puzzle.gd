extends Node2D

const PushableRock := preload("res://interactables/pushable_rock/pushable_rock.gd")

func _ready() -> void:
	# This node must be added manually.
	self.get_node("ResetSwitch").activated.connect(_on_puzzle_reset)


# Resets the 'Pushable Rocks' to their original position.
func _on_puzzle_reset() -> void:
	for n in self.get_node("PushableRocks").get_children():
		var rock: PushableRock = n
		rock.reset_to_starting_position()

