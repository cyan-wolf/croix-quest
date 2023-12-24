extends Node2D

signal activated

@onready var _hitbox: Area2D = self.get_node("HitboxArea")

func _ready() -> void:
	_hitbox.area_entered.connect(_on_area_entered_hitbox)


func _on_area_entered_hitbox(other_hitbox: Node2D) -> void:	
	if other_hitbox.is_in_group("player_ground_hitbox"):
		self.activated.emit()

