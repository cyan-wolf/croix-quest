extends Node2D

@export var _run_warning_dialog: DialogResource
@export var _sword_projectile_sprite_frames: SpriteFrames

var _should_stop_swords_in_long_hall := false

func _ready():
	self.get_node("../PropCollection/TeleporterCollection/Teleporter3") \
		.used \
		.connect(_async_on_long_hall_teleporter_used)

	# Reset the parts of the dungeon that have constantly spawn 
	# projectiles when the player respawns.
	SceneManager.find_player().respawn_component.respawned \
		.connect(_mark_projectile_areas_to_be_reset)


func _async_on_long_hall_teleporter_used() -> void:
	SceneManager.start_cutscene()

	await SceneManager.async_delay(0.5)

	DialogManager.start_dialog(_run_warning_dialog)
	await DialogManager.ended_dialog

	SceneManager.end_cutscene()

	_async_start_firing_sword_projectiles_in_long_hall() # async call


func _async_start_firing_sword_projectiles_in_long_hall() -> void:
	await SceneManager.async_delay(0.5)

	var sword_spawn_positions: Array[Vector2] = []

	sword_spawn_positions.append_array(
		self.get_node("LongHallSwordProjectilePositions")
			.get_children()									# get the position markers
			.map(func(node): return node.global_position)  # get just their position
	)

	# Arbitrarily high number.
	const ITERATIONS := 1000

	for _i in range(ITERATIONS):
		for pos in sword_spawn_positions:
			var speed := 16 * 3 + Player.WALKING_SPEED * Player.DASH_MULTIPLIER

			_summon_sword_projectile(
				pos, 
				speed,
				8,		# damage
			)

		# Stop running this async method if the player dies.
		if _should_stop_swords_in_long_hall:
			_should_stop_swords_in_long_hall = false
			return

		await SceneManager.async_delay(0.8)


# Resets projectile spawning in certain areas of the dungeon.
func _mark_projectile_areas_to_be_reset() -> void:
	_should_stop_swords_in_long_hall = true


func _summon_sword_projectile(spawn_pos: Vector2, speed: float, damage: int) -> void:
	var direction := Vector2.DOWN # the projectiles are falling downwards, so they face down

	# Spawn the projectile.
	Projectile.start_building() \
		.with_global_pos(spawn_pos) \
		.with_impulse(direction * speed) \
		.from_source(Projectile.Source.SHALE_SABER_BOSS) \
		.with_damage(damage) \
		.can_pass_through_wall_edges(true) \
		.with_lifetime(20.0) \
		.with_sprite_frames(_sword_projectile_sprite_frames) \
		.add_to_scene()


