extends Node2D

@export var _run_warning_dialog: DialogResource
@export var _sword_projectile_sprite_frames: SpriteFrames

var _should_stop_swords_in_long_hall := false

func _ready():
	# Connect the first hall sword attack.
	self.get_node("../PropCollection/TeleporterCollection/Teleporter3") \
		.used \
		.connect(_async_on_long_hall_teleporter_used.bind(_run_warning_dialog, Vector2.DOWN)) # currying

	# Connect the first hall sword attack reset.
	self.get_node("../PropCollection/TeleporterCollection/Teleporter4") \
		.used \
		.connect(_mark_projectile_areas_to_be_reset)

	# Connect the first hall sword attack reset.
	self.get_node("../PropCollection/TeleporterCollection/Teleporter6") \
		.used \
		.connect(_mark_projectile_areas_to_be_reset)

	# Connect the second hall sword attack.
	self.get_node("../PropCollection/TeleporterCollection/Teleporter5") \
		.used \
		.connect(_async_on_long_hall_teleporter_used.bind(_run_warning_dialog, Vector2.RIGHT)) # currying

	# Connect the second hall sword attack.
	self.get_node("../PropCollection/TeleporterCollection/Teleporter7") \
		.used \
		.connect(_async_on_long_hall_teleporter_used.bind(_run_warning_dialog, Vector2.RIGHT)) # currying

	# Connect the 'Sword Storm' attack.
	self.get_node("../PropCollection/TeleporterCollection/Teleporter8") \
		.used \
		.connect(_async_firing_sword_storm_attack)

	# Reset the parts of the dungeon that have constantly spawn 
	# projectiles when the player respawns.
	SceneManager.find_player().respawn_component.respawned \
		.connect(_mark_projectile_areas_to_be_reset)


func _async_on_long_hall_teleporter_used(dialog: DialogResource, direction: Vector2) -> void:
	SceneManager.start_cutscene()

	await SceneManager.async_delay(0.5)

	DialogManager.start_dialog(dialog)
	await DialogManager.ended_dialog

	SceneManager.end_cutscene()

	await SceneManager.async_delay(0.5)

	_async_start_firing_sword_projectiles_in_long_hall(direction) # async call


func _async_start_firing_sword_projectiles_in_long_hall(direction: Vector2) -> void:
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
				direction,
			)

		# Stop running this async method if the player dies.
		if _should_stop_swords_in_long_hall:
			_should_stop_swords_in_long_hall = false
			return

		await SceneManager.async_delay(0.8)


func _async_firing_sword_storm_attack() -> void:
	print_debug("TODO: Sword storm attack")


# Resets projectile spawning in certain areas of the dungeon.
func _mark_projectile_areas_to_be_reset() -> void:
	_should_stop_swords_in_long_hall = true


func _summon_sword_projectile(spawn_pos: Vector2, speed: float, damage: int, direction: Vector2) -> void:
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


