extends Node2D

@export var _player_waking_up_dialog: DialogResource

@onready var _town_teleport_hitbox: Area2D = self.get_node("TeleporterToTownHitboxArea")

const CUTSCENE_DIALOG_DELAY := 1.3

func _ready() -> void:
	_town_teleport_hitbox.area_entered.connect(_on_area_entered_town_teleport_hitbox)

	SceneManager.add_world_state(Util.WorldState.CUTSCENE_PLAYING)

	await SceneManager.async_delay(CUTSCENE_DIALOG_DELAY)

	await _async_show_cutscene_after_queen_fight()

	SceneManager.remove_world_state(Util.WorldState.CUTSCENE_PLAYING)


func _on_area_entered_town_teleport_hitbox(other_hitbox: Area2D) -> void:
	if other_hitbox.is_in_group("player_hitbox"):
		# Go the town area outside the castle to continue the story.
		SceneManager.load_scene_file(
				"res://maps/intro_area_outside_castle/town_outside_castle/town_outside_castle.tscn"
		)


func _async_show_cutscene_after_queen_fight() -> void:
	DialogManager.start_dialog(_player_waking_up_dialog)
	await DialogManager.ended_dialog

