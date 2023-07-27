extends Node2D

# The dialog representing the player talking with the other guard there at the start.
@export var _player_conversation_with_guard_dialog: Array[DialogResource]

# The dialog shown to the player representing screeches when approaching the Queen's room.
@export var _strange_sounds_in_hall_dialog: Array[DialogResource]

var _player: Player

func _ready() -> void:
	_player = SceneManager.find_player()

	await _async_show_queen_boss_fight_prelude_cutscene()


func _async_show_queen_boss_fight_prelude_cutscene() -> void:
	_player.disable_actions()

	await SceneManager.async_delay(1.0)

	for dialog in _player_conversation_with_guard_dialog:
		# Temporary fix; long-term solution is to make the player not be able to move if there 
		# is a dialog currently being shown.
		_player.disable_actions() 

		# This is needed so that the `DialogManager` isn't "overwhelmed".
		await SceneManager.async_delay(0.5)

		DialogManager.start_dialog(dialog)
		await DialogManager.ended_dialog

	_player.enable_actions()




