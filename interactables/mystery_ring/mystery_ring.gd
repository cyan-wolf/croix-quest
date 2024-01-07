extends Node2D

@onready var _interaction_component: InteractionComponent = self.get_node("InteractionComponent")

# Called when the node enters the scene tree for the first time.
func _ready():
	_interaction_component.interact.connect(_on_player_interact)


func _on_player_interact() -> void:
	print_debug("TODO: Mystery ring picked up")

	self.queue_free()

