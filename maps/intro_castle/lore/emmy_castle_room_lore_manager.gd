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
	SceneManager.add_world_state(Util.WorldState.CUTSCENE_PLAYING)

	await SceneManager.async_delay(1.0)

	for dialog in _cutscene_dialog:
		# This is needed so that the `DialogManager` isn't "overwhelmed".
		await SceneManager.async_delay(0.5)

		DialogManager.start_dialog(dialog)
		await DialogManager.ended_dialog

	SceneManager.remove_world_state(Util.WorldState.CUTSCENE_PLAYING)

	# TODO: Show some other transition to show that time has passed.
	# Go to the scene where the player discovers what the Queen is doing and fights her.
	SceneManager.load_scene_file("res://maps/intro_castle/boss_fight/queen_boss_fight_prelude.tscn")


