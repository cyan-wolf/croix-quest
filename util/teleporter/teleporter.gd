extends Node2D

@onready var _hitbox: Area2D = self.get_node("HitboxArea")

@export var _teleport_destination: Vector2
@export var _show_loading_screen: bool = true

func _ready() -> void:
	_hitbox.area_entered.connect(_on_area_entered_hitbox)


func _on_area_entered_hitbox(other_hitbox: Area2D) -> void:
	if other_hitbox.is_in_group("player_hitbox"):
		SceneManager.show_loading_screen()
		await SceneManager.async_delay(0.5)

		SceneManager.find_player().global_position = _teleport_destination

		await SceneManager.async_delay(0.5)
		SceneManager.hide_loading_screen()


