extends Node2D

# TODO: 
# This node should be added as a child node on other scenes.
# This node should send a signal when the player tries to "interact" with it,
# and it should only send out this signal if the player is within range.
# The range can be determined using the hitbox.

# This node does not come with the scene, it should be added manually.
@onready var _hitbox: Area2D = self.get_node("HitboxArea")

func _ready() -> void:
	_hitbox.area_entered.connect(_on_area_entered_hitbox)


# This method might not be needed.
func _on_area_entered_hitbox(other_hitbox: Area2D) -> void:
	pass


