extends Node2D

@onready var _loading_screen: Control = self.get_node("CanvasLayer/LoadingScreen")
@onready var _game_over_screen: Control = self.get_node("CanvasLayer/GameOverScreen")
@onready var _pause_screen: Control = self.get_node("CanvasLayer/PauseScreen")
@onready var _background_music_player: AudioStreamPlayer = self.get_node("BackgroundMusicPlayer")
@onready var _progression_manager: ProgressionManager = self.get_node("ProgressionManager")

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

func _process(_delta: float) -> void:
	# Does different things depending on what "debug key" was pressed.
	_handle_debug_keys()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_game") and not _pause_screen.visible:
		self.find_player_hud().hide()
		_pause_screen.show()
		self.get_tree().paused = true


## Loads the scene given by `scene_path` and unloads the previous scene.
## If `keep_player` is `true`, the player is moved from the previous scene to 
## the new one. The new scene must have a 'PlayerSpawnPosition' node to know 
## where to spawn the player, and the new scene must not already have a player.
func load_scene_file(scene_path: String, keep_player: bool = false) -> void:

	# Reference to the player if they need to be moved across scenes.
	var player_to_move: Player = null
	
	if keep_player:
		player_to_move = self.find_player()
		# Remove the player from the previous scene so they don't get freed.
		self.get_tree().current_scene.remove_child(player_to_move)

	self.show_loading_screen()
	self.get_tree().change_scene_to_file(scene_path)

	# Show the loading screen while the scene is loading.
	# Hide it again after the scene has loaded.
	var async_callback: Callable = (func():
		await self.get_tree().tree_changed
		await self.async_delay(0.5)
		
		if keep_player:
			var player_spawn_pos = self.get_tree() \
				.current_scene \
				.get_node("PlayerSpawnPosition") \
				.global_position

			# Move the player from the previous scene to the new one.
			player_to_move.global_position = player_spawn_pos
			player_to_move.checkpoint_component.initialize(player_spawn_pos)
			self.get_tree().current_scene.add_child(player_to_move)
		
		self.hide_loading_screen()
	)

	async_callback.call() # async call


func load_packed_scene(scene: PackedScene) -> void:
	self.load_scene_file(scene.resource_path)


func find_player() -> Player:
	return self.get_tree().current_scene.get_node("Player") as Player


func find_camera() -> Camera2D:
	return self.get_viewport().get_camera_2d()


func find_player_hud() -> Control:
	return self.find_player().get_node("CanvasLayer/PlayerHUD") as Control


func find_boss_health_bar() -> BossHealthBar:
	return self.get_tree().current_scene.get_node("CanvasLayer/BossHeathBar")


## Returns the `ProgressionManager`.
func progression() -> ProgressionManager:
	return _progression_manager


func async_shake_camera(amount: float, duration_in_secs: float) -> void:
	var camera := self.find_camera()

	var elapsed_duration_in_secs := 0.0

	var dt := 0.01 # in seconds

	while elapsed_duration_in_secs < duration_in_secs:
		randomize()

		var offset_x := randf() * amount
		var offset_y := randf() * amount

		camera.offset = Vector2(offset_x, offset_y)

		elapsed_duration_in_secs += dt
		await SceneManager.async_delay(dt)

	camera.offset = Vector2.ZERO


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

	# Pause the game while in the game over screen.
	self.get_tree().paused = true


func play_background_music(audio_track_file: String) -> void:
	var audio_track: AudioStream = load(audio_track_file)
	_background_music_player.stream = audio_track
	_background_music_player.play()


func stop_playing_background_music() -> void:
	_background_music_player.stop()


# Handles "debug key" presses.
func _handle_debug_keys() -> void:
	# Assume that the player is in the scene.
	var _player := self.find_player()

	# DEBUG: The player takes damage if the 'Number Pad 1' key is pressed.
	if Input.is_action_just_pressed("debug_1"):
		_player.health_component.take_damage(1)

	# DEBUG: The player uses up mana if the 'Number Pad 2' key is pressed.
	if Input.is_action_just_pressed("debug_2"):
		_player.mana_component.use_mana(1)

	# DEBUG: The player dies if the 'Number Pad 3' key is pressed.
	if Input.is_action_just_pressed("debug_3"):
		_player.health_component.take_damage(_player.health_component.get_health())

	# DEBUG: The player goes to the 'Test Dungeon' map if the 'Number Pad 4' key is pressed.
	if Input.is_action_just_pressed("debug_4"):
		self.load_scene_file("res://maps/dungeons/test_dungeon/test_dungeon.tscn")

	# DEBUG: The player goes to the 'Cobalt Dungeon' map if the 'Number Pad 5' key is pressed.
	if Input.is_action_just_pressed("debug_5"):
		self.load_scene_file("res://maps/dungeons/cobalt_dungeon/cobalt_dungeon.tscn")

	# DEBUG: Mutes the game volume if the 'Number Pad 6' key is pressed.
	if Input.is_action_just_pressed("debug_6"):
		AudioServer.set_bus_volume_db(
			AudioServer.get_bus_index("Master"),
			linear_to_db(0.0),
		)

	# DEBUG: Halves the game volume if the 'Number Pad 7' key is pressed.
	if Input.is_action_just_pressed("debug_7"):
		AudioServer.set_bus_volume_db(
			AudioServer.get_bus_index("Master"),
			linear_to_db(0.5),
		)

	# DEBUG: Maxes out the game volume if the 'Number Pad 8' key is pressed.
	if Input.is_action_just_pressed("debug_8"):
		AudioServer.set_bus_volume_db(
			AudioServer.get_bus_index("Master"),
			linear_to_db(1.0),
		)


	# DEBUG: Instantly defeats the current boss if the 'Number Pad 9' key is pressed.
	if Input.is_action_just_pressed("debug_9"):
		var current_boss_health_bar := self.find_boss_health_bar()

		if current_boss_health_bar != null:
			# WARNING: Accessing private fields for debug purposes.
			var boss_health_component := current_boss_health_bar._health_bar._health_component

			# Sets the boss' health to 0.
			boss_health_component.take_damage(boss_health_component.get_health())

		else:
			print_debug("WARNING: Cannot defeat boss as there is no boss in this scene.")

