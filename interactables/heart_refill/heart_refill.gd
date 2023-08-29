extends Node2D

@onready var _interaction_component: InteractionComponent = self.get_node("InteractionComponent")

func _ready() -> void:
	_interaction_component.interact.connect(_on_player_interact)


func _on_player_interact() -> void:
	# The player should gain 2 health since: 2 health = 1 heart (in the HUD).
	SceneManager.find_player().health_component.gain_health(2)
	self.queue_free()

