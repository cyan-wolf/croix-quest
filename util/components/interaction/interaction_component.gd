extends Node2D
class_name InteractionComponent

signal interact

# This node should be added as a child node on other scenes.
# This node should send a signal when the player tries to "interact" with it,
# and it should only send out this signal if the player is within range.

# This node does not come with the scene, it should be added manually.
@onready var _hitbox: Area2D = self.get_node("HitboxArea")

## Maximum distance that the player needs to be within before 
## this component can be interacted with (in pixels).
@export var _max_interaction_distance: float = 32.0

var _mouse_is_in_hitbox := false

func _ready() -> void:
	_hitbox.mouse_entered.connect(_on_mouse_entered_hitbox)
	_hitbox.mouse_exited.connect(_on_mouse_exited_hitbox)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") \
		and _mouse_is_in_hitbox \
		and _get_distance_to_player() < _max_interaction_distance:
		
		self.interact.emit()


func _on_mouse_entered_hitbox() -> void:
	_mouse_is_in_hitbox = true


func _on_mouse_exited_hitbox() -> void:
	_mouse_is_in_hitbox = false


func _get_distance_to_player() -> float:
	return self.global_position.distance_to(SceneManager.find_player().global_position)

