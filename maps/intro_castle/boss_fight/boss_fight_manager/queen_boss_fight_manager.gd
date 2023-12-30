extends Node2D

const QueenBoss := preload("res://enemies/bosses/queen/queen_boss.gd")

@export var _queen_defeated_dialog: DialogResource

@onready var _player: Player = SceneManager.find_player()
@onready var _queen_boss_scene: PackedScene = preload("res://enemies/bosses/queen/queen_boss.tscn")

@onready var _queen_teleport_particle_emitter: GPUParticles2D = self.get_node("queen_boss_teleport_particles")
@onready var _queen_laser: Node2D = self.get_node("QueenLaser")

@onready var _queen_sprite: AnimatedSprite2D = self.get_node("../QueenBossFightLoreManager/QueenCroixNPCSprite")

var _queen_boss: QueenBoss

func _ready() -> void:
	self.get_node("../QueenBossFightLoreManager").start_boss_fight.connect(_on_start_boss_fight)


func _on_start_boss_fight() -> void:
	SceneManager.play_background_music("res://sounds/music/Orbital Colossus/Orbital Colossus.mp3")

	# Spawn the boss.
	_queen_boss = _queen_boss_scene.instantiate() as QueenBoss

	_queen_boss.global_position = self.get_node("BossFightSpawnPosition").global_position
	self.get_tree().current_scene.add_child(_queen_boss)

	# Further setup the boss fight manager now that the Queen has been spawned.
	_queen_boss.health_component.death.connect(_async_show_queen_defeated_cutscene)
	_queen_boss.set_animation("float")

	# Setup the boss health bar.
	SceneManager.find_boss_health_bar().initialize(
		_queen_boss.health_component,
		"Queen",
	)


# Shows the Queen "defeat" cutscene and updates the game's state.
func _async_show_queen_defeated_cutscene() -> void:
	var defeat_pos: Vector2 = self.get_node("FallToGroundLandingPosition").global_position

	# Replace the Queen boss with the Queen sprite.
	_queen_sprite.global_position = _queen_boss.global_position

	_queen_boss.queue_free()

	# Move the Queen sprite to the "defeat position".
	await self.async_teleport_queen(defeat_pos, true)

	SceneManager.stop_playing_background_music()

	DialogManager.start_dialog(_queen_defeated_dialog)
	await DialogManager.ended_dialog

	SceneManager.add_world_state(Util.WorldState.CUTSCENE_PLAYING)

	await SceneManager.async_delay(1.0)

	_queen_laser.global_position = _player.global_position
	_queen_laser.show()

	await SceneManager.async_delay(0.3)

	SceneManager.remove_world_state(Util.WorldState.CUTSCENE_PLAYING)

	SceneManager.progression().add_milestone(Util.Milestone.INTRO_CASTLE_COMPLETED)

	# Continue the story by going to the forest outside the castle.
	SceneManager.load_scene_file(
		"res://maps/intro_area_outside_castle/forest_outside_castle/forest_outisde_castle.tscn"
	)


## Moves the Queen NPC sprite if `should_just_move_sprite` is true. 
## Otherwise, it moves the queen boss.
func async_teleport_queen(to_position: Vector2, should_just_move_sprite: bool = false) -> void:
	var queen_to_move: Node2D

	if should_just_move_sprite:
		queen_to_move = _queen_sprite
	else:
		queen_to_move = _queen_boss

	queen_to_move.hide()

	var queen_previous_position: Vector2 = queen_to_move.global_position
	queen_to_move.global_position = to_position

	# Show the particles at the Queen's previous position.
	_queen_teleport_particle_emitter.global_position = queen_previous_position
	_queen_teleport_particle_emitter.emitting = true

	await SceneManager.async_delay(_queen_teleport_particle_emitter.lifetime)

	_queen_teleport_particle_emitter.global_position = queen_to_move.global_position

	# Show the particles at the Queen's new position.
	_queen_teleport_particle_emitter.emitting = true

	await SceneManager.async_delay(_queen_teleport_particle_emitter.lifetime)

	queen_to_move.show()

