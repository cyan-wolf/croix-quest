extends Node2D

@onready var _interaction_component: InteractionComponent = self.get_node("InteractionComponent")

@export var _effect_duration_in_secs: float = 10.0

func _ready() -> void:
	_interaction_component.interact.connect(_on_player_interact)


func _on_player_interact() -> void:
	var status_effect := Util.StatusEffect.new(
			Util.StatusEffectType.DEFENSE, 
			_effect_duration_in_secs,
	)

	SceneManager.find_player().add_status_effect(status_effect)

	self.queue_free()

