extends Control

@export_file("*.tscn") var _new_game_scene: String
@export_file("*.tscn") var _settings_menu_scene: String

@onready var _new_game_button: Button = self.get_node("NewGameButton")
@onready var _settings_button: Button = self.get_node("SettingsButton")

func _ready() -> void:
	_new_game_button.pressed.connect(_on_new_game_button_pressed)
	_settings_button.pressed.connect(_on_settings_button_pressed)

	SceneManager.play_background_music("res://sounds/music/House In A Forest Loop/House In A Forest Loop.mp3")


func _on_new_game_button_pressed() -> void:
	SceneManager.stop_playing_background_music()
	
	SceneManager.load_scene_file(_new_game_scene)


func _on_settings_button_pressed() -> void:
	SceneManager.load_scene_file(_settings_menu_scene)


