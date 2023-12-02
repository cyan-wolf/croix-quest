extends Node2D

const FloorPuzzleSwitch := preload("res://puzzles/floor_x_puzzle/floor_x_puzzle_switch.gd")
const StationaryRock := preload("res://interactables/stationary_rock/stationary_rock.gd")

# Stores the switches that will need to be activated.
var _floor_x_switches: Array[FloorPuzzleSwitch] = []

# Stores the obstacles that will be destroyed in order 
# for the player to progress once the puzzle is over.
var _obstacles_to_break: Array[StationaryRock] = []

var _required_active_switches := 0
var _currently_active_switches := 0

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
	for switch in _floor_x_switches:
		switch.force_deactivate()

	_currently_active_switches = 0


func _complete_puzzle() -> void:
	for switch in _floor_x_switches:
		switch.finish()

	for obstacle in _obstacles_to_break:
		obstacle.destroy()

	_obstacles_to_break.clear()


