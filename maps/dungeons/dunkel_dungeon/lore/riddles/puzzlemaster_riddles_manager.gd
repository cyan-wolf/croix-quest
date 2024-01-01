extends Node2D

const DunkelLoreManager := preload("res://maps/dungeons/dunkel_dungeon/lore/dunkel_dungeon_lore_manager.gd")

@export var _puzzlemaster_health_component: HealthComponent

@onready var _riddle_prompt: Control = self.get_node("CanvasLayer/RiddlePrompt")
@onready var _puzzlemaster_boss_health_bar: BossHealthBar = self.get_node("CanvasLayer/BossHeathBar")

@onready var _lore_manager: DunkelLoreManager = self.get_node("../DunkelDungeonLoreManager")

func _ready() -> void:
	_riddle_prompt.hide()

	self.get_node("../Props/TeleportersCollection/Teleporter9") \
		.used \
		.connect(_async_start_puzzlemaster_riddles)


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

	#SceneManager.end_cutscene()


## The `responses` argument must have length `4`.
func _update_riddle_prompt_ui(question: String, responses: Array[String]) -> void:
	(self.get_node("CanvasLayer/RiddlePrompt/QuestionLabel") as Label).text = question

	for i in range(4):
		(self.get_node("CanvasLayer/RiddlePrompt/ResponseButton%d" % (i + 1)) as Button).text = responses[i]


func _async_give_first_question() -> void:
	# update riddle prompt UI with the riddle question + responses
	_update_riddle_prompt_ui("Question #1: What building has the most stories?", [
		"My house",
		"The library",
		"I don't know...",
		"Burj Khalifa",
	])

	_riddle_prompt.show()
	SceneManager.find_player_hud().hide()

	# TODO: set which will be the correct response
	
	pass

