extends Node2D

@export var _lore_dialogs: Array[DialogResource] = []

var _player: Player
var _camera: Camera2D

# TODO: Replace these `ColorRect`s with `TextureRect`s that display the lore using pixel art.
var _ui_lore_rects: Array[ColorRect] = []

func _ready() -> void:
	# Initialize fields.
	_setup()

	_player.disable_actions()

	await _async_show_lore_rects()

	await SceneManager.async_delay(1.0)

	_player.enable_actions()

	# TODO: Add more lore and story events here.

	
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


