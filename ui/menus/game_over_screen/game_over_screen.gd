extends Control

@onready var _respawn_button: Button = self.get_node("RespawnButton")

@onready var _quit_button: Button = self.get_node("QuitButton")

func _ready() -> void:
	_respawn_button.pressed.connect(_on_respawn_button_pressed)
	_quit_button.pressed.connect(_on_quit_button_pressed)


func _on_respawn_button_pressed() -> void:
	# Unpause the game, since it was paused before showing the game over screen.
	self.get_tree().paused = false

	# Make the player respawn.
	SceneManager.find_player().respawn()

	_reset_ui()


func _on_quit_button_pressed() -> void:
	# Unpause the game, since it was paused before showing the game over screen.
	self.get_tree().paused = false

	# Make the player respawn in order to reset any leftover state.
	SceneManager.find_player().respawn()

	# Go to the main menu.
	SceneManager.load_scene_file("res://ui/menus/main_menu.tscn")

	_reset_ui()


# Resets various UIs to their previous states after the game over screen is used.
func _reset_ui() -> void:
	# Hide the game over screen.
	self.hide()

	# Show the Player HUD again since it was hidden by `SceneManager`.
	SceneManager.find_player_hud().show()


