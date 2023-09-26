extends Node2D

# Tells the boss fight manager when to start the boss fight.
signal start_boss_fight

@export var _dialog_before_teleporting_spirits: Array[DialogResource] = []
@export var _dialog_after_teleporting_spirits: Array[DialogResource] = []

@onready var _player: Player = SceneManager.find_player()

# Not part of this scene; needs to be added manually.
# This sprite is only for the cutscene, it's not the boss itself.
@onready var _queen_sprite: AnimatedSprite2D = self.get_node("QueenCroixNPCSprite")

func _ready() -> void:
	_setup_forest_spirits()

	await _async_show_cutscene_before_boss_fight()
	self.start_boss_fight.emit()


func _setup_forest_spirits() -> void:
	# Not part of this scene; needs to be added manually.
	for spirit in self.get_node("ForestSpirits").get_children():
		var forest_spirit_sprite: AnimatedSprite2D = spirit.get_node("AnimatedSprite")

		forest_spirit_sprite.play("idle")

	# Show this node since it's normally hidden in the inspector.
	self.get_node("ForestSpirits").show()


func _teleport_away_forest_spirits() -> void:
	# Not part of this scene; needs to be added manually.
	for spirit in self.get_node("ForestSpirits").get_children():
		var forest_spirit_sprite: AnimatedSprite2D = spirit.get_node("AnimatedSprite")
		var teleport_particle_emitter: GPUParticles2D = spirit.get_node("queen_boss_teleport_particles")

		forest_spirit_sprite.hide()
		teleport_particle_emitter.emitting = true


func _async_show_cutscene_before_boss_fight() -> void:
	for dialog in _dialog_before_teleporting_spirits:
		DialogManager.start_dialog(dialog)
		await DialogManager.ended_dialog

	SceneManager.add_world_state(Util.WorldState.CUTSCENE_PLAYING)
	
	# This delay is needed, because otherwise the dialog box doesn't activate.
	await SceneManager.async_delay(0.5)

	_teleport_away_forest_spirits()

	await SceneManager.async_delay(3.0)

	for dialog in _dialog_after_teleporting_spirits:
		DialogManager.start_dialog(dialog)
		await DialogManager.ended_dialog

		# This delay is needed, because otherwise the dialog box doesn't activate.
		await SceneManager.async_delay(0.5)

	# Hide the cutscene version of the queen in order to spawn the boss version elsewhere.
	_queen_sprite.hide()

	SceneManager.remove_world_state(Util.WorldState.CUTSCENE_PLAYING)


