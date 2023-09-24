extends Control

@onready var _respawn_button: Button = self.get_node("RespawnButton")

@onready var _quit_button: Button = self.get_node("QuitButton")

func _ready() -> void:
	_respawn_button.pressed.connect(_on_respawn_button_pressed)
	_quit_button.pressed.connect(_on_quit_button_pressed)


func _on_respawn_button_pressed() -> void:
	# Make the player respawn.
	SceneManager.find_player().respawn()

	# Hide the game over screen.
	self.hide()


func _on_quit_button_pressed() -> void:
	# Go to the main menu.
	SceneManager.load_scene_file("res://ui/menus/main_menu.tscn")

