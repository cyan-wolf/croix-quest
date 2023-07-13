extends Node2D

@onready var _hitbox: Area2D = self.get_node("HitboxArea")

func _ready() -> void:
	_hitbox.area_entered.connect(_on_area_entered_hitbox)


# INFO: This enemy type is only for testing purposes.
func _on_area_entered_hitbox(other_hitbox: Area2D) -> void:
	if other_hitbox.is_in_group("player_hitbox"):
		self.queue_free()

	elif other_hitbox.is_in_group("bullet_hitbox"):
		self.queue_free()

