extends Node2D
class_name InteractionComponent

signal interact

# This node should be added as a child node on other scenes.
# This node should send a signal when the player tries to "interact" with it,
# and it should only send out this signal if the player is within range.

# This node does not come with the scene, it should be added manually.
# This node is useless as of Godot 4.2.
@onready var _hitbox: Area2D = self.get_node("HitboxArea")

## Maximum distance that the player needs to be within before 
## this component can be interacted with (in pixels).
@export var _max_interaction_distance: float = 32.0

## Maximum distance that the mouse needs to be to interact with this component.
@export var _max_mouse_interaction_distance: float = 8.0


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") \
		and _get_distance_to_player() < _max_interaction_distance \
		and _get_mouse_dist_to_self() < _max_mouse_interaction_distance:

		self.interact.emit()


func _get_distance_to_player() -> float:
	return self.global_position.distance_to(SceneManager.find_player().global_position)


func _get_mouse_dist_to_self() -> float:
	return self.get_global_mouse_position().distance_to(self.global_position)

