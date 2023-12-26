extends Node2D

enum SceneLightLevel {
	NORMAL = 0,			# normal brightness
	SLIGHTLY_DIM = 1,	# slightly dark
	VERY_DIM = 2,		# very dark
	PITCH_DARK = 3,		# completely dark
}

@onready var _darkness_modulate: CanvasModulate = self.get_node("../DarknessModulate")

func _ready():
	# Dim the scene's "light" in the second part of the maze.
	self.get_node("../Props/TeleportersCollection/Teleporter3") \
		.used \
		.connect(func(): _set_dungeon_light_level(SceneLightLevel.VERY_DIM))

	# Turn off the scene's "light" in the third part of the maze.
	self.get_node("../Props/TeleportersCollection/Teleporter4") \
		.used \
		.connect(func(): 
			_set_dungeon_light_level(SceneLightLevel.PITCH_DARK)
			
			var tile_map: TileMap = self.get_node("../TileMap")

			# Make the walls invisible to get a "spooky" effect.
			tile_map.set_layer_modulate(1, Color("ffffff00")) # 'Background wall' layer
			tile_map.set_layer_modulate(2, Color("ffffff00")) # 'Foreground wall' layer
			)

	# Turn on the scene's "light" after exiting the third part of the maze.
	self.get_node("../Props/TeleportersCollection/Teleporter5") \
		.used \
		.connect(func(): 
			_set_dungeon_light_level(SceneLightLevel.NORMAL)
			
			var tile_map: TileMap = self.get_node("../TileMap")

			# Make the walls visible again.
			tile_map.set_layer_modulate(1, Color("ffffffff")) # 'Background wall' layer
			tile_map.set_layer_modulate(2, Color("ffffffff")) # 'Foreground wall' layer
			)


func _set_dungeon_light_level(level: SceneLightLevel) -> void:
	match level:
		SceneLightLevel.NORMAL:
			_darkness_modulate.color = Color("ffffff")

		SceneLightLevel.SLIGHTLY_DIM:
			_darkness_modulate.color = Color("9a9a9a")	

		SceneLightLevel.VERY_DIM:
			_darkness_modulate.color = Color("252525")

		SceneLightLevel.PITCH_DARK:
			_darkness_modulate.color = Color("000000")

