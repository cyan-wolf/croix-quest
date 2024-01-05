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

var _number_of_questions_left := 5

var _question_stack: Array = []

func _ready() -> void:
	self.get_node("PuzzlemasterNPCs/DialogNPC").show()
	_riddle_prompt.hide()

	self.get_node("../Props/TeleportersCollection/Teleporter9") \
		.used \
		.connect(_async_start_puzzlemaster_riddles)

	SceneManager.find_player().respawn_component.respawned.connect(_on_player_respawn)

	_setup_response_buttons()

	_load_question_stack()


func _setup_response_buttons() -> void:
	for i in range(4):
		(self.get_node("CanvasLayer/RiddlePrompt/ResponseButton%d" % (i + 1)) as Button) \
			.pressed \
			.connect(func():
				_last_response_id = (i + 1)
				self.player_responded.emit()
				)


func _load_question_stack() -> void:
	const QUESTIONS_JSON_PATH := "res://maps/dungeons/dunkel_dungeon/lore/riddles/questions.json"

	var file := FileAccess.open(QUESTIONS_JSON_PATH, FileAccess.READ)
	var data: Array = JSON.parse_string(file.get_as_text())

	_question_stack = data


# Reset the boss fight in case the player respawns.
func _on_player_respawn() -> void:
	self.get_node("PuzzlemasterNPCs/DialogNPC").show()
	_hide_riddle_ui()
	_load_question_stack() # reload questions from disk


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

	_async_give_next_question() # async call


## The `responses` argument must have length `4`.
func _update_riddle_prompt_ui(prompt: String, responses: Array) -> void:
	(self.get_node("CanvasLayer/RiddlePrompt/PromptLabel") as Label).text = prompt

	for i in range(4):
		(self.get_node("CanvasLayer/RiddlePrompt/ResponseButton%d" % (i + 1)) as Button).text = responses[i]


## Checks whether the player answered the current question correctly.
func _check_last_response() -> ResponseResult:
	if _last_response_id == _current_answer_id:
		return ResponseResult.CORRECT
	
	else:
		return ResponseResult.INCORRECT


func _get_next_question() -> Dictionary:
	return _question_stack.pop_back() as Dictionary


func _show_riddle_ui() -> void:
	_riddle_prompt.show()
	SceneManager.find_player_hud().hide()


func _hide_riddle_ui() -> void:
	_riddle_prompt.hide()
	SceneManager.find_player_hud().show()


func _async_give_next_question() -> void:
	var next_question := _get_next_question()

	# print_debug(next_question["prompt"])
	# print_debug(next_question["responses"])

	## Update the UI with the question and responses.
	_update_riddle_prompt_ui(
		next_question["prompt"], 
		next_question["responses"],
	)

	# Mark which of the responses is the correct one.
	_current_answer_id = next_question["answer_id"]

	_show_riddle_ui()

	# Wait for the player to respond to the current question.
	await self.player_responded

	# Get the result of the response.
	var res := _check_last_response()

	# Puzzlemaster takes damage if the player is correct.
	if res == ResponseResult.CORRECT:
		_hide_riddle_ui()
		await SceneManager.async_delay(0.5)
		_puzzlemaster_health_component.take_damage(1)
		await SceneManager.async_delay(0.5)

		DialogManager.start_dialog(DialogResource.create("Puzzlemaster", [
			"...",
			"Ouch.",
			"CORRECT.",
		]))

		await DialogManager.ended_dialog

	# The player takes damage if they are incorrect.
	else:
		_hide_riddle_ui()
		await SceneManager.async_delay(0.5)
		SceneManager.find_player().health_component.take_damage(2)
		await SceneManager.async_delay(0.5)

		DialogManager.start_dialog(DialogResource.create("Puzzlemaster", [
			"...",
			"INCORRECT.",
		]))

		await DialogManager.ended_dialog

	# TODO: Move on to the next question.
	# TODO: Replace this method with an `_async_give_next_question` method that
	# uses a system of queues to determine the next question, answers, and `_current_answer_id`.
	_number_of_questions_left -= 1

	if _number_of_questions_left > 0:
		_async_give_next_question() # async call

	elif _number_of_questions_left == 0:
		# The end of the boss fight.
		_async_handle_ending() # async call

	
func _async_handle_ending() -> void:
	_hide_riddle_ui()

	await SceneManager.async_delay(0.5)

	var puzzlemaster_npc := self.get_node("PuzzlemasterNPCs/DialogNPC")

	if _puzzlemaster_health_component.get_health() > 0:
		DialogManager.start_dialog(DialogResource.create("Puzzlemaster", [
			"...",
			"You weren't able to defeat me.",
			"I'm disappointed in you.",
			"I would continue the questions, but...",
			"I can't think of anymore questions, so... bye!"
		]))

		await DialogManager.ended_dialog

	else:
		DialogManager.start_dialog(DialogResource.create("Puzzlemaster", [
			"...",
			"You were able to defeat me.",
			"I'm proud of you.",
			"I can't die yet though, there are still puzzles to be made.",
			"I'm going to leave for a moment to rest, so... bye!"
		]))

		await DialogManager.ended_dialog

	await SceneManager.async_delay(1.0)

	puzzlemaster_npc.hide()

	self.get_node("Spotlights/PointLight2D").hide()
	self.get_node("Spotlights/PointLight2D2").hide()

	_lore_manager.set_dungeon_light_level(DunkelLoreManager.SceneLightLevel.NORMAL)

	SceneManager.end_cutscene()

