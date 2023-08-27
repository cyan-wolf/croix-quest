extends Node2D

@export var _player_waking_up_dialog: DialogResource

func _ready() -> void:
	await _async_show_cutscene_after_queen_fight()


func _async_show_cutscene_after_queen_fight() -> void:
	DialogManager.start_dialog(_player_waking_up_dialog)
	await DialogManager.ended_dialog

