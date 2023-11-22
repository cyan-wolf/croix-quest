extends Control

func _ready() -> void:
	# Connect signals.
	self.get_node("PauseScreenElements/ResumeGameButton").pressed.connect(_on_resume_game_button_pressed)
	self.get_node("PauseScreenElements/SettingsButton").pressed.connect(_on_settings_button_pressed)
	self.get_node("PauseScreenElements/QuitButton").pressed.connect(_on_quit_button_pressed)

	self.get_node("SettingsMenuElements/BackButton").pressed.connect(_on_settings_screen_back_button_pressed)


func _on_resume_game_button_pressed() -> void:
	_reset_ui()


func _on_settings_button_pressed() -> void:
	# Switch from the pause menu UI to the settings UI.
	self.get_node("PauseScreenElements").hide()
	self.get_node("SettingsMenuElements").show()


func _on_quit_button_pressed() -> void:
	_reset_ui()

	# Go to the main menu.
	SceneManager.load_scene_file("res://ui/menus/main_menu.tscn")


func _on_settings_screen_back_button_pressed() -> void:
	# Switch from the settings UI to the pause menu UI.
	self.get_node("PauseScreenElements").show()
	self.get_node("SettingsMenuElements").hide()


# Resets various UIs to their previous states after the pause screen is done being used.
func _reset_ui() -> void:
	# Unpause the game.
	self.get_tree().paused = false

	# Hide the pause screen.
	self.hide()

	# Show the Player HUD again since it was hidden by `SceneManager`.
	SceneManager.find_player_hud().show()
