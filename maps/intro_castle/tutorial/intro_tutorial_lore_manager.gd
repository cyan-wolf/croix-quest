extends Node2D

@onready var _tutorial_prompt: Control = self.get_node("CanvasLayer/TutorialPrompt")
@onready var _player: Player = SceneManager.find_player()

@export var _shooting_tutorial_dialog: DialogResource
@export var _enemy_shooting_tutorial_dialog: DialogResource
@export var _checkpoint_tutorial_dialog: DialogResource
@export var _checkpoint_tutorial_dialog2: DialogResource
@export var _respawn_tutorial_dialog: DialogResource
@export var _item_pickup_tutorial_dialog: DialogResource
@export var _mana_tutorial_dialog: DialogResource

# The spawn position of the player in the 'Intro Castle' scene.
var _player_original_spawn_position: Vector2

func _ready() -> void:
	# Connect signals.
	self.get_node("../GuardCaptainNPC").dialog_ended.connect(_on_beginning_captain_npc_dialog_ended)
	_tutorial_prompt.get_node("TutorialButton").pressed.connect(_async_on_tutorial_start_button_pressed)
	_tutorial_prompt.get_node("SkipButton").pressed.connect(_on_tutorial_skip_button_pressed)

	# Connect signal to start the second part of the tutorial.
	self.get_node("EnemyShootingTutorialHitboxArea").area_entered.connect(_async_on_start_enemy_shooting_tutorial)

	# Connect signal to start the third part of the tutorial.
	self.get_node("TauronWorshiperMeleeEnemy/EnemyComponent") \
		.health_component.death.connect(_async_on_start_checkpoint_tutorial)

	# Connect signal to end the tutorial.
	self.get_node("TutorialEndHitbox").area_entered.connect(_async_on_end_tutorial)

	_player_original_spawn_position = _player.global_position


# Show the tutorial prompt after the Guard Captain stops talking
# after you right click on him.
func _on_beginning_captain_npc_dialog_ended() -> void:
	# Stops the player from moving when the prompt is visible.
	SceneManager.add_world_state(Util.WorldState.CUTSCENE_PLAYING)

	# Show the tutorial prompt.
	_tutorial_prompt.show()

	# Activate the teleporter that allows the player to continue with the story.
	self.get_node("../MainHallTeleporter").activate()


# Starts the tutorial.
func _async_on_tutorial_start_button_pressed() -> void:
	_tutorial_prompt.hide()

	# "Teleport" the player to the tutorial area.
	SceneManager.show_loading_screen()
	_player.global_position = self.get_node("TutorialStartPosition").global_position
	await SceneManager.async_delay(0.2)
	SceneManager.hide_loading_screen()

	# The first part of the tutorial.
	await SceneManager.async_delay(0.5)
	DialogManager.start_dialog(_shooting_tutorial_dialog)

	# Allows the player to move again.
	SceneManager.remove_world_state(Util.WorldState.CUTSCENE_PLAYING)


# Skips the tutorial.
func _on_tutorial_skip_button_pressed() -> void:
	# Allows the player to move again.
	SceneManager.remove_world_state(Util.WorldState.CUTSCENE_PLAYING)
	_tutorial_prompt.hide()


# The 'Enemy Shooting' (second) part of the tutorial.
func _async_on_start_enemy_shooting_tutorial(other_hitbox: Area2D) -> void:
	if other_hitbox.is_in_group("player_ground_hitbox"):
		SceneManager.start_cutscene()

		await SceneManager.async_delay(1.0)
		DialogManager.start_dialog(_enemy_shooting_tutorial_dialog)

		self.get_node("EnemyShootingTutorialHitboxArea/CollisionShape2D") \
			.set_deferred("disabled", true)

		SceneManager.end_cutscene()


# The 'Checkpoint' (third) part of the tutorial.
func _async_on_start_checkpoint_tutorial() -> void:
	SceneManager.start_cutscene()

	await SceneManager.async_delay(1.0)

	# "Teleport" the player to the tutorial area.
	SceneManager.show_loading_screen()
	_player.global_position = self.get_node("CheckpointTutorialPosition").global_position
	await SceneManager.async_delay(0.2)
	SceneManager.hide_loading_screen()

	# Show the dialog.
	await SceneManager.async_delay(1.0)
	DialogManager.start_dialog(_checkpoint_tutorial_dialog)

	SceneManager.end_cutscene()

	# Wait until the player has used the checkpoint before continuing.
	await self.get_node("Checkpoint").activated

	SceneManager.start_cutscene()

	# Dialog of the captain explaining that he's going to attack the player.
	DialogManager.start_dialog(_checkpoint_tutorial_dialog2)
	await DialogManager.ended_dialog

	var captain_npc: Node2D = self.get_node("GuardCaptiainNPCs/DialogNPC3")

	# Move and wait for the captain to move to "attack" the player.
	await self.create_tween().tween_property(
		captain_npc, 
		"global_position", 
		_player.global_position + (Vector2.RIGHT * 1 * 16),
		0.8,
	).finished

	# The captain "attacking" the player.
	for _i in range(8):
		_player.health_component.take_damage(1)
		await SceneManager.async_delay(0.35)

	SceneManager.end_cutscene()

	# Wait for the player to respawn.
	await _player.respawn_component.respawned

	DialogManager.start_dialog(_respawn_tutorial_dialog)
	await DialogManager.ended_dialog

	# Go to the next part of the tutorial.
	_async_on_start_item_pickup_tutorial() # async call


# The 'Item Pickup' (fourth) part of the tutorial.
func _async_on_start_item_pickup_tutorial() -> void:
	SceneManager.start_cutscene()

	await SceneManager.async_delay(1.0)

	# "Teleport" the player to the tutorial area.
	SceneManager.show_loading_screen()
	_player.global_position = self.get_node("ItemPickupTutorialPosition").global_position
	await SceneManager.async_delay(0.2)
	SceneManager.hide_loading_screen()

	# Show the dialog.
	await SceneManager.async_delay(1.0)
	DialogManager.start_dialog(_item_pickup_tutorial_dialog)

	SceneManager.end_cutscene()

	# Wait until the player has used the checkpoint in the next area before continuing.
	await self.get_node("Checkpoint2").activated

	_async_on_start_mana_tutorial() # async call


# The 'Mana' (final) part of the tutorial.
func _async_on_start_mana_tutorial() -> void:
	SceneManager.start_cutscene()

	# Show the dialog.
	await SceneManager.async_delay(1.0)
	DialogManager.start_dialog(_mana_tutorial_dialog)

	SceneManager.end_cutscene()


# Ends the tutorial.
func _async_on_end_tutorial(other_hitbox: Area2D) -> void:
	if other_hitbox.is_in_group("player_ground_hitbox"):
		
		# "Teleport" the player to the original spawn position (exits the tutorial).
		SceneManager.show_loading_screen()
		_player.global_position = _player_original_spawn_position

		# Reset the starting checkpoint position since it's like the player went to a new scene.
		_player.checkpoint_component.initialize(_player_original_spawn_position)

		await SceneManager.async_delay(0.2)
		SceneManager.hide_loading_screen()

