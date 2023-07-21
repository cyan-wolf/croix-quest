extends CanvasLayer

signal continue_dialog
signal started_dialog
signal ended_dialog

# The delay between each time a character in the dialog is rendered.
@export var _dialog_character_delay_in_secs: float = 0.01

var _current_author: String = ""
var _dialog_queue: Array[String] = []
var _currently_showing_dialog := false

@onready var _dialog_label: RichTextLabel = $DialogBoxRect/DialogLabel
@onready var _author_label: RichTextLabel = $DialogBoxRect/AuthorLabel
@onready var _continue_hint_label: RichTextLabel = $DialogBoxRect/ContinueHintLabel

func _ready() -> void:
	$DialogBoxRect.hide()

	# Hides it seperately so that it isn't visible the first time the 
	# dialog box appears.
	_continue_hint_label.hide()


# Detects when the player presses 'R' (in order to advance the dialog).
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("continue_dialog"):
		self.continue_dialog.emit()


# Starts a dialog using the given author and dialog values.
# Does not do anything if there is currently a dialog in progress.
# NOTE: The dialog array is copied inside of the function.
func start_dialog(dialog_resource: DialogResource) -> void:
	if not _currently_showing_dialog:
		_current_author = dialog_resource.author
		_dialog_queue = dialog_resource.dialog.duplicate()

		_async_show_current_dialog()


func _async_show_current_dialog():
	$DialogBoxRect.show()
	self.started_dialog.emit()
	_currently_showing_dialog = true

	_author_label.text = self.get_current_author()

	for _i in range(self.dialog_queue_length()):
		var text := _pop_text_from_queue()

		_dialog_label.visible_characters = 0
		_dialog_label.text = text

		# Shows each part of the dialog.
		for j in range(1, len(text) + 1):
			await self.get_tree().create_timer(_dialog_character_delay_in_secs).timeout
			_dialog_label.visible_characters = j

			# Skips the character-by-character dialog animation.
			if Input.is_action_pressed("skip_dialog"):
				_dialog_label.visible_characters = len(text)
				break

		# Waits to advance to the next part of the dialog.
		_continue_hint_label.show()
		await self.continue_dialog
		_continue_hint_label.hide()

	$DialogBoxRect.hide()
	self.ended_dialog.emit()
	_currently_showing_dialog = false


# Gets the next part of the dialog and removes it from the queue.
func _pop_text_from_queue() -> String:
	var dialog: String = _dialog_queue.pop_front()
	return dialog


func dialog_queue_length() -> int:
	return len(_dialog_queue)


func get_current_author() -> String:
	return _current_author

