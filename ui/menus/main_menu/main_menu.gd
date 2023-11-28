extends Control

@export_file("*.tscn") var _settings_menu_scene: String

@onready var _play_button: Button = self.get_node("PlayButton")
@onready var _settings_button: Button = self.get_node("SettingsButton")

func _ready() -> void:
	_play_button.pressed.connect(_on_play_button_pressed)
	_settings_button.pressed.connect(_on_settings_button_pressed)

	SceneManager.play_background_music("res://sounds/music/House In A Forest Loop/House In A Forest Loop.mp3")


func _on_play_button_pressed() -> void:
	SceneManager.stop_playing_background_music()
	
	# If the player hasn't completed the intro castle area, go there.
	if not SceneManager.progression().has_milestone(Util.Milestone.INTRO_CASTLE_COMPLETED):
		SceneManager.load_scene_file(Util.ScenePath.INTRO_CASTLE)
	
	# Otherwise, take the player to the hub.
	else:
		SceneManager.load_scene_file(Util.ScenePath.HIDEOUT_HUB)
	


func _on_settings_button_pressed() -> void:
	SceneManager.load_scene_file(_settings_menu_scene)


