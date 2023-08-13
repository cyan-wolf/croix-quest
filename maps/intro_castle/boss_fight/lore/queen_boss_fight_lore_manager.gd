extends Node2D

# Tells the boss fight manager when to start the boss fight.
signal start_boss_fight

@export var _temp_lore_dialog: Array[DialogResource] = []

@onready var _player: Player = SceneManager.find_player()

# Not part of this scene; needs to be added manually.
# This sprite is only for the cutscene, it's not the boss itself.
@onready var _queen_sprite: AnimatedSprite2D = self.get_node("QueenCroixNPCSprite")

func _ready() -> void:
	await _async_show_cutscene_before_boss_fight()
	self.start_boss_fight.emit()


# TODO: Add the actual cutscene that happens before the boss fight.
func _async_show_cutscene_before_boss_fight() -> void:
	for dialog in _temp_lore_dialog:
		DialogManager.start_dialog(dialog)
		await DialogManager.ended_dialog

		# This delay is needed, because otherwise the dialog box doesn't activate.
		await SceneManager.async_delay(0.5)

	# Hide the cutscene version of the queen in order to spawn the boss version elsewhere.
	_queen_sprite.hide()


