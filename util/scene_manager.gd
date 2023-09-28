extends Node2D

@onready var _loading_screen: Control = self.get_node("CanvasLayer/LoadingScreen")
@onready var _game_over_screen: Control = self.get_node("CanvasLayer/GameOverScreen")
@onready var _background_music_player: AudioStreamPlayer = self.get_node("BackgroundMusicPlayer")

@export var _should_mute_game_volume_on_start := false

# This is actually a hash set (i.e. a Dictionary[Util.WorldState, null]).
var _world_state: Dictionary = {}

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


func find_player_hud() -> Control:
	return self.get_tree().current_scene.get_node("CanvasLayer/PlayerHUD") as Control


func async_delay(delay_in_secs: float) -> void:
	await self.get_tree().create_timer(delay_in_secs).timeout


func add_world_state(state: Util.WorldState) -> void:
	# This is a HashSet so the values are null.
	_world_state[state] = null


func remove_world_state(state: Util.WorldState) -> void:
	_world_state.erase(state)


## This function returning `true` implies that the player should be able to move normally.
## Otherwise, the player should not be able to move.
func is_world_state_empty() -> bool:
	return _world_state.is_empty()


func show_loading_screen() -> void:
	_loading_screen.show()

	# The player should not be able to do anything if the loading screen is visible.
	var player := self.find_player()
	if player != null:
		self.add_world_state(Util.WorldState.LOADING_SCREEN_VISIBLE)


func hide_loading_screen() -> void:
	_loading_screen.hide()

	# Re-enable player actions once the "loading" is finished.
	var player := self.find_player()
	if player != null:
		self.remove_world_state(Util.WorldState.LOADING_SCREEN_VISIBLE)


func show_game_over_screen() -> void:
	# Hide the Player HUD, because otherwise the game over screen can't be used.
	self.find_player_hud().hide()
	
	_game_over_screen.show()


func play_background_music(audio_track_file: String) -> void:
	var audio_track: AudioStream = load(audio_track_file)
	_background_music_player.stream = audio_track
	_background_music_player.play()


func stop_playing_background_music() -> void:
	_background_music_player.stop()

