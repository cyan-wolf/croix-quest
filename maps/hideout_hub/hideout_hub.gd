extends Node2D



func _ready() -> void:
	_async_manage_hideout_state_based_on_completed_milestones()


func _async_manage_hideout_state_based_on_completed_milestones() -> void:
	var progression_manager: ProgressionManager = SceneManager.progression()

	if progression_manager.has_milestone(Util.Milestone.DUNKEL_DUNGEON_COMPLETED):
		# Configure the scene based on progression in the game.
		print_debug("Should be in post-Dunkel configuration")

	elif progression_manager.has_milestone(Util.Milestone.VODOROD_DUNGEON_COMPLETED):
		# Configure the scene based on progression in the game.
		print_debug("Should be in post-Vodorod configuration")

	elif progression_manager.has_milestone(Util.Milestone.ULMUS_DUNGEON_COMPLETED):
		# Configure the scene based on progression in the game.
		print_debug("Should be in post-Ulmus configuration")

	elif progression_manager.has_milestone(Util.Milestone.COBALT_DUNGEON_COMPLETED):
		# Configure the scene based on progression in the game.
		print_debug("Should be in post-Cobalt configuration")

	# This one might not be necessary since this could be the same as the default state.
	elif progression_manager.has_milestone(Util.Milestone.INTRO_CASTLE_COMPLETED):
		# Configure the scene based on progression in the game.
		print_debug("Should be in post-Intro Castle configuration")

	else:
		# Configure the scene based on progression in the game.
		print_debug("Should be in default(?) configuration")


	# Play the correct cutscene.
	_async_manage_cutscenes(progression_manager) # async call
	

func _async_manage_cutscenes(progression_manager: ProgressionManager) -> void:
	match progression_manager.get_just_completed_milestone():
		Util.Milestone.INTRO_CASTLE_COMPLETED:
			_async_should_play_first_cutscene()

		Util.Milestone.COBALT_DUNGEON_COMPLETED:
			_async_play_return_from_cobalt_cutscene()

		Util.Milestone.ULMUS_DUNGEON_COMPLETED:
			_async_play_return_from_ulmus_cutscene()

		Util.Milestone.VODOROD_DUNGEON_COMPLETED:
			_async_play_return_from_vodorod_cutscene()

		Util.Milestone.DUNKEL_DUNGEON_COMPLETED:
			_async_play_return_from_dunkel_cutscene()


func _async_should_play_first_cutscene() -> void:
	print_debug("Should play the first cutscene")


func _async_play_return_from_cobalt_cutscene() -> void:
	print_debug("Should play the 'Cobalt Dungeon' cutscene")


func _async_play_return_from_ulmus_cutscene() -> void:
	print_debug("Should play the 'Ulmus Dungeon' cutscene")


func _async_play_return_from_vodorod_cutscene() -> void:
	print_debug("Should play the 'Vodorod Dungeon' cutscene")


func _async_play_return_from_dunkel_cutscene() -> void:
	print_debug("Should play the 'Dunkel Dungeon' cutscene")


