extends Node2D

@onready var _tutorial_prompt: Control = self.get_node("CanvasLayer/TutorialPrompt")

func _ready() -> void:
	self.get_node("../GuardCaptainNPC").dialog_ended.connect(_on_beginning_captain_npc_dialog_ended)
	_tutorial_prompt.get_node("TutorialButton").pressed.connect(_on_tutorial_start_button_pressed)
	_tutorial_prompt.get_node("SkipButton").pressed.connect(_on_tutorial_skip_button_pressed)


# Show the tutorial prompt after the Guard Captain stops talking
# after you right click on him.
func _on_beginning_captain_npc_dialog_ended() -> void:
	# Stops the player from moving when the prompt is visible.
	SceneManager.add_world_state(Util.WorldState.CUTSCENE_PLAYING)

	# Show the tutorial prompt.
	_tutorial_prompt.show()

	# Activate the teleporter that allows the player to continue with the story.
	self.get_node("../MainHallTeleporter").activate()


# Starts the tutorial.
func _on_tutorial_start_button_pressed() -> void:
	# Allows the player to move again.
	SceneManager.remove_world_state(Util.WorldState.CUTSCENE_PLAYING)
	_tutorial_prompt.hide()

	print_debug("tutorial started!")


# Skips the tutorial.
func _on_tutorial_skip_button_pressed() -> void:
	# Allows the player to move again.
	SceneManager.remove_world_state(Util.WorldState.CUTSCENE_PLAYING)
	_tutorial_prompt.hide()

