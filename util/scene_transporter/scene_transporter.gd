extends Node2D

## The destination scene.
@export_file("*.tscn") var _destination_scene_path: String
## If `true`, the player from the current scene will be moved to the new scene, along with any picked up weapons, etc.
@export var _keep_player: bool = true

@onready var _hitbox: Area2D = self.get_node("HitboxArea")

func _ready() -> void:
	_hitbox.area_entered.connect(_on_area_entered_hitbox)


func _on_area_entered_hitbox(other_hitbox: Area2D) -> void:
	if other_hitbox.is_in_group("player_hitbox"):
		SceneManager.load_scene_file(
				_destination_scene_path,
				_keep_player, # saves player data across scenes
		)
