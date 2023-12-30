extends Node2D

signal landed

var _height: float = 16 * 10
var _duration: float = 0.8

func async_land_on_player(forest_sprit_sprite_scene: PackedScene) -> void:
	self.add_child(forest_sprit_sprite_scene.instantiate())

	# Wait for the forest spirit to go up.
	await self.create_tween().tween_property(
		self,
		"global_position",
		self.global_position + Vector2.UP * _height,
		_duration,
	).finished

	# Make the forest spirit be at the same x value as the player, 
	# so that it lands on the player.
	self.global_position.x = SceneManager.find_player().global_position.x

	# Wait for the forest spirit to land on the player.
	await self.create_tween().tween_property(
		self,
		"global_position",
		SceneManager.find_player().global_position,
		_duration,
	).finished

	# TODO: Make a particle SFX for the player obtaining the forest spirit.

	self.landed.emit()

	self.hide()

