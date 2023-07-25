extends Node2D

@export var _should_show_lore_cutscene: bool = true
@export var _lore_dialogs: Array[DialogResource] = []
## Dialog given to the player after the "lore rects" are over.
@export var _final_intro_dialog: DialogResource 

var _player: Player
var _camera: Camera2D

# TODO: Replace these `ColorRect`s with `TextureRect`s that display the lore using pixel art.
var _ui_lore_rects: Array[ColorRect] = []

func _ready() -> void:
	# Initialize fields.
	_setup()

	if _should_show_lore_cutscene:
		await _async_show_lore_cutscene()

	SceneManager.play_background_music("res://sounds/music/Hero Immortal/Hero Immortal.mp3")

	
func _setup() -> void:
	_player = SceneManager.find_player()
	_camera = SceneManager.find_camera()

	for lore_rect in self.get_node("CanvasLayer/LoreRects").get_children():
		# TODO: Replace with `TextureRect`.
		_ui_lore_rects.push_back(lore_rect as ColorRect)


func _async_show_lore_rects() -> void:
	for lore_rect in _ui_lore_rects:
		lore_rect.show()
		
		# Read the "lore dialogs" in ascending order.
		DialogManager.start_dialog(_lore_dialogs.pop_front())

		# Wait for the current dialog to end before starting the next one.
		await DialogManager.ended_dialog

		# This delay is needed, because otherwise the dialog box doesn't activate.
		await SceneManager.async_delay(0.5)

		lore_rect.hide()


func _async_show_lore_cutscene() -> void:
	# Player can no longer move.
	_player.disable_actions()

	# Introductory exposition with complementary visuals.
	await _async_show_lore_rects()

	await SceneManager.async_delay(1.0)

	DialogManager.start_dialog(_final_intro_dialog)
	await DialogManager.ended_dialog

	# TODO: Add more lore and story events here.

	_player.enable_actions()


