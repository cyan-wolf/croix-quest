extends Node2D

@export var _run_warning_dialog: DialogResource
@export var _sword_projectile_sprite_frames: SpriteFrames

var _should_stop_swords_in_long_hall := false

var _should_stop_sword_storm := false

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

	# Connect the first 'Sword Storm' attack.
	self.get_node("../PropCollection/TeleporterCollection/Teleporter8") \
		.used \
		.connect(_async_firing_sword_storm_attack.bind(Vector2.DOWN, "SwordStormPositions1")) # currying

	# Connect the second 'Sword Storm' attack.
	self.get_node("../PropCollection/TeleporterCollection/Teleporter9") \
		.used \
		.connect(_async_firing_sword_storm_attack.bind(Vector2.RIGHT, "SwordStormPositions2")) # currying

	# Connect 'Sword Storm' attack reset.
	self.get_node("../PropCollection/TeleporterCollection/Teleporter10") \
		.used \
		.connect(func(): _should_stop_sword_storm = true) # stops the 'Sword Storm' attack

	# Connect 'Sword Intimidation Attack' to various hitboxes.
	for n in self.get_node("IntimidationSwordAttackTriggerHitboxes").get_children():
		var trigger_hitbox: Area2D = n

		trigger_hitbox.area_entered.connect(
			func(other_hitbox: Area2D) -> void:
				if other_hitbox.is_in_group("player_hitbox"):
					_async_fire_intimidation_sword_attack() # async call

				# Disable this hitbox's collision since it will no longer be used.
				trigger_hitbox.get_node("CollisionShape2D").set_deferred("disabled", true)
		)
	
	# Reset the parts of the dungeon that have constantly spawn 
	# projectiles when the player respawns.
	SceneManager.find_player().respawn_component.respawned \
		.connect(_mark_projectile_areas_to_be_reset)

	# Reset the 'Sword Storm' when the player respawns.
	SceneManager.find_player().respawn_component.respawned \
		.connect(func(): _should_stop_sword_storm = true)


func _async_on_long_hall_teleporter_used(dialog: DialogResource, direction: Vector2) -> void:
	SceneManager.start_cutscene()

	await SceneManager.async_delay(0.5)

	DialogManager.start_dialog(dialog)
	await DialogManager.ended_dialog

	SceneManager.end_cutscene()

	await SceneManager.async_delay(0.5)

	_async_start_firing_sword_projectiles_in_long_hall(direction) # async call


func _async_start_firing_sword_projectiles_in_long_hall(direction: Vector2) -> void:
	# Set this to `false` at the start of this method, since 
	# this field only should be set to `true` after this 
	# method has been running already for a while.
	_should_stop_swords_in_long_hall = false 

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


func _async_firing_sword_storm_attack(direction: Vector2, node_with_position_name: NodePath) -> void:
	# Set this to `false` at the start of this method, since 
	# this field only should be set to `true` after this 
	# method has been running already for a while.
	_should_stop_sword_storm = false

	var pos_markers: Array[Vector2] = []

	pos_markers.append_array(
		self.get_node(node_with_position_name) # should be either "SwordStormPositions1" or "SwordStormPositions2"
			.get_children()
			.map(func(n): return n.global_position)
	)

	var pos_1 = pos_markers[0]
	var pos_2 = pos_markers[1]

	while true:
		randomize()
		var random_coord: float = 0.0       # unitialized
		var pos: Vector2 = Vector2.ZERO		# unitialized

		# Checks if the direction is vertical (Vector2.UP or Vector2.DOWN).
		if is_equal_approx(direction.dot(Vector2.RIGHT), 0.0):
			random_coord = randf_range(pos_1.x, pos_2.x)	# the projectiles only vary in the x-coord
			pos = Vector2(random_coord, pos_1.y)			# the projectiles have the same y-coord

		# Runs if the direction is horizontal (Vector2.LEFT or Vector2.RIGHT).
		else:
			random_coord = randf_range(pos_1.y, pos_2.y)	# the projectiles only vary in the y-coord
			pos = Vector2(pos_1.x, random_coord) 			# the projectiles have the same x-coord

		_summon_sword_projectile(
			pos,
			16 * 25,
			1,
			direction,
		)

		# This delay determines how fast the projectiles spawn.
		await SceneManager.async_delay(0.08)

		if _should_stop_sword_storm:
			_should_stop_sword_storm = false
			return


func _async_fire_intimidation_sword_attack() -> void:
	await SceneManager.async_delay(0.01)

	for n in self.get_node("IntimidationSwordPositions").get_children():
		var sword_pos: Vector2 = n.global_position

		# The "forward" direction of the position marker, used here
		# for marking what direction the projectile should go in.
		var direction: Vector2 = n.global_transform.x 

		_summon_sword_projectile(
			sword_pos,
			16 * 20,
			1,		    
			direction,
		)
	

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
		.with_sprite_frames(Projectile.SpriteFramesConsts.SHALE_SABER_BOSS) \
		.with_trail_gradient(Projectile.TrailConsts.SHALE_SABER_BOSS) \
		.add_to_scene()


