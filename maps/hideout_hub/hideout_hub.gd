extends Node2D

@export var _first_cutscene_dialog: DialogResource
@export var _return_from_cobalt_dialog: DialogResource
@export var _return_from_ulmus_dialog: DialogResource
@export var _return_from_vodorod_dialog: DialogResource
@export var _return_from_dunkel_dialog: DialogResource

# The delay before dialog plays in a cutscene.
const CUTSCENE_DIALOG_DELAY := 1.3

func _ready() -> void:
	_async_manage_hideout_state_based_on_completed_milestones()


func _async_manage_hideout_state_based_on_completed_milestones() -> void:
	var progression_manager: ProgressionManager = SceneManager.progression()

	_move_emmy_to_default_position()

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

	SceneManager.add_world_state(Util.WorldState.CUTSCENE_PLAYING)

	# Move Emmy to the center.
	_move_emmy_to_lore_position()

	# Reset the "just completed milestone" so that this cutcene doesn't play again.
	SceneManager.progression().reset_just_completed_milestone()

	await SceneManager.async_delay(CUTSCENE_DIALOG_DELAY)

	# Play the appropriate dialog.
	DialogManager.start_dialog(_first_cutscene_dialog)


	SceneManager.remove_world_state(Util.WorldState.CUTSCENE_PLAYING)


func _async_play_return_from_cobalt_cutscene() -> void:
	print_debug("Should play the 'Cobalt Dungeon' cutscene")

	SceneManager.add_world_state(Util.WorldState.CUTSCENE_PLAYING)

	# Move Emmy to the center.
	_move_emmy_to_lore_position()

	# Reset the "just completed milestone" so that this cutcene doesn't play again.
	SceneManager.progression().reset_just_completed_milestone()

	await SceneManager.async_delay(CUTSCENE_DIALOG_DELAY)

	# Play the appropriate dialog.
	DialogManager.start_dialog(_return_from_cobalt_dialog)

	SceneManager.remove_world_state(Util.WorldState.CUTSCENE_PLAYING)


func _async_play_return_from_ulmus_cutscene() -> void:
	print_debug("Should play the 'Ulmus Dungeon' cutscene")

	SceneManager.add_world_state(Util.WorldState.CUTSCENE_PLAYING)

	# Move Emmy to the center.
	_move_emmy_to_lore_position()

	# Reset the "just completed milestone" so that this cutcene doesn't play again.
	SceneManager.progression().reset_just_completed_milestone()

	await SceneManager.async_delay(CUTSCENE_DIALOG_DELAY)

	# Play the appropriate dialog.
	DialogManager.start_dialog(_return_from_ulmus_dialog)

	SceneManager.remove_world_state(Util.WorldState.CUTSCENE_PLAYING)


func _async_play_return_from_vodorod_cutscene() -> void:
	print_debug("Should play the 'Vodorod Dungeon' cutscene")

	SceneManager.add_world_state(Util.WorldState.CUTSCENE_PLAYING)

	# Move Emmy to the center.
	_move_emmy_to_lore_position()

	# Reset the "just completed milestone" so that this cutcene doesn't play again.
	SceneManager.progression().reset_just_completed_milestone()

	await SceneManager.async_delay(CUTSCENE_DIALOG_DELAY)

	# Play the appropriate dialog.
	DialogManager.start_dialog(_return_from_vodorod_dialog)

	SceneManager.remove_world_state(Util.WorldState.CUTSCENE_PLAYING)


func _async_play_return_from_dunkel_cutscene() -> void:
	print_debug("Should play the 'Dunkel Dungeon' cutscene")

	SceneManager.add_world_state(Util.WorldState.CUTSCENE_PLAYING)

	# Move Emmy to the center.
	_move_emmy_to_lore_position()

	# Reset the "just completed milestone" so that this cutcene doesn't play again.
	SceneManager.progression().reset_just_completed_milestone()

	await SceneManager.async_delay(CUTSCENE_DIALOG_DELAY)

	# Play the appropriate dialog.
	DialogManager.start_dialog(_return_from_dunkel_dialog)

	SceneManager.remove_world_state(Util.WorldState.CUTSCENE_PLAYING)


# Moves Emmy to a corner when there isn't a cutscene playing.
func _move_emmy_to_default_position() -> void:
	var emmy_npc: Node2D = self.get_node("HubElements/EmmyDialogNPC")
	var emmy_default_pos: Node2D = self.get_node("HubElements/EmmyDefaultPosition")

	emmy_npc.global_position = emmy_default_pos.global_position


# Move Emmy to the center of the room in cutscenes.
func _move_emmy_to_lore_position() -> void:
	var emmy_npc: Node2D = self.get_node("HubElements/EmmyDialogNPC")
	var emmy_lore_pos: Node2D = self.get_node("HubElements/EmmyLorePosition")

	emmy_npc.global_position = emmy_lore_pos.global_position


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


