extends Node2D

const DunkelLoreManager := preload("res://maps/dungeons/dunkel_dungeon/lore/dunkel_dungeon_lore_manager.gd")

enum ResponseResult {
	CORRECT = 0,
	INCORRECT = 1,
}

## Emitted when the player responds to the current question.
signal player_responded

@export var _puzzlemaster_health_component: HealthComponent

@onready var _riddle_prompt: Control = self.get_node("CanvasLayer/RiddlePrompt")
@onready var _puzzlemaster_boss_health_bar: BossHealthBar = self.get_node("CanvasLayer/BossHeathBar")

@onready var _lore_manager: DunkelLoreManager = self.get_node("../DunkelDungeonLoreManager")

## The response that answers the current question, value ranges from 1 to 4.
var _current_answer_id := 0 # unitialized

## The last response given by the player, value ranges from 1 to 4.
var _last_response_id := 0 # uninitalized

func _ready() -> void:
	_riddle_prompt.hide()

	self.get_node("../Props/TeleportersCollection/Teleporter9") \
		.used \
		.connect(_async_start_puzzlemaster_riddles)

	_setup_response_buttons()


func _setup_response_buttons() -> void:
	for i in range(4):
		(self.get_node("CanvasLayer/RiddlePrompt/ResponseButton%d" % (i + 1)) as Button) \
			.pressed \
			.connect(func():
				_last_response_id = (i + 1)
				self.player_responded.emit()
				)


func _async_start_puzzlemaster_riddles() -> void:
	print_debug("Started riddles")

	SceneManager.start_cutscene()

	_lore_manager.set_dungeon_light_level(DunkelLoreManager.SceneLightLevel.VERY_DIM)

	await SceneManager.async_delay(1.0)

	self.get_node("Spotlights/PointLight2D2").show()

	await SceneManager.async_delay(1.0)

	self.get_node("Spotlights/PointLight2D").show()

	await SceneManager.async_delay(1.0)

	DialogManager.start_dialog(DialogResource.create("Puzzlemaster", [
		"We meet again.",
		"Seeing you struggle so much in the last dungeon made me realize something very important.",
		"You have gotten weak.",
		"I will not let you continue until you defeat me... with riddles.",
		"My riddles have magical powers. If you get a question wrong, you take damage. If you get a question right, I take damage.",
		"I'll only let you pass if you manage to solve enough questions to defeat me.",
		"Let us begin.",
	]))

	await DialogManager.ended_dialog

	_puzzlemaster_boss_health_bar.initialize(_puzzlemaster_health_component, "Puzzlemaster")

	_async_give_first_question() # async call


## The `responses` argument must have length `4`.
func _update_riddle_prompt_ui(question: String, responses: Array[String]) -> void:
	(self.get_node("CanvasLayer/RiddlePrompt/QuestionLabel") as Label).text = question

	for i in range(4):
		(self.get_node("CanvasLayer/RiddlePrompt/ResponseButton%d" % (i + 1)) as Button).text = responses[i]


## Checks whether the player answered the current question correctly.
func _check_last_response() -> ResponseResult:
	if _last_response_id == _current_answer_id:
		return ResponseResult.CORRECT
	
	else:
		return ResponseResult.INCORRECT


func _async_give_first_question() -> void:
	## Update the UI with the question and responses.
	_update_riddle_prompt_ui("Question #1: What building has the most stories?", [
		"My house",
		"The library",
		"I don't know...",
		"Burj Khalifa",
	])

	# Mark which of the responses is the correct one.
	_current_answer_id = 2

	# Show the UI.
	_riddle_prompt.show()
	SceneManager.find_player_hud().hide()

	# Wait for the player to respond to the current question.
	await self.player_responded

	# Get the result of the response.
	var res := _check_last_response()

	# Puzzlemaster takes damage if the player is correct.
	if res == ResponseResult.CORRECT:
		print_debug("CORRECT")

		_puzzlemaster_health_component.take_damage(1)

	# The player takes damage if they are incorrect.
	else:
		print_debug("INCORRECT")

		SceneManager.find_player().health_component.take_damage(2)

	# TODO: Move on to the next question.
	# TODO: Replace this method with an `_async_give_next_question` method that
	# uses a system of queues to determine the next question, answers, and `_current_answer_id`.

	# Placeholder:
	_riddle_prompt.hide()
	# Placeholder:
	SceneManager.find_player_hud().show()
	# Placeholder:
	SceneManager.end_cutscene()

