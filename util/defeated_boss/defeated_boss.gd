extends Node2D

const FOREST_SPIRIT_AFTER_DEFEAT := preload("res://util/forest_spirit_after_boss_defeat/forest_spirit_after_boss_defeat.tscn")

@onready var _sprite: AnimatedSprite2D = self.get_node("AnimatedSprite2D")
@onready var _boss_implosion_particles: GPUParticles2D = self.get_node("BossImplosionParticles")
@onready var _boss_burst_particles: GPUParticles2D = self.get_node("BossBurstParticles")

@export var _milestone_after_boss_defeat: Util.Milestone
@export_file("*.tscn") var _forest_spirit_sprite_scene_path: String

func _ready():
	# Stop playing the music that started when the boss appeared.
	SceneManager.stop_playing_background_music()

	SceneManager.add_world_state(Util.WorldState.CUTSCENE_PLAYING)

	await SceneManager.async_delay(1.0)

	# SFX for boss dying
	_boss_burst_particles.emitting = true
	_boss_implosion_particles.emitting = true
	_sprite.hide()

	await SceneManager.async_delay(1.5)

	# SFX for the player rescuing the forest spirit.
	var forest_spirit := FOREST_SPIRIT_AFTER_DEFEAT.instantiate()
	forest_spirit.global_position = self.global_position
	self.get_tree().current_scene.add_child(forest_spirit)
	forest_spirit.async_land_on_player(
		load(_forest_spirit_sprite_scene_path)
	)

	# Wait for the forest spirit to land on the player.
	await forest_spirit.landed

	await SceneManager.async_delay(0.5)

	# Update the game's state.
	SceneManager.progression().add_milestone(_milestone_after_boss_defeat)

	SceneManager.remove_world_state(Util.WorldState.CUTSCENE_PLAYING)

	# Go to the hub.
	SceneManager.load_scene_file(Util.ScenePath.HIDEOUT_HUB)

