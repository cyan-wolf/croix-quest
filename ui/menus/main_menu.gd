extends Control

@export var _new_game_scene: PackedScene
@export var _settings_menu_scene: PackedScene

@onready var _new_game_button: Button = self.get_node("NewGameButton")
@onready var _settings_button: Button = self.get_node("SettingsButton")

func _ready() -> void:
	_new_game_button.pressed.connect(_on_new_game_button_pressed)
	_settings_button.pressed.connect(_on_settings_button_pressed)


func _on_new_game_button_pressed() -> void:
	self.get_tree().change_scene_to_packed(_new_game_scene)


func _on_settings_button_pressed() -> void:
	self.get_tree().change_scene_to_packed(_settings_menu_scene)


