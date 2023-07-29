extends Node2D

@onready var _hitbox: Area2D = self.get_node("HitboxArea")
# The teleporter should have a 'TeleporterDestination' child node (a separate one in each scene).
@onready var _teleporter_destination: Node2D = self.get_node("TeleporterDestination")

@export var _show_loading_screen: bool = true

func _ready() -> void:
	_hitbox.area_entered.connect(_on_area_entered_hitbox)

	# Hide the teleporter's sprites since they are just markers.
	self.hide()
	_teleporter_destination.hide()


func _on_area_entered_hitbox(other_hitbox: Area2D) -> void:
	if other_hitbox.is_in_group("player_hitbox"):
		if _show_loading_screen:
			SceneManager.show_loading_screen()
			await SceneManager.async_delay(0.5)

		SceneManager.find_player().global_position = _teleporter_destination.global_position

		if _show_loading_screen:
			await SceneManager.async_delay(0.5)
			SceneManager.hide_loading_screen()


