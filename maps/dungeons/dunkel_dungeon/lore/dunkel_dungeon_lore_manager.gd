extends Node2D

enum SceneLightLevel {
	NORMAL = 0,			# normal brightness
	SLIGHTLY_DIM = 1,	# slightly dark
	VERY_DIM = 2,		# very dark
	PITCH_DARK = 3,		# completely dark
}

# Causes the "darkness" effect in the scene.
@onready var _darkness_modulate: CanvasModulate = self.get_node("../DarknessModulate")

## Duration of the damaging light being on.
@export var _damaging_light_on_duration: float = 2.0

## Duration of the damaging light being off.
@export var _damaging_light_off_duration: float = 2.0

## Damage that the player receives per second.
@export var _damaging_light_dps: float = 1.0

var _damaging_light_is_active := false
var _player_should_be_taking_damaging_light_damage := false

func _ready():
	# Dim the scene's "light" in the second part of the maze.
	self.get_node("../Props/TeleportersCollection/Teleporter3") \
		.used \
		.connect(func(): self.set_dungeon_light_level(SceneLightLevel.VERY_DIM))

	# Turn off the scene's "light" in the third part of the maze.
	self.get_node("../Props/TeleportersCollection/Teleporter4") \
		.used \
		.connect(func(): 
			self.set_dungeon_light_level(SceneLightLevel.PITCH_DARK)
			
			var tile_map: TileMap = self.get_node("../TileMap")

			# Make the walls invisible to get a "spooky" effect.
			tile_map.set_layer_modulate(1, Color("ffffff00")) # 'Background wall' layer
			tile_map.set_layer_modulate(2, Color("ffffff00")) # 'Foreground wall' layer
			)

	# Turn on the scene's "light" after exiting the third part of the maze.
	self.get_node("../Props/TeleportersCollection/Teleporter5") \
		.used \
		.connect(func(): 
			self.set_dungeon_light_level(SceneLightLevel.NORMAL)
			
			var tile_map: TileMap = self.get_node("../TileMap")

			# Make the walls visible again.
			tile_map.set_layer_modulate(1, Color("ffffffff")) # 'Background wall' layer
			tile_map.set_layer_modulate(2, Color("ffffffff")) # 'Foreground wall' layer
			)

	self.get_node("../Props/TeleportersCollection/Teleporter5") \
		.used \
		.connect(_async_turn_on_line_of_sight_damaging_light)

	# Setup timer for the damaging light's damage.
	self.get_node("PlayerDamagingLightDamageTimer").wait_time = 1.0 / _damaging_light_dps

	# Used to deal damage to the player in the "Line of sight" areas.
	self.get_node("PlayerDamagingLightDamageTimer") \
		.timeout \
		.connect(_deal_player_damaging_light_damage)


func _physics_process(_delta: float) -> void:
	_player_should_be_taking_damaging_light_damage = false

	for n in self.get_node("LineOfSight/Hitboxes").get_children():
		var hitbox: Area2D = n

		for other_hitbox in hitbox.get_overlapping_areas():
			if other_hitbox.is_in_group("player_hitbox"):
				_player_should_be_taking_damaging_light_damage = true
				return # no need to keep checking


func set_dungeon_light_level(level: SceneLightLevel) -> void:
	match level:
		SceneLightLevel.NORMAL:
			_darkness_modulate.color = Color("ffffff")

		SceneLightLevel.SLIGHTLY_DIM:
			_darkness_modulate.color = Color("9a9a9a")	

		SceneLightLevel.VERY_DIM:
			_darkness_modulate.color = Color("252525")

		SceneLightLevel.PITCH_DARK:
			_darkness_modulate.color = Color("000000")


func _async_turn_on_line_of_sight_damaging_light() -> void:
	_damaging_light_is_active = true
	
	# Make the damaging lights visible.
	for light in self.get_node("LineOfSight/Lights").get_children():
		light.show()

	# Enable the damaging light hitboxes.
	for hitbox in self.get_node("LineOfSight/Hitboxes").get_children():
		hitbox.get_node("CollisionPolygon2D").set_deferred("disabled", false)

	# Make the eye sprites turn red.
	for sprite in self.get_node("LineOfSight/EyeSprites").get_children():
		sprite.play("attack")

	await SceneManager.async_delay(_damaging_light_on_duration)

	_async_turn_off_line_of_sight_damaging_light() # async call


func _async_turn_off_line_of_sight_damaging_light() -> void:
	_damaging_light_is_active = false
	
	# Make the damaging lights no longer visible.
	for light in self.get_node("LineOfSight/Lights").get_children():
		light.hide()

	# Disable the damaging light hitboxes.
	for hitbox in self.get_node("LineOfSight/Hitboxes").get_children():
		hitbox.get_node("CollisionPolygon2D").set_deferred("disabled", true)

	# Make the eye sprites no longer red.
	for sprite in self.get_node("LineOfSight/EyeSprites").get_children():
		sprite.play("idle")

	await SceneManager.async_delay(_damaging_light_off_duration)

	_async_turn_on_line_of_sight_damaging_light() # async call


func _deal_player_damaging_light_damage() -> void:
	if _player_should_be_taking_damaging_light_damage:
		SceneManager.find_player().health_component.take_damage(1)

