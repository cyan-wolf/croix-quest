extends Node2D



func _ready() -> void:
	_async_manage_hideout_state_based_on_completed_milestones()


func _async_manage_hideout_state_based_on_completed_milestones() -> void:
	var progression_manager: ProgressionManager = SceneManager.progression()

	if progression_manager.has_milestone(Util.Milestone.DUNKEL_DUNGEON_COMPLETED):
		# Configure the scene based on progression in the game.
		print_debug("Should be in post-Dunkel configuration")

		_put_cat_spirit_in_hub()
		_put_frog_spirit_in_hub()
		_put_dog_spirit_in_hub()
		_put_penguin_spirit_in_hub()

	elif progression_manager.has_milestone(Util.Milestone.VODOROD_DUNGEON_COMPLETED):
		# Configure the scene based on progression in the game.
		print_debug("Should be in post-Vodorod configuration")

		_put_cat_spirit_in_hub()
		_put_frog_spirit_in_hub()
		_put_dog_spirit_in_hub()

	elif progression_manager.has_milestone(Util.Milestone.ULMUS_DUNGEON_COMPLETED):
		# Configure the scene based on progression in the game.
		print_debug("Should be in post-Ulmus configuration")

		_put_cat_spirit_in_hub()
		_put_frog_spirit_in_hub()

	elif progression_manager.has_milestone(Util.Milestone.COBALT_DUNGEON_COMPLETED):
		# Configure the scene based on progression in the game.
		print_debug("Should be in post-Cobalt configuration")

		_put_cat_spirit_in_hub()

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


func _put_cat_spirit_in_hub() -> void:
	var cat_spirit: Node2D = self.get_node("HubElements/ForestSprits/CatDialogNPC")
	var cat_hub_pos: Node2D = self.get_node("HubElements/ForestSpiritHubPositions/CatPosition")

	cat_spirit.global_position = cat_hub_pos.global_position


func _put_frog_spirit_in_hub() -> void:
	var frog_spirit: Node2D = self.get_node("HubElements/ForestSprits/FrogDialogNPC")
	var frog_hub_pos: Node2D = self.get_node("HubElements/ForestSpiritHubPositions/FrogPosition")

	frog_spirit.global_position = frog_hub_pos.global_position


func _put_dog_spirit_in_hub() -> void:
	var dog_spirit: Node2D = self.get_node("HubElements/ForestSprits/DogDialogNPC")
	var dog_hub_pos: Node2D = self.get_node("HubElements/ForestSpiritHubPositions/DogPosition")

	dog_spirit.global_position = dog_hub_pos.global_position


func _put_penguin_spirit_in_hub() -> void:
	var penguin_spirit: Node2D = self.get_node("HubElements/ForestSprits/PenguinDialogNPC")
	var penguin_hub_pos: Node2D = self.get_node("HubElements/ForestSpiritHubPositions/PenguinPosition")

	penguin_spirit.global_position = penguin_hub_pos.global_position


