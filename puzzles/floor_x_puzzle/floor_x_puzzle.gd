extends Node2D

## This signal is only fired once, when the puzzle is completed for the first time.
signal completed

const FloorPuzzleSwitch := preload("res://puzzles/floor_x_puzzle/floor_x_puzzle_switch.gd")
const StationaryRock := preload("res://interactables/stationary_rock/stationary_rock.gd")

# Stores the switches that will need to be activated.
var _floor_x_switches: Array[FloorPuzzleSwitch] = []

# Stores the obstacles that will be destroyed in order 
# for the player to progress once the puzzle is over.
var _obstacles_to_break: Array[StationaryRock] = []

var _required_active_switches := 0
var _currently_active_switches := 0

## Marks whether the puzzle has been completed before.
var _already_completed := false

func _ready() -> void:
	# These nodes must be added manually.
	for n in self.get_node("FloorXSwitches").get_children():
		var floor_switch: FloorPuzzleSwitch = n

		# Setup signals.
		floor_switch.activated.connect(_on_floor_switch_activated)
		floor_switch.deactivated.connect(_on_floor_switch_deactivated)

		# Store references.
		_floor_x_switches.append(floor_switch)
	
	# The amount of switches that need to be activated for the puzzle to be complete.
	_required_active_switches = len(_floor_x_switches)

	# This node must be added manually.
	_obstacles_to_break.append_array(self.get_node("ObstaclesToBreak").get_children())

	# This node must be added manually.
	# A reset button that resets the puzzle.
	self.get_node("FloorXPuzzleResetSwitch").activated.connect(_on_puzzle_reset)


func _on_floor_switch_activated() -> void:
	_currently_active_switches += 1

	if _currently_active_switches == _required_active_switches:
		_complete_puzzle()


func _on_floor_switch_deactivated() -> void:
	_currently_active_switches -= 1


func _on_puzzle_reset() -> void:
	# Forcefully turn off all the switches.
	for switch in _floor_x_switches:
		switch.force_deactivate()

	# Mark the number of active switches as zero.
	_currently_active_switches = 0
	
	# If this puzzle has 'Pushable Rocks', reset their position.
	if self.get_node_or_null("PushableRocks") != null:
		for n in self.get_node("PushableRocks").get_children():
			const PushableRock := preload("res://interactables/pushable_rock/pushable_rock.gd")
			var rock: PushableRock = n

			rock.reset_to_starting_position()


func _complete_puzzle() -> void:
	if not _already_completed:
		_already_completed = true
		self.completed.emit()

	for switch in _floor_x_switches:
		switch.finish()

	for obstacle in _obstacles_to_break:
		obstacle.destroy()

	_obstacles_to_break.clear()


