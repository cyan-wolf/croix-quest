extends Node2D

@onready var _interaction_component: InteractionComponent = self.get_node("InteractionComponent")

func _ready() -> void:
	_interaction_component.interact.connect(_on_player_interact)


func _on_player_interact() -> void:
	SceneManager.find_player().mana_component.gain_mana(1)
	self.queue_free()

