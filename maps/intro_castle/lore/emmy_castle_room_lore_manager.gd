extends Node2D

@export var _cutscene_dialog: Array[DialogResource] = []

@onready var _hitbox: Area2D = self.get_node("HitboxArea")

var _player: Player

func _ready() -> void:
	_hitbox.area_entered.connect(_on_area_entered_hitbox)
	_player = SceneManager.find_player()


func _on_area_entered_hitbox(other_hitbox: Area2D) -> void:
	if other_hitbox.is_in_group("player_hitbox"):
		await _async_show_emmy_castle_room_cutscene()


func _async_show_emmy_castle_room_cutscene() -> void:
	_player.disable_actions()

	await SceneManager.async_delay(1.0)

	for dialog in _cutscene_dialog:
		# Temporary fix; long-term solution is to make the player not be able to move if there 
		# is a dialog currently being shown.
		_player.disable_actions() 

		# This is needed so that the `DialogManager` isn't "overwhelmed".
		await SceneManager.async_delay(0.5)

		DialogManager.start_dialog(dialog)
		await DialogManager.ended_dialog

	_player.enable_actions()

	# TODO: Show some other transition to show that time has passed.
	# Go to the scene where the player discovers what the Queen is doing and fights her.
	SceneManager.load_scene_file("res://maps/intro_castle/boss_fight/intro_castle_queen_boss_fight.tscn")


