extends Node2D

@onready var _tutorial_prompt: Control = self.get_node("CanvasLayer/TutorialPrompt")
@onready var _player: Player = SceneManager.find_player()

@export var _shooting_tutorial_dialog: DialogResource
@export var _enemy_shooting_tutorial_dialog: DialogResource
@export var _checkpoint_tutorial_dialog: DialogResource
@export var _respawn_tutorial_dialog: DialogResource
@export var _item_pickup_tutorial_dialog: DialogResource
@export var _mana_tutorial_dialog: DialogResource

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
	# Allows the player to move again.
	SceneManager.remove_world_state(Util.WorldState.CUTSCENE_PLAYING)
	_tutorial_prompt.hide()

	# "Teleport" the player to the tutorial area.
	SceneManager.show_loading_screen()
	_player.global_position = self.get_node("TutorialStartPosition").global_position
	await SceneManager.async_delay(0.2)
	SceneManager.hide_loading_screen()

	# The first part of the tutorial.
	await SceneManager.async_delay(0.5)
	DialogManager.start_dialog(_shooting_tutorial_dialog)


# Skips the tutorial.
func _on_tutorial_skip_button_pressed() -> void:
	# Allows the player to move again.
	SceneManager.remove_world_state(Util.WorldState.CUTSCENE_PLAYING)
	_tutorial_prompt.hide()


# The 'Enemy Shooting' (second) part of the tutorial.
func _async_on_start_enemy_shooting_tutorial(other_hitbox: Area2D) -> void:
	if other_hitbox.is_in_group("player_ground_hitbox"):
		await SceneManager.async_delay(1.0)
		DialogManager.start_dialog(_enemy_shooting_tutorial_dialog)
		self.get_node("EnemyShootingTutorialHitboxArea").hide()


# The 'Checkpoint' (third) part of the tutorial.
func _async_on_start_checkpoint_tutorial() -> void:
	print_debug("TODO: start checkpoint tutorial")


