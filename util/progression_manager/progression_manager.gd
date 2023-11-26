extends Node2D
class_name ProgressionManager



# Hash set (`Dictionary[Milestone, null]`) that stores every completed milestone.
var _completed_milestones: Dictionary = { Util.Milestone.NONE: null } # default value

# This variable only stores the milestone that was just completed.
# This is so that the hub only plays the appropriate cutscene once 
# after beating a dungeon's boss (for example).
var _just_completed_milestone: Util.Milestone = Util.Milestone.NONE

## Adds `milestone` to the list of completed milestones.
func add_milestone(milestone: Util.Milestone) -> void:
	# `_completed_milestones` is a hash set
	_completed_milestones[milestone] = null

	_just_completed_milestone = milestone


## Checks if `milestone` has been completed.
func has_milestone(milestone: Util.Milestone) -> bool:
	return _completed_milestones.has(milestone)


## Returns the milestone that was just completed.
func get_just_completed_milestone() -> Util.Milestone:
	return _just_completed_milestone


## Resets the milestone that was just completed.
## This does not remove this milestone from the list of completed milestones.
func reset_just_completed_milestone() -> void:
	_just_completed_milestone = Util.Milestone.NONE


