extends Node2D

# This node is just a teleporter that puts the player in 
# Cobalt Dungeon's boss fight scene.

@onready var _hitbox: Area2D = self.get_node("HitboxArea")

func _ready() -> void:
	_hitbox.area_entered.connect(_on_area_entered_hitbox)


func _on_area_entered_hitbox(other_hitbox: Area2D) -> void:
	if other_hitbox.is_in_group("player_hitbox"):
		# TODO: Make a way for the player to keep the weapons previously 
		# obtained in the dungeon, since the player is technically still in the same dungeon.
		SceneManager.load_scene_file(
				"res://maps/dungeons/cobalt_dungeon/boss_fight/cobalt_dugeon_boss_fight.tscn",
				true, # saves player data across scenes
		)

