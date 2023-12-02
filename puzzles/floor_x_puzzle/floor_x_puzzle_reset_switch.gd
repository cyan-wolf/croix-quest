extends Node2D

signal activated

@onready var _hitbox: Area2D = self.get_node("HitboxArea")

func _ready() -> void:
	_hitbox.body_entered.connect(_on_body_entered_hitbox)


# This hitbox needs to collide with the player's ground collision, not the regular hitbox.
func _on_body_entered_hitbox(other_hitbox: Node2D) -> void:	
	if other_hitbox.is_in_group("player_physics_body_collision"):
		self.activated.emit()

