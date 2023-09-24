extends Node2D

@onready var _loading_screen: Control = self.get_node("CanvasLayer/LoadingScreen")
@onready var _background_music_player: AudioStreamPlayer = self.get_node("BackgroundMusicPlayer")

@export var _should_mute_game_volume_on_start := false

func _ready() -> void:
	if _should_mute_game_volume_on_start:
		print_debug(
			"Warning: Game volume is currently muted. Open the `SceneManager` scene to unmute. "
			+ "Disable the `_should_mute_game_volume_on_start` export variable to unmute."
		)

		AudioServer.set_bus_volume_db(
			AudioServer.get_bus_index("Master"),
			linear_to_db(0.0),
		)


func load_scene_file(scene_path: String) -> void:
	self.show_loading_screen()
	self.get_tree().change_scene_to_file(scene_path)

	# Show the loading screen while the scene is loading.
	# Hide it again after the scene has loaded.
	var callback: Callable = (func():
		await self.get_tree().tree_changed
		await self.async_delay(0.5)
		
		self.hide_loading_screen()
	)

	callback.call()


func load_packed_scene(scene: PackedScene) -> void:
	self.load_scene_file(scene.resource_path)


func find_player() -> Player:
	return self.get_tree().current_scene.get_node("Player") as Player


func find_camera() -> Camera2D:
	return self.get_viewport().get_camera_2d()


func async_delay(delay_in_secs: float) -> void:
	await self.get_tree().create_timer(delay_in_secs).timeout


func show_loading_screen() -> void:
	_loading_screen.show()

	# The player should not be able to do anything if the loading screen is visible.
	var player := self.find_player()
	if player != null:
		player.disable_actions()


func hide_loading_screen() -> void:
	_loading_screen.hide()

	# Re-enable player actions once the "loading" is finished.
	var player := self.find_player()
	if player != null:
		player.enable_actions()


func show_game_over_screen() -> void:
	print_debug("TODO")
	# _game_over_screen.show()


func hide_game_over_screen() -> void:
	print_debug("TODO")
	# NOTE: This function might not be necessary.
	# _game_over_screen.hide()


func play_background_music(audio_track_file: String) -> void:
	var audio_track: AudioStream = load(audio_track_file)
	_background_music_player.stream = audio_track
	_background_music_player.play()


func stop_playing_background_music() -> void:
	_background_music_player.stop()

