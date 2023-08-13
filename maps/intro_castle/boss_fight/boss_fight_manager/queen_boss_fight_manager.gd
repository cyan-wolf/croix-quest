extends Node2D

const QueenBoss := preload("res://enemies/bosses/queen/queen_boss.gd")

@onready var _queen_boss_scene: PackedScene = preload("res://enemies/bosses/queen/queen_boss.tscn")

var _queen_boss: QueenBoss

func _ready() -> void:
	self.get_node("../QueenBossFightLoreManager").start_boss_fight.connect(_start_boss_fight)


func _start_boss_fight() -> void:
	_queen_boss = _queen_boss_scene.instantiate() as QueenBoss

	self.get_tree().get_root().add_child(_queen_boss)

	_queen_boss.global_position = self.get_node("BossFightSpawnPosition").global_position

